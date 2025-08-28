--liquibase formatted sql
--changeset stamencho-bogdanovski:database-improvements

-- Make column `joined_subject.codes` to a JSONB data type
-- Add safety check to ensure column exists and has data

-- Create a table which will store device IDs of students
-- Each student can register only with one device to protect from being exploited.
CREATE TABLE IF NOT EXISTS student_device (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_student_index VARCHAR(255) NOT NULL,
    device_id VARCHAR(255) NOT NULL UNIQUE, -- Ensure device_id is unique
    device_name VARCHAR(255),
    device_os VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_student_device_student FOREIGN KEY (student_student_index) REFERENCES student (student_index) ON DELETE CASCADE
);

-- Essential indexes
CREATE INDEX IF NOT EXISTS idx_student_device_student_index ON student_device(student_student_index);
CREATE INDEX IF NOT EXISTS idx_student_device_active ON student_device(is_active) WHERE is_active = true;

--rollback DROP TABLE IF EXISTS student_device; ALTER TABLE joined_subject ALTER COLUMN codes TYPE text;
