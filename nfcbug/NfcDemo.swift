//
//  Nfc.swift
//  nfcbug
//
//  Created by Dusan Klinec on 30/09/2020.
//  AIDS: https://www.eftlab.com/knowledge-base/211-emv-aid-rid-pix/
//

import Foundation
import CoreNFC

class NfcDemo: NSObject, NFCTagReaderSessionDelegate {
    var cv: ContentView? = nil
    
    private(set) var session: NFCTagReaderSession?
    private(set) var queue = DispatchQueue(label: "cardChannel", qos: .default)
    private(set) var timeActive: DispatchTime? = nil
    private(set) var timeInvalidated: DispatchTime? = nil
    private(set) var sessCtr = 0
    
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
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: queue)
        session?.alertMessage = "Tap your card near the iPhone top speaker."
        session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        logView("tagReaderSessionDidBecomeActive")
        timeActive = .now()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        logView("tagReaderSession invalidated \(error)")
        timeInvalidated = .now()
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
}
