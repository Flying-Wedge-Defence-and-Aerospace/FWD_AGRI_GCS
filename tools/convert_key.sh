#!/bin/bash
# Converts a hex key file into the C array format for LicenseMasterKeys.h
# Usage: ./tools/convert_key.sh /path/to/master_aes.key

KEY_FILE="${1:-master_aes.key}"

if [ ! -f "$KEY_FILE" ]; then
    echo "Usage: $0 <path/to/master_aes.key>"
    exit 1
fi

HEX=$(cat "$KEY_FILE" | tr -d ' \n\r\t')

if [ ${#HEX} -ne 64 ]; then
    echo "Error: expected 64 hex chars, got ${#HEX}"
    exit 1
fi

echo "// AES-256 key — 32 bytes from $KEY_FILE"
echo "static const uint8_t kFWDMasterAESKey[32] = {"
for i in $(seq 0 31); do
    BYTE="${HEX:$((i*2)):2}"
    if [ $((i % 8)) -eq 0 ]; then
        echo -n "    "
    fi
    echo -n "0x$BYTE"
    if [ $i -lt 31 ]; then echo -n ", "
    else echo ""
    fi
    if [ $((i % 8)) -eq 7 ] && [ $i -lt 31 ]; then echo ""; fi
done
echo "};"
