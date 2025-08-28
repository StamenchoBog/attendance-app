--liquibase formatted sql
--changeset stamencho-bogdanovski:optimize-reports-performance

-- Essential composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_reports_status_priority ON attendance_problem_report(status, priority);
CREATE INDEX IF NOT EXISTS idx_reports_type_created_at ON attendance_problem_report(report_type, created_at DESC);
