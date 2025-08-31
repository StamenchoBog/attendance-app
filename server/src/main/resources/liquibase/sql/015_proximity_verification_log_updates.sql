--liquibase formatted sql
--changeset proximity-verification-log-updates:1

-- Add missing columns to proximity_verification_log table
ALTER TABLE proximity_verification_log
ADD COLUMN IF NOT EXISTS student_attendance_id INTEGER,
ADD COLUMN IF NOT EXISTS verification_duration_seconds INTEGER;

-- Update the verification_status constraint to include new enum values
ALTER TABLE proximity_verification_log
DROP CONSTRAINT IF EXISTS proximity_verification_log_verification_status_check;

ALTER TABLE proximity_verification_log
ADD CONSTRAINT proximity_verification_log_verification_status_check
CHECK (verification_status IN ('SUCCESS', 'SUCCESS_LOW_CONFIDENCE', 'FAILED', 'TIMEOUT', 'WRONG_ROOM', 'OUT_OF_RANGE', 'ONGOING'));

-- Add foreign key constraint for student_attendance_id
ALTER TABLE proximity_verification_log
ADD CONSTRAINT fk_proximity_log_student_attendance
FOREIGN KEY (student_attendance_id) REFERENCES student_attendance(id) ON DELETE CASCADE;

-- Add index for the new student_attendance_id column
CREATE INDEX IF NOT EXISTS idx_proximity_log_student_attendance_id ON proximity_verification_log(student_attendance_id);
