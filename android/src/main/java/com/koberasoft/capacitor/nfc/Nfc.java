package com.koberasoft.capacitor.nfc;

import android.nfc.NfcAdapter;
import android.content.Context;
import com.getcapacitor.Logger;

public class Nfc {

    public boolean isNfcEnabled(Context context) {
        NfcAdapter nfcAdapter = NfcAdapter.getDefaultAdapter(context);
        if (nfcAdapter == null) {
            Logger.info("NFC", "NFC is not supported on this device");
            return false;
        }
        return nfcAdapter.isEnabled();
    }

    public boolean isNfcSupported(Context context) {
        NfcAdapter nfcAdapter = NfcAdapter.getDefaultAdapter(context);
        return nfcAdapter != null;
    }

    public String formatTagId(byte[] tagId) {
        if (tagId == null) return null;
        StringBuilder hexId = new StringBuilder();
        for (byte b : tagId) {
            hexId.append(String.format("%02X", b));
        }
        return hexId.toString();
    }
}
