--liquibase formatted sql
--changeset stamencho-bogdanovski:ble-beacon-proximity-verification

CREATE TABLE IF NOT EXISTS proximity_verification_log (
    id BIGSERIAL PRIMARY KEY,
    student_index VARCHAR(255) NOT NULL,
    beacon_device_id VARCHAR(255),
    detected_room_id VARCHAR(255),
    expected_room_id VARCHAR(255),
    rssi INTEGER,
    proximity_level VARCHAR(20) CHECK (proximity_level IN ('NEAR', 'MEDIUM', 'FAR', 'OUT_OF_RANGE')),
    estimated_distance DECIMAL(5,2),
    verification_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verification_status VARCHAR(20) CHECK (verification_status IN ('PENDING', 'VERIFIED', 'FAILED', 'TIMEOUT')),
    beacon_type VARCHAR(30) CHECK (beacon_type IN ('DEDICATED', 'PROFESSOR_PHONE')),
    session_token VARCHAR(255)
);

-- Essential indexes only
CREATE INDEX IF NOT EXISTS idx_proximity_log_student_index ON proximity_verification_log(student_index);
CREATE INDEX IF NOT EXISTS idx_proximity_log_verification_timestamp ON proximity_verification_log(verification_timestamp);
