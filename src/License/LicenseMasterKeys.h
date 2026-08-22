#pragma once

#include <QtCore/QByteArray>
#include <cstdint>

// ECDSA P-256 public key — embed full PEM content from Anvil team's master_public.pem
// Replace with actual key when provided
static const char* kFWDMasterPublicKeyPEM __attribute__((unused)) =
    "-----BEGIN PUBLIC KEY-----\n"
    "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n"
    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==\n"
    "-----END PUBLIC KEY-----\n";

// AES-256 key — 32 bytes from master_aes.key (Anvil team)
static const uint8_t kFWDMasterAESKey[32] = {
    0x44, 0x59, 0x74, 0x16, 0x58, 0x78, 0x8c, 0x91,
    0xf2, 0xef, 0x6f, 0x35, 0x9b, 0xa3, 0x75, 0x6e,
    0x3e, 0x11, 0x51, 0x51, 0x23, 0x8e, 0x70, 0x95,
    0xc4, 0xc3, 0x58, 0xb6, 0x4d, 0x3f, 0x94, 0x67
};
