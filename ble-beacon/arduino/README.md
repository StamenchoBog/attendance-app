# FINKI BLE Beacon System - Production Deployment Guide

## Arduino Beacon (Hardware)
- **Reliability**: Watchdog timer, automatic restart on failures
- **Configuration**: Validation and production safety checks
- **Monitoring**: Health metrics, error counting, uptime tracking
- **Security**: Optional debug mode disable for production
- **Efficiency**: Optimized power consumption and memory usage

## Production Configuration

### Mobile App Configuration
```dart
// Production constants in app_constants.dart
static const Duration bluetoothScanTimeout = Duration(seconds: 30);
static const int maxRetries = 3;
static const int minRssiThreshold = -100;
static const Duration scanCooldown = Duration(milliseconds: 500);
```

### Arduino Configuration for Production
```cpp
// Set these for production deployment
const bool ENABLE_SERIAL_DEBUG = false;    // Disable for security
const uint16_t UPDATE_INTERVAL = 30000;    // 30 seconds
const int8_t TX_POWER = -4;                // Adjust per room size
const uint8_t MAX_CONSECUTIVE_ERRORS = 3;  // Error tolerance
```

## Deployment Workflow

### 1. Initial Setup
1. Configure development environment with Arduino IDE
2. Install required libraries (WiFiS3, ArduinoBLE)
3. Test beacon functionality in development mode
4. Validate data transmission with mobile app

### 2. Production Setup

#### Arduino Beacon Deployment
1. Configure each beacon for specific classroom
2. Upload production firmware with debug disabled
3. Test beacon advertising and data transmission
4. Mount securely in classroom with power supply

### 3. Configuration Management

#### Classroom-Specific Configuration
```cpp
// Room 101A - Main Lecture Hall
const String ROOM_ID = "101A";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 1;
const String BEACON_ID = "BCN01";
const int8_t TX_POWER = -4;

// Room 102 - Computer Lab
const String ROOM_ID = "102";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 1;
const String BEACON_ID = "BCN02";
const int8_t TX_POWER = -8;  // Lower for smaller room
```

### 4. Monitoring and Maintenance

#### Health Check Commands (Development/Maintenance)
```
status  - Current beacon status
health  - Health metrics and diagnostics
data    - JSON data output
restart - Manual restart beacon
reset   - Reset error counters
```

#### Production Monitoring
- Monitor beacon uptime and error rates
- Check mobile app crash reports
- Validate attendance data accuracy
- Monitor server API performance

## Security Considerations

### Arduino Security
- ✅ Serial debug disabled in production
- ✅ Configuration validation prevents invalid settings
- ✅ No sensitive data in beacon transmissions
- ✅ Secure mounting to prevent tampering

## Performance Optimization

### Arduino Performance
- **Power Efficiency**: Optimized delays and update intervals
- **Memory Management**: Efficient data structures and cleanup
- **Reliability**: Watchdog timer prevents system hangs
- **Error Recovery**: Automatic restart on persistent errors

## Troubleshooting Guide

### Diagnostic Commands
```cpp
health  // Check beacon health status
status  // View current operational status
config  // Display configuration settings
data    // Output beacon data in JSON format
restart // Manual restart beacon
reset   // Reset error counters
```
- Maintain backup configurations for quick redeployment
- Create configuration templates for different room types

### 2. Update Procedures
- Test firmware updates in development environment first
- Plan maintenance windows for beacon updates
- Keep rollback firmware ready for critical issues

### 3. Monitoring
- Set up automated health checks for beacons
- Monitor mobile app analytics and crash reports
- Track attendance system accuracy and performance

### 4. Documentation
- Maintain deployment logs with beacon locations
- Document any configuration changes or issues
- Keep network diagrams and installation photos

## Hardware Specifications

### Arduino UNO R4 WiFi Requirements
- **Microcontroller**: Renesas RA4M1 (ARM Cortex-M4)
- [ ] Quarterly configuration audits
- [ ] Semester deployment reviews
- [ ] Annual hardware inspection

### Emergency Procedures
1. **Beacon Failure**: Use backup beacon or manual attendance
2. **App Issues**: Distribute hotfix or rollback to previous version
3. **Server Issues**: Check API connectivity and failover procedures
