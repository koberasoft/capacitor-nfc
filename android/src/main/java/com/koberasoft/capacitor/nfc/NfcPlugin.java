package com.koberasoft.capacitor.nfc;

import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentFilter;
import android.nfc.NfcAdapter;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "Nfc")
public class NfcPlugin extends Plugin {

    private NfcAdapter nfcAdapter;
    private String lastScannedTag;
    private boolean isScanning = false;

    @PluginMethod
    public void startScanSession(PluginCall call) {
        nfcAdapter = NfcAdapter.getDefaultAdapter(getContext());
        if (nfcAdapter == null) {
            call.reject("NFC not supported on this device");
            return;
        }
        
        if (!nfcAdapter.isEnabled()) {
            call.reject("NFC is not enabled");
            return;
        }
        
        Intent intent = new Intent(getContext(), getActivity().getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(getContext(), 0, intent, PendingIntent.FLAG_MUTABLE);

        IntentFilter[] filters = new IntentFilter[]{new IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED)};
        nfcAdapter.enableForegroundDispatch(getActivity(), pendingIntent, filters, null);
        
        isScanning = true;
        lastScannedTag = null;
        
        call.resolve();
    }

    @PluginMethod
    public void stopScanSession(PluginCall call) {
        if (nfcAdapter != null && isScanning) {
            nfcAdapter.disableForegroundDispatch(getActivity());
            isScanning = false;
            lastScannedTag = null;
        }
        call.resolve();
    }

    @PluginMethod
    public void nfcTagScanned(PluginCall call) {
        if (lastScannedTag != null) {
            JSObject ret = new JSObject();
            ret.put("nfcTag", lastScannedTag);
            call.resolve(ret);
        } else {
            call.reject("No NFC tag has been scanned");
        }
    }

    @Override
    protected void handleOnNewIntent(Intent intent) {
        super.handleOnNewIntent(intent);
        if (isScanning && NfcAdapter.ACTION_TAG_DISCOVERED.equals(intent.getAction())) {
            byte[] tagId = intent.getByteArrayExtra(NfcAdapter.EXTRA_ID);
            if (tagId != null) {
                StringBuilder hexId = new StringBuilder();
                for (byte b : tagId) {
                    hexId.append(String.format("%02X", b));
                }
                lastScannedTag = hexId.toString();
                
                JSObject data = new JSObject();
                data.put("nfcTag", lastScannedTag);
                notifyListeners("nfcTagScanned", data);
            }
        }
    }
}
