--liquibase formatted sql
--changeset stamencho-bogdanovski:fix-student-attendance-auto-increment

CREATE SEQUENCE IF NOT EXISTS student_attendance_id_seq;

SELECT setval('student_attendance_id_seq', (SELECT COALESCE(MAX(id), 0) + 1 FROM student_attendance));

ALTER TABLE student_attendance
ALTER COLUMN id SET DEFAULT nextval('student_attendance_id_seq');

ALTER SEQUENCE student_attendance_id_seq OWNED BY student_attendance.id;
