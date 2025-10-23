import Foundation
import CoreNFC

@objc protocol NfcDelegate: AnyObject {
    func nfcTagDetected(tagId: String)
    func nfcScanningFinished()
}

@objc public class Nfc: NSObject {
    @objc weak var delegate: NfcDelegate?
    
    @objc public func isNfcSupported() -> Bool {
        return NFCNDEFReaderSession.readingAvailable
    }
    
    private func formatTagId(_ data: Data) -> String {
        return data.map { String(format: "%02X", $0) }.joined()
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension Nfc: NFCNDEFReaderSessionDelegate {
    @objc public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        delegate?.nfcScanningFinished()
        
        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                print("NFC session cancelled by user")
            case .readerSessionInvalidationErrorSessionTimeout:
                print("NFC session timed out")
            default:
                print("NFC session error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Handle NDEF messages if needed
        for message in messages {
            for record in message.records {
                let payload = String(data: record.payload, encoding: .utf8) ?? ""
                print("NDEF Record: \(payload)")
            }
        }
    }
    
    @objc public func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { (error: Error?) in
            if let error = error {
                session.alertMessage = "Connection error: \(error.localizedDescription)"
                session.invalidate()
                return
            }
            
            // Get tag identifier
            if let tagId = tag.identifier {
                let hexId = self.formatTagId(tagId)
                DispatchQueue.main.async {
                    self.delegate?.nfcTagDetected(tagId: hexId)
                }
                session.alertMessage = "NFC tag detected successfully!"
            } else {
                session.alertMessage = "Could not read tag identifier"
            }
            
            session.invalidate()
        }
    }
}
