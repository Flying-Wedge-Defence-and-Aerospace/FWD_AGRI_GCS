#!/usr/bin/env python3
"""
Test MAVLink signing with a real license key.

1. Encrypts a known board UID + signing key with master AES key
2. Sends the resulting license as base64url to the GCS
3. The GCS decrypts, validates UID, stores key, enables signing
4. Then connects a signed MAVLink client to verify signing works

Usage:
    python3 test_signing.py [license_string]

Without license_string, generates a test license for UID 35001A001851313334373032
"""
import sys
import os
import time
import base64
import struct
from pymavlink import mavutil

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

# The same master AES key embedded in the GCS binary
MASTER_AES_KEY_HEX = "4459741658788c91f2ef6f359ba3756e3e115151238e7095c4c358b64d3f9467"
MASTER_AES_KEY = bytes.fromhex(MASTER_AES_KEY_HEX)

TEST_BOARD_UID = "35001A001851313334373032"
TEST_SIGNING_KEY = bytes(range(32))  # 0x00..0x1f — 32 bytes

def generate_test_license(board_uid_hex: str, signing_key: bytes) -> str:
    """Generate a 96-char base64url license string (no padding)."""
    plaintext = bytes.fromhex(board_uid_hex) + signing_key  # 12 + 32 = 44 bytes
    aesgcm = AESGCM(MASTER_AES_KEY)
    nonce = b'\x00' * 12  # fixed nonce for testing only!
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    # ciphertext = nonce[12] + cipher[44] + tag[16] = 72 bytes
    raw = nonce + ciphertext
    return base64.urlsafe_b64encode(raw).rstrip(b'=').decode()

def connect_signed(master_aes_key_hex: str, license_str: str, port: str = 'udpout:127.0.0.1:14550'):
    """Connect with signing enabled using the license key."""
    aes_key = bytes.fromhex(master_aes_key_hex)
    padding = "=" * (4 - len(license_str) % 4) if len(license_str) % 4 else ""
    raw = base64.urlsafe_b64decode(license_str + padding)

    nonce = raw[0:12]
    ciphertext_tag = raw[12:]
    aesgcm = AESGCM(aes_key)
    plaintext = aesgcm.decrypt(nonce, ciphertext_tag, None)
    board_uid = plaintext[0:12].hex().upper()
    signing_key = plaintext[12:44]

    print(f"License decrypted: board UID = {board_uid}")
    print(f"Signing key       = {signing_key.hex()}")

    mav = mavutil.mavlink_connection(port, source_system=1, source_component=1)
    mav.setup_signing(signing_key, sign_outgoing=True, allow_unsigned_callback=None)

    print("Sending signed HEARTBEAT...")
    mav.mav.heartbeat_send(
        mavutil.mavlink.MAV_TYPE_QUADROTOR,
        mavutil.mavlink.MAV_AUTOPILOT_ARDUPILOTMEGA,
        0, 0, 0
    )
    time.sleep(2)
    print("Signed heartbeat sent. Check GCS for signing status.")
    return mav, board_uid, signing_key

def connect_unsigned(port: str = 'udpout:127.0.0.1:14550'):
    """Connect WITHOUT signing — should be rejected by GCS when enforcement is on."""
    mav = mavutil.mavlink_connection(port, source_system=2, source_component=1)
    print("Sending unsigned HEARTBEAT (should be rejected when enforcement active)...")
    mav.mav.heartbeat_send(
        mavutil.mavlink.MAV_TYPE_QUADROTOR,
        mavutil.mavlink.MAV_AUTOPILOT_ARDUPILOTMEGA,
        0, 0, 0
    )
    time.sleep(2)
    print("Unsigned heartbeat sent.")
    return mav

if __name__ == '__main__':
    if len(sys.argv) > 1:
        license_str = sys.argv[1]
    else:
        license_str = generate_test_license(TEST_BOARD_UID, TEST_SIGNING_KEY)
        print(f"Generated test license: {license_str}")

    print(f"\nLicense string ({len(license_str)} chars): {license_str}\n")

    # Step 1: Connect with signing
    mav, uid, key = connect_signed(MASTER_AES_KEY_HEX, license_str)

    # Step 2: Optionally test unsigned rejection
    if '--test-reject' in sys.argv:
        print("\n--- Testing unsigned rejection ---")
        mav2 = connect_unsigned()
        mav2.close()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nClosing...")
        mav.close()
