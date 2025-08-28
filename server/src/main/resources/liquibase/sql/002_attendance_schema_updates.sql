--liquibase formatted sql
--changeset stamencho-bogdanovski:attendance-updates

-- Add status and proximity to student_attendance with proper constraints
ALTER TABLE student_attendance
ADD COLUMN IF NOT EXISTS status VARCHAR(255) NOT NULL DEFAULT 'PRESENT'
CONSTRAINT chk_attendance_status CHECK (status IN ('PRESENT', 'ABSENT', 'LATE', 'PENDING_VERIFICATION', 'EXCUSED'));

ALTER TABLE student_attendance
ADD COLUMN IF NOT EXISTS proximity VARCHAR(255);

-- Add token expiration to professor_class_session
ALTER TABLE professor_class_session
ADD COLUMN IF NOT EXISTS attendance_token VARCHAR(255) UNIQUE,
ADD COLUMN IF NOT EXISTS token_expiration_time TIMESTAMP;

-- Add verification timestamp for audit trail
ALTER TABLE student_attendance
ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS verified_by VARCHAR(255);

-- Update existing records to have a valid status
UPDATE student_attendance
SET status = 'PRESENT'
WHERE status IS NULL;

-- Essential indexes only
CREATE INDEX IF NOT EXISTS idx_student_attendance_status ON student_attendance(status);
CREATE INDEX IF NOT EXISTS idx_professor_class_session_token ON professor_class_session(attendance_token) WHERE attendance_token IS NOT NULL;

--rollback ALTER TABLE student_attendance DROP COLUMN IF EXISTS status, DROP COLUMN IF EXISTS proximity, DROP COLUMN IF EXISTS verified_at, DROP COLUMN IF EXISTS verified_by; ALTER TABLE professor_class_session DROP COLUMN IF EXISTS attendance_token, DROP COLUMN IF EXISTS token_expiration_time;
