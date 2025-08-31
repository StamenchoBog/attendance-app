--liquibase formatted sql
--changeset stamencho-bogdanovski:refactor-reports-foreign-keys

-- Refactor attendance_problem_report table to use proper foreign keys
-- instead of plain text fields for better data integrity and normalization

-- Step 1: Add new foreign key columns
ALTER TABLE attendance_problem_report
ADD COLUMN IF NOT EXISTS student_index VARCHAR(20);

ALTER TABLE attendance_problem_report
ADD COLUMN IF NOT EXISTS device_id UUID;

-- Step 2: Create foreign key constraints
-- Note: student_index references the student_index in students table
-- device_id references the id in student_devices table (optional)
ALTER TABLE attendance_problem_report
ADD CONSTRAINT fk_report_student
    FOREIGN KEY (student_index) REFERENCES student(student_index)
    ON DELETE SET NULL;

ALTER TABLE attendance_problem_report
ADD CONSTRAINT fk_report_device
    FOREIGN KEY (device_id) REFERENCES student_device(id)
    ON DELETE SET NULL;

-- Step 4: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_attendance_problem_report_student_index
    ON attendance_problem_report(student_index);
CREATE INDEX IF NOT EXISTS idx_attendance_problem_report_device_id
    ON attendance_problem_report(device_id);

-- Step 5: Add comments for documentation
COMMENT ON COLUMN attendance_problem_report.student_index IS 'Foreign key to students table - identifies who submitted the report';
COMMENT ON COLUMN attendance_problem_report.device_id IS 'Optional foreign key to student_devices table - identifies the device associated with the report';

-- Step 6: Update table comment to reflect the new structure
COMMENT ON TABLE attendance_problem_report IS 'Stores user-submitted bug reports, feature requests, and feedback with proper foreign key relationships';

-- Note: We keep the old user_info and device_info columns for now to avoid data loss
-- They can be dropped in a future migration after verifying the migration was successful
-- ALTER TABLE attendance_problem_report DROP COLUMN IF EXISTS user_info;
-- ALTER TABLE attendance_problem_report DROP COLUMN IF EXISTS device_info;
