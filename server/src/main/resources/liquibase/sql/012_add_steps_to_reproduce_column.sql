--liquibase formatted sql
--changeset stamencho-bogdanovski:add-steps-to-reproduce-column

-- Add missing steps_to_reproduce column to attendance_problem_report table
-- This column is required by the Report entity but was missing from the original schema
ALTER TABLE attendance_problem_report
ADD COLUMN IF NOT EXISTS steps_to_reproduce TEXT;

-- Add comment for documentation
COMMENT ON COLUMN attendance_problem_report.steps_to_reproduce IS 'Optional field for users to describe steps to reproduce bugs or issues';
