--liquibase formatted sql
--changeset stamencho-bogdanovski:create-reports-table

-- Create attendance_problem_report table for storing user-submitted reports
CREATE TABLE IF NOT EXISTS attendance_problem_report (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    user_info VARCHAR(255),
    device_info TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'NEW',
    admin_notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Essential indexes only
CREATE INDEX IF NOT EXISTS idx_attendance_problem_report_status ON attendance_problem_report(status);
CREATE INDEX IF NOT EXISTS idx_attendance_problem_report_created_at ON attendance_problem_report(created_at);

-- Add comments for documentation
COMMENT ON TABLE attendance_problem_report IS 'Stores user-submitted bug reports, feature requests, and feedback for the attendance app';
COMMENT ON COLUMN attendance_problem_report.report_type IS 'Type of report: bug, feature_request, attendance_issue, device_issue, other';
COMMENT ON COLUMN attendance_problem_report.priority IS 'Priority level: low, medium, high, critical';
COMMENT ON COLUMN attendance_problem_report.status IS 'Current status: NEW, IN_PROGRESS, RESOLVED, CLOSED';
COMMENT ON COLUMN attendance_problem_report.user_info IS 'Optional user information (student/professor ID, no personal data)';
COMMENT ON COLUMN attendance_problem_report.device_info IS 'Optional device information for debugging';
COMMENT ON COLUMN attendance_problem_report.admin_notes IS 'Internal notes from administrators or developers';
