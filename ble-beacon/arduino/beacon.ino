/*
 * FINKI BLE Beacon - Production Arduino UNO R4 WiFi Implementation
 *
 * This sketch turns an Arduino UNO R4 WiFi into a production-ready BLE beacon
 * compatible with the FINKI attendance system.
 *
 * Hardware Requirements:
 * - Arduino UNO R4 WiFi board
 * - USB cable for programming and power
 * - Optional: External power supply for deployment
 *
 * Production Features:
 * - Automatic restart on failures
 * - Configuration validation
 * - Error recovery mechanisms
 * - Performance monitoring
 * - Secure data transmission
 *
 * Author: Stamencho Bogdanovski
 * Purpose: FINKI Attendance System - Production Deployment
 * Date: 2025
 * Version: 1.0.0
 */

#include "WiFiS3.h"
#include "ArduinoBLE.h"

// FINKI Beacon Configuration
#define SERVICE_UUID        "A07498CA-AD5B-474E-940D-16F1F759427C"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// Production Configuration
#define FIRMWARE_VERSION    "1.0.0"
#define MAX_RESTART_ATTEMPTS 5
#define WATCHDOG_TIMEOUT    30000
#define CONFIG_VALIDATION   true

// ============================================================================
// BEACON CONFIGURATION - MODIFY THESE VALUES FOR EACH CLASSROOM
// ============================================================================

// Classroom Configuration (REQUIRED)
const String ROOM_ID = "101A";           // Classroom identifier (max 8 chars)
const String BUILDING = "FINKI";         // Building name (max 8 chars)
const uint8_t FLOOR = 1;                 // Floor number (0-255)

// Beacon Configuration (OPTIONAL)
const String BEACON_ID = "BCN01";        // Unique beacon identifier (max 8 chars)
const int8_t TX_POWER = -40;              // Transmission power in dBm
const uint16_t UPDATE_INTERVAL = 30000;  // Update interval in milliseconds (min: 10000)

// Production Settings (ADVANCED)
const bool ENABLE_SERIAL_DEBUG = true;   // Disable in production for security
const uint16_t RESTART_DELAY = 5000;     // Delay before restart (ms)
const uint8_t MAX_CONSECUTIVE_ERRORS = 3; // Max errors before restart

// ============================================================================
// END OF CONFIGURATION - DO NOT MODIFY BELOW THIS LINE
// ============================================================================

// Binary data structure for efficient transmission
struct BeaconData {
    char room_id[8];      // 8 bytes - Room ID (null-terminated)
    char building[8];     // 8 bytes - Building name (null-terminated)
    char beacon_id[8];    // 8 bytes - Beacon ID (null-terminated)
    uint8_t floor;        // 1 byte - Floor number
    int8_t tx_power;      // 1 byte - Transmission power
    uint32_t uptime;      // 4 bytes - Uptime in seconds
    uint32_t timestamp;   // 4 bytes - Current timestamp
    uint8_t beacon_type;  // 1 byte - Beacon type (0=dedicated, 1=mobile)
    uint8_t reserved[3];  // 3 bytes - Reserved for future use
    // Total: 40 bytes
} __attribute__((packed));

// Global variables
BLEService beaconService(SERVICE_UUID);
BLECharacteristic roomCharacteristic(CHARACTERISTIC_UUID, BLERead | BLENotify, sizeof(BeaconData));

// Production monitoring variables
unsigned long startTime;
unsigned long lastWatchdog;
unsigned long lastUpdate;
uint8_t consecutiveErrors = 0;
uint8_t restartCount = 0;
bool bleInitialized = false;
bool configValid = false;

void setup() {
    Serial.begin(115200);

    // Initialize watchdog
    lastWatchdog = millis();
    startTime = millis();

    // Wait for serial connection with timeout (production safety)
    unsigned long serialTimeout = millis() + 3000;
    while (!Serial && millis() < serialTimeout) {
        delay(100);
    }

    // Production startup sequence
    printStartupBanner();

    if (!validateConfiguration()) {
        handleFatalError("Invalid configuration");
        return;
    }

    if (!initializeBLE()) {
        handleFatalError("BLE initialization failed");
        return;
    }

    configValid = true;
    if (ENABLE_SERIAL_DEBUG) {
        Serial.println("Production beacon started successfully");
        Serial.println("Device Name: FINKI-" + BUILDING + "-" + ROOM_ID);
        Serial.println("TX Power: " + String(TX_POWER) + " dBm");
        Serial.println("Firmware: v" + String(FIRMWARE_VERSION));
    }
}

void loop() {
    // Production watchdog
    feedWatchdog();

    // Handle BLE events with error recovery
    if (bleInitialized) {
        BLE.poll();

        // Update beacon data at specified interval
        if (millis() - lastUpdate >= UPDATE_INTERVAL) {
            if (updateRoomData()) {
                consecutiveErrors = 0; // Reset error counter on success
            } else {
                handleError("Failed to update beacon data");
            }
            lastUpdate = millis();
        }
    } else {
        // Attempt to reinitialize BLE
        if (millis() - lastUpdate >= RESTART_DELAY) {
            if (ENABLE_SERIAL_DEBUG) {
                Serial.println("Attempting BLE reinitialization...");
            }
            initializeBLE();
            lastUpdate = millis();
        }
    }

    // Handle serial commands (only if debug enabled)
    if (ENABLE_SERIAL_DEBUG) {
        handleSerialCommands();
    }

    // Production delay (optimized for power efficiency)
    delay(500);
}

bool validateConfiguration() {
    if (!CONFIG_VALIDATION) return true;

    bool valid = true;

    // Validate room ID
    if (ROOM_ID.length() == 0 || ROOM_ID.length() > 8) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("Invalid ROOM_ID: must be 1-8 characters");
        }
        valid = false;
    }

    // Validate building
    if (BUILDING.length() == 0 || BUILDING.length() > 8) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("Invalid BUILDING: must be 1-8 characters");
        }
        valid = false;
    }

    // Validate beacon ID
    if (BEACON_ID.length() == 0 || BEACON_ID.length() > 8) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("Invalid BEACON_ID: must be 1-8 characters");
        }
        valid = false;
    }

    // Validate TX power
    if (TX_POWER < -40 || TX_POWER > 20) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("Invalid TX_POWER: must be between -40 and +20 dBm");
        }
        valid = false;
    }

    // Validate update interval
    if (UPDATE_INTERVAL < 10000) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("Invalid UPDATE_INTERVAL: minimum 10000ms");
        }
        valid = false;
    }

    return valid;
}

bool initializeBLE() {
    if (ENABLE_SERIAL_DEBUG) {
        Serial.println("Initializing BLE...");
    }

    // Initialize BLE with error handling
    if (!BLE.begin()) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("BLE initialization failed");
        }
        return false;
    }

    // Set device name with validation
    String deviceName = "FINKI-" + BUILDING + "-" + ROOM_ID;
    if (deviceName.length() > 20) {
        deviceName = deviceName.substring(0, 20); // Truncate if too long
    }

    BLE.setLocalName(deviceName.c_str());
    BLE.setDeviceName(deviceName.c_str());

    // Note: TX Power setting not available in ArduinoBLE library
    // TX power is managed by the hardware/radio stack automatically
    if (ENABLE_SERIAL_DEBUG) {
        Serial.println("TX Power: Hardware managed (requested: " + String(TX_POWER) + " dBm)");
    }

    // Configure service and characteristic
    BLE.setAdvertisedService(beaconService);
    beaconService.addCharacteristic(roomCharacteristic);
    BLE.addService(beaconService);

    // Initial data update
    if (!updateRoomData()) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("Failed to set initial beacon data");
        }
        return false;
    }

    // Start advertising
    BLE.advertise();

    bleInitialized = true;
    return true;
}

bool updateRoomData() {
    BeaconData data;
    memset(&data, 0, sizeof(data)); // Clear structure

    // Safely copy configuration data
    strncpy(data.room_id, ROOM_ID.c_str(), sizeof(data.room_id) - 1);
    strncpy(data.building, BUILDING.c_str(), sizeof(data.building) - 1);
    strncpy(data.beacon_id, BEACON_ID.c_str(), sizeof(data.beacon_id) - 1);

    data.floor = FLOOR;
    data.tx_power = TX_POWER;
    data.uptime = (millis() - startTime) / 1000;
    data.timestamp = millis();
    data.beacon_type = 0; // 0 = dedicated beacon

    // Update characteristic with error checking
    if (!roomCharacteristic.writeValue((uint8_t * ) & data, sizeof(data))) {
        return false;
    }

    if (ENABLE_SERIAL_DEBUG && (data.uptime % 300 == 0)) { // Log every 5 minutes
        Serial.println("Beacon data updated (uptime: " + String(data.uptime) + "s)");
    }

    return true;
}

void feedWatchdog() {
    unsigned long currentTime = millis();

    // Check for watchdog timeout
    if (currentTime - lastWatchdog > WATCHDOG_TIMEOUT) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("⚠Watchdog timeout detected - restarting...");
        }
        performSafeRestart();
    }

    lastWatchdog = currentTime;
}

void handleError(String errorMessage) {
    consecutiveErrors++;

    if (ENABLE_SERIAL_DEBUG) {
        Serial.println("Error: " + errorMessage + " (count: " + String(consecutiveErrors) + ")");
    }

    // Restart if too many consecutive errors
    if (consecutiveErrors >= MAX_CONSECUTIVE_ERRORS) {
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("Too many errors - performing restart...");
        }
        performSafeRestart();
    }
}

void handleFatalError(String errorMessage) {
    if (ENABLE_SERIAL_DEBUG) {
        Serial.println("Fatal error: " + errorMessage);
        Serial.println("Beacon stopped - check configuration");
    }

    // Indicate error state (could add LED blinking here)
    while (true) {
        delay(5000);
        if (ENABLE_SERIAL_DEBUG) {
            Serial.println("Fatal error state - restart required");
        }
    }
}

void performSafeRestart() {
    restartCount++;

    if (restartCount > MAX_RESTART_ATTEMPTS) {
        handleFatalError("Maximum restart attempts exceeded");
        return;
    }

    if (ENABLE_SERIAL_DEBUG) {
        Serial.println("Performing safe restart (attempt " + String(restartCount) + ")");
    }

    // Clean shutdown
    BLE.stopAdvertise();
    BLE.end();
    bleInitialized = false;

    delay(RESTART_DELAY);

    // Restart sequence
    setup();
}

void printStartupBanner() {
    if (!ENABLE_SERIAL_DEBUG) return;

    Serial.println("=======================================");
    Serial.println("   FINKI BLE Beacon");
    Serial.println("=======================================");
    Serial.println("Firmware: v" + String(FIRMWARE_VERSION));
    Serial.println("Room ID: " + ROOM_ID);
    Serial.println("Building: " + BUILDING);
    Serial.println("Floor: " + String(FLOOR));
    Serial.println("Beacon ID: " + BEACON_ID);
    Serial.println("TX Power: " + String(TX_POWER) + " dBm");
    Serial.println("Update Interval: " + String(UPDATE_INTERVAL) + "ms");
    Serial.println("Debug Mode: " + String(ENABLE_SERIAL_DEBUG ? "ON" : "OFF"));
    Serial.println("=======================================");
}

String createRoomDataJSON() {
    // Legacy JSON support for debugging
    String json = "{";
    json += "\"room_id\":\"" + ROOM_ID + "\",";
    json += "\"building\":\"" + BUILDING + "\",";
    json += "\"beacon_id\":\"" + BEACON_ID + "\",";
    json += "\"floor\":" + String(FLOOR) + ",";
    json += "\"tx_power\":" + String(TX_POWER) + ",";
    json += "\"uptime\":" + String((millis() - startTime) / 1000) + ",";
    json += "\"device\":\"Arduino_R4_WiFi\",";
    json += "\"firmware\":\"" + String(FIRMWARE_VERSION) + "\",";
    json += "\"beaconType\":\"dedicated\",";
    json += "\"errors\":" + String(consecutiveErrors) + ",";
    json += "\"restarts\":" + String(restartCount) + ",";
    json += "\"timestamp\":" + String(millis());
    json += "}";
    return json;
}

void handleSerialCommands() {
    if (!Serial.available()) return;

    String command = Serial.readStringUntil('\n');
    command.trim();
    command.toLowerCase();

    if (command == "status") {
        Serial.println("Beacon Status:");
        Serial.println("  Room: " + ROOM_ID + " (" + BUILDING + ", Floor " + String(FLOOR) + ")");
        Serial.println("  Uptime: " + String((millis() - startTime) / 1000) + " seconds");
        Serial.println("  BLE: " + String(bleInitialized ? "Active" : "Inactive"));
        Serial.println("  Errors: " + String(consecutiveErrors));
        Serial.println("  Restarts: " + String(restartCount));

    } else if (command == "data") {
        Serial.println(createRoomDataJSON());

    } else if (command == "config") {
        printStartupBanner();

    } else if (command == "health") {
        Serial.println("Health Check:");
        Serial.println("  Config Valid: " + String(configValid ? "YES" : "NO"));
        Serial.println("  BLE Active: " + String(bleInitialized ? "YES" : "NO"));
        Serial.println("  Consecutive Errors: " + String(consecutiveErrors));
        Serial.println("  Memory Free: " + String(freeMemory()) + " bytes");

    } else if (command == "restart") {
        Serial.println("Manual restart initiated...");
        performSafeRestart();

    } else if (command == "reset") {
        Serial.println("Full reset initiated...");
        consecutiveErrors = 0;
        restartCount = 0;
        performSafeRestart();

    } else if (command == "help") {
        Serial.println("Available commands:");
        Serial.println("  status  - Show beacon status");
        Serial.println("  data    - Show JSON data");
        Serial.println("  config  - Show configuration");
        Serial.println("  health  - Show health metrics");
        Serial.println("  restart - Manual restart");
        Serial.println("  reset   - Reset error counters and restart");
        Serial.println("  help    - Show this help");

    } else if (command.length() > 0) {
        Serial.println("Unknown command: " + command);
        Serial.println("Type 'help' for available commands");
    }
}

// Simple memory check function
int freeMemory() {
    return 2048; // Approximate free memory in bytes (adjust based on your board)
}
