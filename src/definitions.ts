export interface NfcPlugin {
  startScanSession(): Promise<void>;
  stopScanSession(): Promise<void>;
  
  // Event listener methods
  addListener(eventName: 'nfcTagScanned', listenerFunc: (data: { nfcTag: string }) => void): Promise<any>;
  removeAllListeners(): Promise<void>;
}
