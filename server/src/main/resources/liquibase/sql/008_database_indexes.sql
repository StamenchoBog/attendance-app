--liquibase formatted sql
--changeset stamencho-bogdanovski:performance-indexes

-- Core performance indexes (removing duplicates from other files)
CREATE INDEX IF NOT EXISTS idx_pcs_professor_id ON professor_class_session(professor_id);
CREATE INDEX IF NOT EXISTS idx_pcs_date ON professor_class_session(date);
CREATE INDEX IF NOT EXISTS idx_pcs_scheduled_class_session_id ON professor_class_session(scheduled_class_session_id);

CREATE INDEX IF NOT EXISTS idx_sa_student_index ON student_attendance(student_student_index);
CREATE INDEX IF NOT EXISTS idx_sa_professor_class_session_id ON student_attendance(professor_class_session_id);

CREATE INDEX IF NOT EXISTS idx_sse_student_index ON student_semester_enrollment(student_student_index);
CREATE INDEX IF NOT EXISTS idx_sse_course_id ON student_subject_enrollment(course_id);
CREATE INDEX IF NOT EXISTS idx_scs_course_id ON scheduled_class_session(course_id);
CREATE INDEX IF NOT EXISTS idx_tsa_professor_id ON teacher_subject_allocations(professor_id);
