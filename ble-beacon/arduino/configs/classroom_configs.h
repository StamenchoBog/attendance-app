/*
 * FINKI Beacon Classroom Configurations
 *
 * This file contains predefined configurations for different classrooms.
 * Copy the desired configuration to the main beacon.ino file.
 */

#ifndef CLASSROOM_CONFIGS_H
#define CLASSROOM_CONFIGS_H

// ============================================================================
// CLASSROOM 101A - Main Lecture Hall
// ============================================================================
/*
const String ROOM_ID = "101A";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 1;
const String BEACON_ID = "BCN01";
const int8_t TX_POWER = -4;
const uint16_t UPDATE_INTERVAL = 30000;
*/

// ============================================================================
// CLASSROOM 102 - Computer Lab 1
// ============================================================================
/*
const String ROOM_ID = "102";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 1;
const String BEACON_ID = "BCN02";
const int8_t TX_POWER = -8;  // Lower power for smaller room
const uint16_t UPDATE_INTERVAL = 30000;
*/

// ============================================================================
// CLASSROOM 201A - Upper Floor Lecture Hall
// ============================================================================
/*
const String ROOM_ID = "201A";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 2;
const String BEACON_ID = "BCN03";
const int8_t TX_POWER = -4;
const uint16_t UPDATE_INTERVAL = 30000;
*/

// ============================================================================
// CLASSROOM 202 - Computer Lab 2
// ============================================================================
/*
const String ROOM_ID = "202";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 2;
const String BEACON_ID = "BCN04";
const int8_t TX_POWER = -8;  // Lower power for smaller room
const uint16_t UPDATE_INTERVAL = 30000;
*/

// ============================================================================
// CLASSROOM 301 - Seminar Room
// ============================================================================
/*
const String ROOM_ID = "301";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 3;
const String BEACON_ID = "BCN05";
const int8_t TX_POWER = -12; // Very low power for small seminar room
const uint16_t UPDATE_INTERVAL = 30000;
*/

// ============================================================================
// AMPHITHEATER - Large Lecture Hall
// ============================================================================
/*
const String ROOM_ID = "AMPH";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 0;
const String BEACON_ID = "BCN06";
const int8_t TX_POWER = 0;   // High power for large amphitheater
const uint16_t UPDATE_INTERVAL = 30000;
*/

// ============================================================================
// LIBRARY - Study Area
// ============================================================================
/*
const String ROOM_ID = "LIB";
const String BUILDING = "FINKI";
const uint8_t FLOOR = 1;
const String BEACON_ID = "BCN07";
const int8_t TX_POWER = -8;
const uint16_t UPDATE_INTERVAL = 60000;  // Less frequent updates
*/

#endif // CLASSROOM_CONFIGS_H
