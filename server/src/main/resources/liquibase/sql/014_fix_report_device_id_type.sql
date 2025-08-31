--liquibase formatted sql
--changeset stamencho-bogdanovski:fix-report-device-id-type

-- Fix the device_id column in attendance_problem_report table
-- The current foreign key setup is incorrect - we should store the actual device identifier
-- not reference the student_device.id UUID

-- Step 1: Drop the existing foreign key constraint
ALTER TABLE attendance_problem_report
DROP CONSTRAINT IF EXISTS fk_report_device;

-- Step 2: Drop the existing index
DROP INDEX IF EXISTS idx_attendance_problem_report_device_id;

-- Step 3: Change the device_id column from UUID to VARCHAR to store actual device identifiers
ALTER TABLE attendance_problem_report
ALTER COLUMN device_id TYPE VARCHAR(255);

-- Step 4: Create new index for performance
CREATE INDEX IF NOT EXISTS idx_attendance_problem_report_device_id
    ON attendance_problem_report(device_id);

-- Step 5: Update comment to reflect the new purpose
COMMENT ON COLUMN attendance_problem_report.device_id IS 'Device identifier string from mobile app (e.g., Android ID, iOS IDFV) - matches student_device.device_id';

-- Note: We intentionally don't create a foreign key constraint here because:
-- 1. Device ID might be submitted even if the device is not registered
-- 2. Device IDs from mobile might not always match registered devices
-- 3. This allows for more flexible reporting scenarios
