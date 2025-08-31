# Bluetooth LE Beacon

Bluetooth Low Energy beacon component for proximity verification in the FINKI Attendance Application.

## 🎯 Overview

This component broadcasts a specific Bluetooth Low Energy (BLE) signal that serves as a proximity verification mechanism for the attendance system. When students scan QR codes for attendance, their mobile devices must detect this beacon signal to confirm they are physically present in the classroom.

## 🛠 Technologies & Hardware

### Software Requirements
- **Python**: 3.7 or higher
- **BlueZ**: Linux Bluetooth stack (Linux only)
- **Operating System**: Linux (recommended), macOS, Windows (with limitations)

### Hardware Requirements
- **Bluetooth 4.0+**: BLE-capable hardware
- **Recommended Devices**:
  - Raspberry Pi 3/4 with built-in Bluetooth
  - ESP32 development boards
  - Dedicated BLE beacon hardware
  - USB Bluetooth dongles (BLE compatible)

### Python Dependencies
```
bleak>=0.20.0           # Cross-platform BLE library
asyncio                 # Asynchronous programming
logging                 # Logging functionality
```

## 🚀 Getting Started

### Prerequisites

**For Raspberry Pi (Recommended)**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and pip
sudo apt install python3 python3-pip -y

# Install BlueZ (if not already installed)
sudo apt install bluez bluez-tools -y

# Install system dependencies
sudo apt install libbluetooth-dev -y
```

**For Ubuntu/Debian**
```bash
sudo apt install bluetooth bluez bluez-tools
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
```

### Installation

1. **Navigate to Beacon Directory**
   ```bash
   cd ble-beacon
   ```

2. **Create Virtual Environment** (Recommended)
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # Linux/macOS
   # or
   venv\Scripts\activate     # Windows
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Verify Bluetooth Hardware**
   ```bash
   # Check Bluetooth adapter
   hciconfig
   
   # Should show something like:
   # hci0: Type: Primary  Bus: USB
   #       BD Address: XX:XX:XX:XX:XX:XX  ACL MTU: 1021:8  SCO MTU: 64:1
   #       UP RUNNING
   ```

## 📁 Project Structure

```
blt-beacon/
├── beacon.py              # Main beacon implementation
├── config.py              # Configuration settings
├── requirements.txt       # Python dependencies
├── README.md              # This file
├── scripts/               # Utility scripts
│   ├── setup_bluetooth.sh
│   └── test_beacon.sh
└── logs/                  # Application logs
    └── beacon.log
```

## ⚙️ Configuration

### Beacon Parameters

The beacon broadcasts with these specific parameters:

```python
# config.py
BEACON_CONFIG = {
    # Service UUID (must match mobile app)
    'SERVICE_UUID': 'A07498CA-AD5B-474E-940D-16F1F759427C',
    
    # Advertising interval (milliseconds)
    'ADVERTISING_INTERVAL': 100,  # 100ms
    
    # Transmission power (dBm)
    'TX_POWER': 0,  # 0 dBm (adjust based on room size)
    
    # Device name
    'DEVICE_NAME': 'FINKI-Classroom-Beacon',
    
    # Major and Minor values (for iBeacon compatibility)
    'MAJOR': 1,
    'MINOR': 1
}
```

### Room-Specific Configuration

For multiple classrooms, create room-specific configurations:

```python
# Room configurations
ROOM_CONFIGS = {
    'room_101': {
        'SERVICE_UUID': 'A07498CA-AD5B-474E-940D-16F1F759427C',
        'MAJOR': 1,
        'MINOR': 101,
        'DEVICE_NAME': 'FINKI-Room-101'
    },
    'room_102': {
        'SERVICE_UUID': 'A07498CA-AD5B-474E-940D-16F1F759427C',
        'MAJOR': 1,
        'MINOR': 102,
        'DEVICE_NAME': 'FINKI-Room-102'
    }
}
```

## 🏃‍♂️ Running the Beacon

### Basic Usage

```bash
# Start beacon with default configuration
python beacon.py

# Start beacon for specific room
python beacon.py --room room_101

# Start with custom power level
python beacon.py --tx-power -4

# Start in debug mode
python beacon.py --debug
```

### Command Line Options

```bash
usage: beacon.py [-h] [--room ROOM] [--tx-power TX_POWER] [--interval INTERVAL] [--debug]

options:
  -h, --help           Show help message
  --room ROOM          Specify room configuration
  --tx-power TX_POWER  Set transmission power (-20 to +4 dBm)
  --interval INTERVAL  Set advertising interval (20-10240 ms)
  --debug              Enable debug logging
```

### Running as System Service

Create a systemd service for automatic startup:

```bash
# Create service file
sudo nano /etc/systemd/system/finki-beacon.service
```

```ini
[Unit]
Description=FINKI Attendance Beacon
After=bluetooth.service
Requires=bluetooth.service

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/attendance-app/blt-beacon
Environment=PATH=/home/pi/attendance-app/blt-beacon/venv/bin
ExecStart=/home/pi/attendance-app/blt-beacon/venv/bin/python beacon.py --room room_101
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start service
sudo systemctl enable finki-beacon.service
sudo systemctl start finki-beacon.service

# Check status
sudo systemctl status finki-beacon.service
```

## 🔧 Hardware Setup

### Raspberry Pi Setup

1. **Enable Bluetooth**
   ```bash
   # Edit config file
   sudo nano /boot/config.txt
   
   # Add or ensure these lines exist:
   dtparam=i2c_arm=on
   dtparam=spi=on
   enable_uart=1
   dtoverlay=disable-bt  # Optional: if using external BLE dongle
   ```

2. **Configure Bluetooth Service**
   ```bash
   # Edit Bluetooth service
   sudo nano /etc/systemd/system/dbus-org.bluez.service
   
   # Modify ExecStart line:
   ExecStart=/usr/lib/bluetooth/bluetoothd --experimental
   ```

3. **Set Permissions**
   ```bash
   # Add user to bluetooth group
   sudo usermod -a -G bluetooth $USER
   
   # Set capabilities for Python (if needed)
   sudo setcap cap_net_raw+ep $(which python3)
   ```

### ESP32 Setup (Alternative)

For ESP32-based beacons, use Arduino IDE or PlatformIO:

```cpp
#include "BLEDevice.h"
#include "BLEServer.h"
#include "BLEUtils.h"
#include "BLE2902.h"

#define SERVICE_UUID "A07498CA-AD5B-474E-940D-16F1F759427C"

void setup() {
  Serial.begin(115200);
  
  BLEDevice::init("FINKI-Classroom-Beacon");
  BLEServer* pServer = BLEDevice::createServer();
  
  BLEService* pService = pServer->createService(SERVICE_UUID);
  
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  
  BLEDevice::startAdvertising();
  Serial.println("Beacon started advertising");
}

void loop() {
  delay(2000);
}
```

## 📡 Signal Characteristics

### RSSI Distance Mapping

The mobile app uses RSSI (Received Signal Strength Indicator) values to determine proximity:

| Distance | RSSI Range | Status |
|----------|------------|--------|
| 0-2m     | -40 to -55 dBm | NEAR |
| 2-5m     | -55 to -70 dBm | MEDIUM |
| 5m+      | -70+ dBm | FAR |

### Factors Affecting Signal Strength

- **Physical obstacles**: Walls, furniture, people
- **Interference**: Other 2.4GHz devices (WiFi, microwaves)
- **Antenna orientation**: Device positioning matters
- **Battery level**: Low power affects transmission strength
- **Environmental conditions**: Temperature, humidity

## 🔍 Testing & Validation

### Testing Beacon Functionality

```bash
# Test script to verify beacon is broadcasting
python scripts/test_beacon.sh

# Use Android/iOS apps for testing:
# - nRF Connect (Nordic Semiconductor)
# - Bluetooth Scanner
# - LightBlue Explorer
```

### Mobile App Testing

The mobile app should detect the beacon with these characteristics:
- **Service UUID**: A07498CA-AD5B-474E-940D-16F1F759427C
- **Device Name**: FINKI-Classroom-Beacon
- **Signal Strength**: Variable based on distance

### Range Testing

```bash
# Test signal range at different distances
python beacon.py --debug

# In another terminal or device, monitor RSSI:
sudo hcitool lescan
sudo bluetoothctl
```

## 🐛 Troubleshooting

### Common Issues

**Bluetooth Not Available**
```bash
# Check Bluetooth status
sudo systemctl status bluetooth

# Restart Bluetooth service
sudo systemctl restart bluetooth

# Check hardware
lsusb | grep -i bluetooth
```

**Permission Denied**
```bash
# Fix common permission issues
sudo chmod +x /usr/bin/bluetoothctl
sudo usermod -a -G bluetooth $USER

# Logout and login again
```

**Beacon Not Detected**
```bash
# Check if beacon is advertising
sudo hcitool lescan

# Monitor advertising packets
sudo btmon
```

**Range Issues**
- Check antenna connection
- Adjust transmission power
- Remove physical obstacles
- Check for interference sources

### Debug Mode

Enable detailed logging:

```bash
# Run with maximum verbosity
python beacon.py --debug

# Check logs
tail -f logs/beacon.log
```

## 🔒 Security Considerations

### Signal Security
- **UUID Protection**: Use organization-specific UUIDs
- **Signal Encryption**: Consider additional encryption layers
- **Range Limitation**: Configure appropriate transmission power
- **Spoofing Prevention**: Implement additional verification in mobile app

### Physical Security
- **Device Protection**: Secure hardware from tampering
- **Access Control**: Limit physical access to beacon devices
- **Monitoring**: Log all beacon activities
- **Backup Power**: Use UPS for continuous operation

## ⚡ Performance Optimization

### Power Management
```python
# Optimize for battery-powered devices
POWER_OPTIMIZED_CONFIG = {
    'ADVERTISING_INTERVAL': 200,  # Longer interval saves power
    'TX_POWER': -12,              # Lower power for battery life
    'SLEEP_MODE': True            # Enable sleep between advertisements
}
```

### Network Optimization
- **Advertising Interval**: Balance detection speed vs. power consumption
- **Transmission Power**: Optimize for room size
- **Packet Size**: Minimize advertisement payload

## 📊 Monitoring & Maintenance

### Health Monitoring
```bash
# Create monitoring script
#!/bin/bash
# check_beacon_health.sh

if pgrep -f "beacon.py" > /dev/null; then
    echo "Beacon is running"
    # Check Bluetooth status
    if hciconfig hci0 | grep -q "UP RUNNING"; then
        echo "Bluetooth adapter is active"
        exit 0
    else
        echo "Bluetooth adapter is down"
        exit 1
    fi
else
    echo "Beacon process not found"
    exit 1
fi
```

### Log Rotation
```bash
# Setup logrotate for beacon logs
sudo nano /etc/logrotate.d/finki-beacon

/home/pi/attendance-app/ble-beacon/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 pi pi
}
```

## 🔄 Deployment Strategies

### Single Room Deployment
- One beacon per classroom
- Fixed configuration
- Hardcoded room identifier

### Multi-Room Deployment
- Central configuration management
- Room-specific parameters
- Remote monitoring capabilities

### Scalable Infrastructure
```bash
# Deploy script for multiple rooms
#!/bin/bash
for room in 101 102 103 104; do
    ssh pi@beacon-room-$room "cd /home/pi/attendance-app/blt-beacon && python beacon.py --room room_$room"
done
```

## 📚 Additional Resources

- [Bluetooth LE Specification](https://www.bluetooth.com/specifications/bluetooth-core-specification/)
- [Bleak Documentation](https://bleak.readthedocs.io/)
- [Raspberry Pi Bluetooth Guide](https://www.raspberrypi.org/documentation/configuration/bluetooth.md)
- [ESP32 BLE Arduino Library](https://github.com/espressif/arduino-esp32/tree/master/libraries/BLE)
- [Nordic nRF Connect](https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-mobile) - Testing tool
