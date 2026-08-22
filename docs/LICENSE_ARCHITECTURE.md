# FWD License & MAVLink Signing Architecture

## Overview

FWD AgriGCS uses license-based MAVLink 2.0 signing to secure communication between the ground control station and drones. Each drone requires a unique 96-character license key that, when activated, unlocks a 32-byte signing key used for HMAC-based packet authentication.

---

## Flow Diagram

```
ANVIL LICENSE SERVER                    GCS (FWDAgriGCS)                    DRONE
┌─────────────────────┐                 ┌─────────────────────────┐          ┌──────────┐
│ master_aes.key      │                 │                         │          │          │
│ (32 bytes)           │                │  1. Launch GCS          │          │          │
│                      │                │     ↓                            │          │          │
│  boardUID[12]        │                │  2. LoginPage           │          │          │
│  + signingKey[32]    │                │     ↓                            │          │          │
│  + pad[6]            │                │  3. Connections         │          │          │
│  → 44 bytes          │                │     SUSPENDED           │          │          │
│                      │                │     ("Awaiting login")  │          │          │
│  AES-256-GCM         │                │                         │          │          │
│  encrypt             │                │  4. User enters         │          │          │
│  ↓                            │                │     license key         │          │          │
│                      │                │     in LicensePage      │          │          │
│  96-char base64url   │─────────►      │     ↓                           │          │          │
│  license key         │   (delivered)  │  5. base64url decode    │          │          │
│                      │                │     → 72 bytes          │          │          │
│                      │                │     nonce[12]           │          │          │
│                      │                │     + ciphertext[44]    │          │          │
│                      │                │     + tag[16]           │          │          │
│                      │                │     ↓                            │          │          │
│                      │                │  6. AES-256-GCM         │          │          │
│                      │                │     decrypt             │          │          │
│                      │                │     (master_aes.key)    │          │          │
│                      │                │     ↓                            │          │          │
│                      │                │  7. Plaintext:           │          │          │
│                      │                │     boardUID[12]        │          │          │
│                      │                │     + signingKey[32]    │          │          │
│                      │                │     + padding[6]        │          │          │
│                      │                │     ↓                            │          │          │
│                      │                │  8. Save signingKey     │          │          │
│                      │                │     in QSettings        │          │          │
│                      │                │     under boardUID      │          │          │
│                      │                │     ↓                            │          │          │
│                      │                │  9. activationSucceeded │          │          │
│                      │                │     signal fires        │          │          │
│                      │                │     ↓                            │          │          │
│                      │                │ 10. startMavlink        │          │          │
│                      │                │     Connections()       │          │          │
│                      │                │     (resumes auto-      │          │          │
│                      │                │      connect)           │          │          │
│                      │                │     ↓                           │          │          │
│                      │                │                         │◄────────┤          │
│                      │                │ 11. Auto-connect        │  MAVLink │          │
│                      │                │     ↓                           │          │          │
│                      │                │ 12. AUTOPILOT_VERSION   │◄─────────┤          │
│                      │                │     received            │          │          │
│                      │                │     ↓                           │          │          │
│                      │                │ 13. Extract uid2[0:12]  │          │          │
│                      │                │     → _boardUid         │          │          │
│                      │                │     ↓                            │          │          │
│                      │                │ 14. _checkLicense()     │          │          │
│                      │                │     ↓                           │          │          │
│                      │                │ 15. Lookup signingKey   │          │          │
│                      │                │     in QSettings        │          │          │
│                      │                │     by _boardUid        │          │          │
│                      │                │     ↓                            │          │          │
│                      │                │ 16a. Key found?         │          │          │
│                      │                │     YES →                     │          │          │
│                      │                │     enableSigningWithKey│          │          │
│                      │                │     → HMAC signed       │─────────►│  Verify  │
│                      │                │       MAVLink packets   │          │  signing │
│                      │                │                         │          │          │
│                      │                │ 16b. NO license?        │          │          │
│                      │                │     → closeVehicle()    │──X──────►│          │
│                      │                │     → ignoreVehicleId() │          │          │
└─────────────────────┘                 └─────────────────────────┘           └──────────┘
```

---

## License Key Structure

```
96-character base64url license key
│
├─ Base64URL decode → 72 bytes
│
├─ nonce (IV) ........ 12 bytes  ─┐
├─ ciphertext ........ 44 bytes  ─┤── AES-256-GCM decrypt
└─ GCM auth tag ...... 16 bytes  ─┘  (master_aes.key)
                                      │
                                      ▼ plaintext → 44 bytes
                                      │
                                      ├─ boardUID ........ 12 bytes
                                      │   (24 hex chars, e.g. "35001A001851313334373032")
                                      │
                                      ├─ signingKey ...... 32 bytes
                                      │   (64 hex chars, the raw HMAC key)
                                      │
                                      └─ padding ......... 6 bytes
                                          (zeros, for AES block alignment)
```

| Field | Size | Description |
|-------|------|-------------|
| `nonce` | 12 bytes | Initialization vector for AES-GCM |
| `ciphertext` | 44 bytes | AES-256-GCM encrypted boardUID + signingKey + padding |
| `tag` | 16 bytes | GCM authentication tag (integrity check) |
| `boardUID` | 12 bytes | Drone's unique serial number from `AUTOPILOT_VERSION.uid2[0:12]` |
| `signingKey` | 32 bytes | Raw secret key for MAVLink 2.0 HMAC signing |
| `padding` | 6 bytes | Zero padding (AES-GCM operates on blocks) |

---

## Files Reference

### Source Files

| File | Purpose |
|------|---------|
| `src/License/LicenseMasterKeys.h` | Embedded `master_aes.key` (32 bytes) and `master_public.pem` (ECDSA P-256) |
| `src/License/FWDLicenseManager.h/.cc` | AES-256-GCM decryption, QSettings persistence, activate/lookup/list/remove |
| `src/License/FWDCertVerifier.h/.cc` | ECDSA P-256 signature verification (optional FTP-based certs) |
| `src/Vehicle/Vehicle.h/.cc` | `_boardUid`, `_checkLicense()`, `activateAndConnectLicense()`, `licenseRequired`/`licenseError`/`licenseActivated` signals |
| `src/Vehicle/InitialConnectStateMachine.cc` | Extracts `uid2[0:12]` from `AUTOPILOT_VERSION`, sets `_boardUid`, calls `_checkLicense()` |
| `src/comm/MAVLinkSigning.h/.cc` | MAVLink 2.0 signing engine (port from reference) |
| `src/Vehicle/VehicleLinkManager.cc` | Auto-restores signing 100ms after link established |
| `src/QmlControls/QGroundControlQmlGlobal.h/.cc` | `licenseManager` Q_PROPERTY exposed to QML |
| `src/QGCToolbox.h/.cc` | `FWDLicenseManager` singleton creation |

### QML Files

| File | Purpose |
|------|---------|
| `src/ui/preferences/LicensePage.qml` | License activation UI, activated drones list, connection prompt |
| `src/ui/preferences/MavlinkSettings.qml` | "License Keys" button in MAVLink settings |
| `src/ui/MainRootWindow.qml` | Login page, `licenseRequired` dialog |
| `src/FlightDisplay/FlyView.qml` | Signing lock indicator (green/orange/grey dot) |
| `LoginPage.qml` | License-based login with SQLite (deferred MAVLink) |

### Build Files

| File | Purpose |
|------|---------|
| `qgroundcontrol.pro` | Linux: `PKGCONFIG += openssl` `LIBS += -lssl -lcrypto`; Android: `INCLUDEPATH` + static lib per arch |
| `QGCExternalLibs.pri` | Android OpenSSL `.so` bundling via `android_openssl/openssl.pri` |
| `src/License/CMakeLists.txt` | CMake target linking OpenSSL |
| `qgroundcontrol.qrc` | LicensePage.qml resource registration |

---

## Embedded Secrets

### `kFWDMasterAESKey` (in `LicenseMasterKeys.h`)

- 32-byte AES-256 key
- Hex: `4459741658788c91f2ef6f359ba3756e3e115151238e7095c4c358b64d3f9467`
- Used for AES-256-GCM decryption of license keys
- Provided by Anvil team via `master_aes.key`

### `kFWDMasterPublicKeyPEM` (in `LicenseMasterKeys.h`)

- ECDSA P-256 public key (PEM format)
- Used for optional certificate verification (MAVLink FTP download of `/APM/scripts/fwd_license.bin`)
- Provided by Anvil team via `master_public.pem`

---

## Key Implementation Details

### Connection Deferral

The GCS suspends auto-connect at startup:
1. `QGCApplication::_initForNormalApp` → `setConnectionsSuspended("Awaiting login")`
2. LoginPage hides → `startMavlinkConnections()` is NOT called (connections remain suspended)
3. Only when `FWDLicenseManager::activationSucceeded` fires → `startMavlinkConnections()` resumes
4. The `_connectionsSuspended` flag gates `LinkManager::_updateAutoConnectLinks()` timer

### Per-Drone License Check

`Vehicle::_checkLicense()` runs inside `InitialConnectStateMachine` immediately after `AUTOPILOT_VERSION.uid2` is received:
- **License found** → `enableSigningWithKey()` on the MAVLink channel
- **No license** → `emit licenseRequired()` + `closeVehicle()` + `ignoreVehicleId()` (drone disconnected)

### Board UID Extraction

`InitialConnectStateMachine::_autopilotVersionRequestMessageHandler` reads `uid2[0:12]` as raw bytes and converts to a hex string → sets `Vehicle::_boardUid`.

### MAVLink Signing Initialization

Per-link signing auto-restore is handled by `VehicleLinkManager.cc` using `QTimer::singleShot(100ms)` after link establishment.

---

## Testing

### 1. License Activation + MAVLink Signing

```
1. Launch GCS
2. Settings → MAVLink → License Keys
3. Enter 96-char license key → Activate
   ✓ Status: "Activated license for drone <UID>"
   ✓ Drone connects automatically
   ✓ FlyView signing indicator turns green
   ✓ Terminal: "MAVLinkSigning::initSigning: Enabling signing on channel X"
```

### 2. Wrong License Rejection

```
1. Launch GCS
2. Enter incorrect license key → Activate
   ✓ Status: "Invalid license key — decryption failed"
   ✓ Drone does NOT connect (connections remain suspended)
```

### 3. Wrong Drone UID

```
1. Launch GCS
2. Enter a license key issued for a DIFFERENT drone
   ✓ Status: "License key does not match this drone (UID: ...)"
   ✓ Activation saved but the connected drone disconnects
```

### 4. No License

```
1. Connect a drone without activating a license
   ✓ Drone connects briefly
   ✓ "License Required for Connected Drone" prompt appears
   ✓ Drone disconnects (closeVehicle + ignoreVehicleId)
```

### 5. DRONEID Authorization

```
1. Connect a drone not in trusted_drones.json
   ✓ GCS receives STATUSTEXT with "DRONEID: <uuid>"
   ✓ Unknown UUID → closeVehicle() + ignoreVehicleId()
   ✓ Known UUID → connection proceeds
```

---

## Android Build Notes

- OpenSSL static libraries: `libs/OpenSSL/android_openssl/static/lib/*/libcrypto.a`
- Headers: `libs/OpenSSL/android_openssl/static/include/`
- Runtime bundling: `openssl.pri` adds `.so` files to `ANDROID_EXTRA_LIBS`
- Architecture mapping:
  - `armeabi-v7a` → `arm/`
  - `arm64-v8a` → `arm64/`
  - `x86` → `x86/`
  - `x86_64` → `x86_64/`

## Security Notes

- The `master_aes.key` is embedded in the GCS binary. It should be obfuscated or stored in a secure enclave for production.
- License keys are stored in `QSettings` (plaintext hex). For production, consider encrypted storage via Qt Keychain or platform key store.
- MAVLink signing uses symmetric HMAC. The signing key is shared between GCS and drone — keep it confidential.
- ECDSA certificate verification (optional) provides asymmetric trust but requires the drone to host `/APM/scripts/fwd_license.bin`.
