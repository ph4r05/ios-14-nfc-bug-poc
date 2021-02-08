//
//  Nfc.swift
//  nfcbug
//
//  Created by Dusan Klinec on 30/09/2020.
//  AIDS: https://www.eftlab.com/knowledge-base/211-emv-aid-rid-pix/
//

import Foundation
import CoreNFC

class Nfc: NSObject, NFCTagReaderSessionDelegate {
    var cv: ContentView? = nil
    
    private(set) var session: NFCTagReaderSession?
    private(set) var queue = DispatchQueue(label: "cardChannel", qos: .default)
    private(set) var timeActive: DispatchTime? = nil
    private(set) var timeInvalidated: DispatchTime? = nil
    private(set) var sessCtr = 0
    private(set) var invalidateTask: DispatchWorkItem? = nil
    private(set) var invalidatedByTask = false
    
    func startNfc() {
        sessCtr = 0
        openSession()
    }
    
    deinit {
        self.cv = nil
    }
    
    private func openSession() {
        logView("Opening NFC session, ctr=\(sessCtr), diff since last invalidate: \(Nfc.getDiff(DispatchTime.now(), timeInvalidated))")
        
        sessCtr += 1
        invalidateTask?.cancel()
        invalidateTask = nil
        invalidatedByTask = false
        
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: queue)
        session?.alertMessage = "Tap your card near the iPhone top speaker."
        session?.begin()
        
        // Monitor if session starts in 5 seconds (plenty of time)
        let invTask = DispatchWorkItem { [weak self] in
            self?.logView("Invalidating task triggered - NFC session not started")
            self?.invalidatedByTask = true
            self?.session?.invalidate(errorMessage: "Invalidated by task")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000), execute: invTask)
        invalidateTask = invTask
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        logView("tagReaderSessionDidBecomeActive")
        timeActive = .now()
        invalidatedByTask = false
        invalidateTask?.cancel()
        invalidateTask = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
            self.session?.alertMessage = "Going to Step 2"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)){
            self.session?.invalidate()
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        logView("tagReaderSession invalidated \(error), by watchdog task: \(invalidatedByTask)")
        timeInvalidated = .now()
        
        if sessCtr <= 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)){
                self.openSession()
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        logView("tagReaderSession didDetect tags: \(tags)")
        let tag = tags.first!
        if case .iso7816(let ctag) = tag {
            logView("Tag detected, ID: \(ctag.identifier.hexEncodedString()), AID: \(ctag.initialSelectedAID), histData: \(ctag.historicalBytes?.hexEncodedString() ?? "-"), appData: \(ctag.applicationData?.hexEncodedString() ?? "-")")
        }
    }
    
    func logView(_ text: String){
        NSLog(text)
        DispatchQueue.main.async {
            self.cv?.setTxt(text)
        }
    }
    
    static let nanos: Double = 1_000_000_000
    static func getDiff(_ a: DispatchTime?, _ b: DispatchTime?) -> Double {
        if a == nil || b == nil {
            return -1
        }
        return Double(Int64(a!.uptimeNanoseconds) - Int64(b!.uptimeNanoseconds)) / nanos;
    }
    

}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
