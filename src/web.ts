import { WebPlugin } from '@capacitor/core';

import type { NfcPlugin } from './definitions';

// export class NfcWeb extends WebPlugin implements NfcPlugin {
//   // async echo(options: { value: string }): Promise<{ value: string }> {
//   //   console.log('ECHO', options);
//   //   return options;
//   // }
// }

export class NfcWeb extends WebPlugin implements NfcPlugin {
  private listening = false;

  async startListening(): Promise<{ status: string }> {
    this.listening = true;
    console.log('[NfcWeb] NFC listening started (simulated)');
    return { status: 'listening (simulated)' };
  }

  async stopListening(): Promise<{ status: string }> {
    this.listening = false;
    console.log('[NfcWeb] NFC listening stopped');
    return { status: 'stopped' };
  }

  // You can use this method for testing from console:
  simulateScan(uid: string) {
    if (this.listening) {
      this.notifyListeners('nfcTagScanned', { uid });
      console.log(`[NfcWeb] Simulated scan: ${uid}`);
    } else {
      console.warn('[NfcWeb] Not listening; ignoring simulated scan');
    }
  }
}
