#!/usr/bin/env python3
"""
Simulate a drone sending DRONEID via STATUSTEXT to test GCS authorization.
Run this FIRST, then connect QGC via UDP to 127.0.0.1:14550
"""
import sys
import time
import socket
from pymavlink import mavutil

drone_uuid = sys.argv[1] if len(sys.argv) > 1 else "550e8400-e29b-41d4-a716-446655440000"
reject_test = '--reject' in sys.argv

if reject_test:
    drone_uuid = "00000000-0000-0000-0000-000000000000"
    print(f"Testing REJECTION — UUID: {drone_uuid}")
else:
    print(f"Testing AUTHORISATION — UUID: {drone_uuid}")

# Connect to QGC's UDP port (default 14550)
master = mavutil.mavlink_connection('udpout:127.0.0.1:14550', source_system=1, source_component=1)

print("Sending HEARTBEAT...")
master.mav.heartbeat_send(
    mavutil.mavlink.MAV_TYPE_QUADROTOR,
    mavutil.mavlink.MAV_AUTOPILOT_ARDUPILOTMEGA,
    0, 0, 0
)
time.sleep(1)

msg = f"DRONEID:{drone_uuid}"
print(f"Sending STATUSTEXT: '{msg}'")
master.mav.statustext_send(
    mavutil.mavlink.MAV_SEVERITY_INFO,
    msg.encode('utf-8')
)

print("Done. Check QGC console for DRONEID: messages.")
