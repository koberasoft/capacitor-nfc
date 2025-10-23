import Foundation
import Capacitor
import CoreNFC

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(NfcPlugin)
public class NfcPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NfcPlugin"
    public let jsName = "Nfc"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "startScanSession", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopScanSession", returnType: CAPPluginReturnPromise)
    ]
    
    private let implementation = Nfc()
    private var nfcSession: NFCNDEFReaderSession?
    private var isScanning = false

    @objc func startScanSession(_ call: CAPPluginCall) {
        guard NFCNDEFReaderSession.readingAvailable else {
            call.reject("NFC not supported on this device")
            return
        }
        
        implementation.delegate = self
        nfcSession = NFCNDEFReaderSession(delegate: implementation, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold your iPhone near an NFC tag to scan it."
        nfcSession?.begin()
        isScanning = true
        
        call.resolve()
    }
    
    @objc func stopScanSession(_ call: CAPPluginCall) {
        if isScanning {
            nfcSession?.invalidate()
            nfcSession = nil
            isScanning = false
        }
        call.resolve()
    }
}

// MARK: - NFC Delegate Extension
extension NfcPlugin: NfcDelegate {
    func nfcTagDetected(tagId: String) {
        notifyListeners("nfcTagScanned", data: ["nfcTag": tagId])
    }
    
    func nfcScanningFinished() {
        isScanning = false
        nfcSession = nil
    }
}
