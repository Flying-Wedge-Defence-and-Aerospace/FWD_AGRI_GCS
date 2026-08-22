#!/bin/bash
# Test timestamp persistence by inspecting QSettings before and after
set -e

QSETTINGS_FILE="$HOME/.config/FWDAgriGCS/FWDAgriGCS.conf"

echo "=== Timestamp Persistence Test ==="
echo "QSettings file: $QSETTINGS_FILE"
echo ""

# Check current state
if [ -f "$QSETTINGS_FILE" ]; then
    echo "Current FWDLicenses in QSettings:"
    grep -A2 "FWDLicenses" "$QSETTINGS_FILE" | head -30 || echo "(none found)"
else
    echo "QSettings file not yet created. Run GCS with license activation first."
fi

echo ""
echo "=== What to verify ==="
echo "1. After license activation, run: grep 'FWDLicenses' $HOME/.config/FWDAgriGCS/FWDAgriGCS.conf"
echo "   Expected: board UID with ts=NNNNNN under it"
echo ""
echo "2. Restart GCS, check signing status text shows persisted timestamp"
echo ""
echo "3. Run test_signing.py to verify full flow:"
echo "   python3 test_signing.py"
