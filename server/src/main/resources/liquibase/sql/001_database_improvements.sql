--liquibase formatted sql
--changeset stamencho-bogdanovski:database-improvements

-- Make column `joined_subject.codes` to a JSONB data type
UPDATE joined_subject
SET codes = '[' ||
            (SELECT string_agg('"' || value || '"', ',')
             FROM regexp_split_to_table(codes, ',') AS value) ||
            ']'
WHERE codes IS NOT NULL;
ALTER TABLE joined_subject ALTER COLUMN codes TYPE jsonb USING codes::jsonb::jsonb;

-- Create a table which will store device IDs of students
-- Each student can register only with one device to protect from being exploited.
CREATE TABLE student_device (
    ID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_student_index VARCHAR(255) NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    device_os VARCHAR(255),
    created_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_student_index) REFERENCES student (student_index)
);
