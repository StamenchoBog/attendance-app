--liquibase formatted sql
--changeset stamencho-bogdanovski:attendance-updates

-- Add status and proximity to student_attendance
ALTER TABLE public.student_attendance ADD COLUMN status VARCHAR(255) NOT NULL DEFAULT 'PRESENT';
ALTER TABLE public.student_attendance ADD COLUMN proximity VARCHAR(255);

-- Add token expiration to professor_class_session
ALTER TABLE public.professor_class_session ADD COLUMN token_expiration_time TIMESTAMP;

-- Update existing records to have a valid status based on the class date
-- Set status to 'PRESENT' for past classes
UPDATE public.student_attendance
SET status = 'PRESENT'
WHERE id IN (
    SELECT sa.id
    FROM student_attendance sa
    JOIN professor_class_session pcs ON sa.professor_class_session_id = pcs.id
    WHERE pcs.date < CURRENT_DATE
);

-- Set status to 'PENDING_VERIFICATION' for future classes
UPDATE public.student_attendance
SET status = 'PENDING_VERIFICATION'
WHERE id IN (
    SELECT sa.id
    FROM student_attendance sa
    JOIN professor_class_session pcs ON sa.professor_class_session_id = pcs.id
    WHERE pcs.date >= CURRENT_DATE
);
