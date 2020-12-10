//
//  Nfc.swift
//  nfcbug
//
//  Created by Dusan Klinec on 30/09/2020.
//

import Foundation
import CoreNFC

class NfcClosePoc: NSObject, NFCTagReaderSessionDelegate {
    var cv: ContentView? = nil
    
    private(set) var session: NFCTagReaderSession?
    private(set) var queue = DispatchQueue(label: "cardChannel", qos: .default)
    
    func startNfc() {
        openSession()
    }
    
    deinit {
        self.cv = nil
    }
    
    private func openSession() {
        logView("Opening NFC session")
        
        session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: queue)
        session?.alertMessage = "Please wait"
        session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        logView("tagReaderSessionDidBecomeActive")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
            self.logView("Closing session, waiting for callback. Lock the screen.")
            self.session?.alertMessage = "Lock the screen now"
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)){
                self.session?.invalidate()
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        logView("Callback received, error: \(error)")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        logView("tagReaderSession didDetect tags")
    }
    
    func logView(_ text: String){
        NSLog(text)
        DispatchQueue.main.async {
            self.cv?.setTxt(text)
        }
    }
}

