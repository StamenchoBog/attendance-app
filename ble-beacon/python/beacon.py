#!/usr/bin/env python3
"""
FINKI Linux Beacon - Production BLE beacon for Linux devices
Designed for deployment on Raspberry Pi or other Linux devices in classrooms.
"""

import asyncio
import argparse
import signal
import sys
import time
import json
import subprocess
import logging
from typing import Optional, Dict, Any
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/finki-beacon.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class FINKILinuxBeacon:
    """Production FINKI beacon for Linux devices using BlueZ tools"""

    # FINKI Beacon Service UUID
    SERVICE_UUID = "A07498CA-AD5B-474E-940D-16F1F759427C"

    # Advertisement configuration
    ADV_INTERVAL_MIN = 100  # 62.5ms units (100 = 62.5ms)
    ADV_INTERVAL_MAX = 200  # 62.5ms units (200 = 125ms)
    ADV_TYPE = 0  # Connectable undirected advertising

    def __init__(self, room_id: str, building: str = "FINKI", floor: int = 1,
                 tx_power: int = 0, hci_device: str = "hci0"):
        """
        Initialize FINKI Linux Beacon

        Args:
            room_id: Classroom identifier
            building: Building name
            floor: Floor number
            tx_power: TX power level (-127 to +20 dBm)
            hci_device: HCI device to use (default: hci0)
        """
        self.room_id = room_id
        self.building = building
        self.floor = floor
        self.tx_power = tx_power
        self.hci_device = hci_device
        self.is_running = False
        self.start_time = time.time()

        # Validate room ID
        if len(room_id) > 16:
            raise ValueError("Room ID must be 16 characters or less")

        logger.info(f"Initializing FINKI beacon for room {room_id}")

    async def start(self):
        """Start the beacon advertising"""
        try:
            logger.info(f"Starting FINKI beacon for {self.building} - Room {self.room_id}")
            logger.info(f"Service UUID: {self.SERVICE_UUID}")
            logger.info(f"HCI Device: {self.hci_device}")

            # Check prerequisites
            self._check_prerequisites()

            # Setup bluetooth adapter
            await self._setup_bluetooth_adapter()

            # Configure advertising
            await self._configure_advertising()

            # Start advertising
            await self._start_advertising()

            self.is_running = True
            logger.info("✅ FINKI beacon started successfully")

            # Keep running and log status
            await self._run_beacon_loop()

        except Exception as e:
            logger.error(f"Failed to start beacon: {e}")
            raise

    async def stop(self):
        """Stop the beacon advertising"""
        try:
            logger.info("Stopping FINKI beacon...")
            self.is_running = False

            # Disable advertising
            await self._run_hci_command("0x08", "0x000a", "00")  # LE Set Advertise Enable: Disable

            # Reset adapter
            await self._run_subprocess(["hciconfig", self.hci_device, "reset"])

            logger.info("🛑 FINKI beacon stopped")

        except Exception as e:
            logger.error(f"Error stopping beacon: {e}")

    def _check_prerequisites(self):
        """Check if all prerequisites are met"""
        import os

        # Check if running as root
        if os.geteuid() != 0:
            raise PermissionError(
                "Root privileges required for BLE advertising. "
                "Run with: sudo python3 beacon.py --room-id YOUR_ROOM"
            )

        # Check if bluetooth tools are available
        try:
            subprocess.run(["which", "hciconfig"], check=True, capture_output=True)
            subprocess.run(["which", "hcitool"], check=True, capture_output=True)
        except subprocess.CalledProcessError:
            raise RuntimeError(
                "Bluetooth tools not found. Install with: "
                "sudo apt-get install bluez bluez-tools"
            )

        # Check if HCI device exists
        try:
            result = subprocess.run(
                ["hciconfig", self.hci_device],
                check=True, capture_output=True, text=True
            )
            if "DOWN" in result.stdout:
                logger.warning(f"HCI device {self.hci_device} is down, will attempt to bring up")
        except subprocess.CalledProcessError:
            raise RuntimeError(f"HCI device {self.hci_device} not found")

    async def _setup_bluetooth_adapter(self):
        """Setup and configure the Bluetooth adapter"""
        logger.info("Setting up Bluetooth adapter...")

        # Bring adapter down and up to reset
        await self._run_subprocess(["hciconfig", self.hci_device, "down"])
        await self._run_subprocess(["hciconfig", self.hci_device, "up"])

        # Configure adapter for LE advertising
        await self._run_subprocess(["hciconfig", self.hci_device, "leadv", "3"])
        await self._run_subprocess(["hciconfig", self.hci_device, "noscan"])

        logger.info("Bluetooth adapter configured")

    async def _configure_advertising(self):
        """Configure BLE advertising parameters and data"""
        logger.info("Configuring BLE advertising...")

        # Set advertising parameters
        # HCI_LE_Set_Advertising_Parameters command
        await self._run_hci_command(
            "0x08", "0x0006",  # OGF=0x08, OCF=0x0006
            f"{self.ADV_INTERVAL_MIN:04x}"[:2], f"{self.ADV_INTERVAL_MIN:04x}"[2:],  # Min interval
            f"{self.ADV_INTERVAL_MAX:04x}"[:2], f"{self.ADV_INTERVAL_MAX:04x}"[2:],  # Max interval
            f"{self.ADV_TYPE:02x}",  # Advertising type
            "00",  # Own address type (public)
            "00",  # Direct address type
            "00", "00", "00", "00", "00", "00",  # Direct address
            "07",  # Advertising channel map (all channels)
            "00"   # Advertising filter policy
        )

        # Set advertising data
        adv_data = self._create_advertising_data()
        adv_data_hex = adv_data.hex()

        # Prepare advertising data command
        adv_length = len(adv_data)
        adv_command = ["0x08", "0x0008", f"{adv_length:02x}"]  # OGF, OCF, length

        # Add data bytes
        for i in range(0, len(adv_data_hex), 2):
            adv_command.append(adv_data_hex[i:i+2])

        # Pad to 31 bytes if needed
        while len(adv_command) - 3 < 31:
            adv_command.append("00")

        await self._run_hci_command(*adv_command)

        # Set scan response data (empty)
        await self._run_hci_command("0x08", "0x0009", "00")

        logger.info("BLE advertising configured")

    def _create_advertising_data(self) -> bytes:
        """Create BLE advertising data packet"""
        adv_data = bytearray()

        # Flags (LE General Discoverable, BR/EDR not supported)
        adv_data.extend([0x02, 0x01, 0x06])

        # Complete list of 128-bit service UUIDs
        service_uuid_bytes = bytes.fromhex(self.SERVICE_UUID.replace('-', ''))
        adv_data.extend([0x11, 0x07])  # Length=17, Type=Complete 128-bit UUIDs
        adv_data.extend(reversed(service_uuid_bytes))  # UUID in little-endian

        # Manufacturer data (Apple company ID for compatibility)
        room_id_bytes = self.room_id.encode('utf-8')[:16].ljust(16, b'\x00')
        building_bytes = self.building.encode('utf-8')[:8].ljust(8, b'\x00')

        manufacturer_data = bytearray([
            0x4C, 0x00,  # Apple company ID
            0x02, 0x15,  # iBeacon type
        ])
        manufacturer_data.extend(room_id_bytes)
        manufacturer_data.extend(building_bytes[:4])  # Limit building to 4 bytes for space
        manufacturer_data.extend([self.floor & 0xFF, self.tx_power & 0xFF])

        # Add manufacturer data to advertising packet
        mfg_length = len(manufacturer_data)
        adv_data.extend([mfg_length + 1, 0xFF])  # Length + type
        adv_data.extend(manufacturer_data)

        logger.debug(f"Advertising data created: {adv_data.hex()}")
        return bytes(adv_data)

    async def _start_advertising(self):
        """Start BLE advertising"""
        logger.info("Starting BLE advertising...")

        # Enable advertising
        await self._run_hci_command("0x08", "0x000a", "01")  # LE Set Advertise Enable: Enable

        logger.info("BLE advertising started")

    async def _run_beacon_loop(self):
        """Main beacon loop - runs while beacon is active"""
        status_interval = 300  # Log status every 5 minutes
        last_status_time = time.time()

        while self.is_running:
            current_time = time.time()

            # Log status periodically
            if current_time - last_status_time >= status_interval:
                uptime = current_time - self.start_time
                hours = int(uptime // 3600)
                minutes = int((uptime % 3600) // 60)

                logger.info(f"📶 Beacon active | Room: {self.room_id} | "
                           f"Uptime: {hours:02d}:{minutes:02d}")

                # Check if advertising is still active
                try:
                    result = await self._run_subprocess(
                        ["hciconfig", self.hci_device], capture_output=True, text=True
                    )
                    if "ADVERTISE" not in result.stdout:
                        logger.warning("Advertising seems to have stopped, restarting...")
                        await self._start_advertising()
                except Exception as e:
                    logger.error(f"Error checking advertising status: {e}")

                last_status_time = current_time

            await asyncio.sleep(30)  # Check every 30 seconds

    async def _run_subprocess(self, command, **kwargs):
        """Run subprocess command asynchronously"""
        logger.debug(f"Running command: {' '.join(command)}")

        process = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            **kwargs
        )

        stdout, stderr = await process.communicate()

        if process.returncode != 0:
            error_msg = stderr.decode() if stderr else "Unknown error"
            raise subprocess.CalledProcessError(
                process.returncode, command, stdout, stderr
            )

        return subprocess.CompletedProcess(
            command, process.returncode, stdout, stderr
        )

    async def _run_hci_command(self, *args):
        """Run HCI command using hcitool"""
        command = ["hcitool", "-i", self.hci_device, "cmd"] + list(args)
        await self._run_subprocess(command)

    def get_status(self) -> Dict[str, Any]:
        """Get current beacon status"""
        uptime = time.time() - self.start_time if self.is_running else 0

        return {
            "room_id": self.room_id,
            "building": self.building,
            "floor": self.floor,
            "service_uuid": self.SERVICE_UUID,
            "hci_device": self.hci_device,
            "tx_power": self.tx_power,
            "is_running": self.is_running,
            "uptime_seconds": uptime,
            "start_time": self.start_time
        }

async def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="FINKI Linux Beacon")
    parser.add_argument("--room-id", required=True, help="Classroom identifier (max 16 chars)")
    parser.add_argument("--building", default="FINKI", help="Building name (max 8 chars)")
    parser.add_argument("--floor", type=int, default=1, help="Floor number")
    parser.add_argument("--tx-power", type=int, default=0, help="TX power level (-127 to +20 dBm)")
    parser.add_argument("--hci-device", default="hci0", help="HCI device to use")
    parser.add_argument("--daemon", action="store_true", help="Run as daemon")
    parser.add_argument("--status", action="store_true", help="Show beacon status and exit")

    args = parser.parse_args()

    # Validate arguments
    if len(args.room_id) > 16:
        logger.error("Room ID must be 16 characters or less")
        sys.exit(1)

    if len(args.building) > 8:
        logger.error("Building name must be 8 characters or less")
        sys.exit(1)

    if not (-127 <= args.tx_power <= 20):
        logger.error("TX power must be between -127 and +20 dBm")
        sys.exit(1)

    # Create beacon instance
    beacon = FINKILinuxBeacon(
        room_id=args.room_id,
        building=args.building,
        floor=args.floor,
        tx_power=args.tx_power,
        hci_device=args.hci_device
    )

    # Handle status request
    if args.status:
        status = beacon.get_status()
        print(json.dumps(status, indent=2))
        return

    # Setup signal handlers for graceful shutdown
    def signal_handler(signum, frame):
        logger.info(f"Received signal {signum}, shutting down...")
        asyncio.create_task(beacon.stop())

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    try:
        # Run as daemon if requested
        if args.daemon:
            import daemon
            with daemon.DaemonContext():
                await beacon.start()
        else:
            await beacon.start()

    except KeyboardInterrupt:
        logger.info("Beacon stopped by user")
    except Exception as e:
        logger.error(f"Beacon failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except Exception as e:
        logger.error(f"Failed to start beacon: {e}")
        sys.exit(1)
