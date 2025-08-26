--liquibase formatted sql
--changeset stamencho-bogdanovski:refactor-joined-subject-codes

-- 1. Create the new join table
CREATE TABLE IF NOT EXISTS joined_subject_codes (
    joined_subject_abbreviation VARCHAR(255) NOT NULL,
    subject_id VARCHAR(255) NOT NULL,
    PRIMARY KEY (joined_subject_abbreviation, subject_id),
    FOREIGN KEY (joined_subject_abbreviation) REFERENCES joined_subject(abbreviation)
);

-- 2. Migrate the data from the JSONB column to the new table
-- This script iterates through each joined_subject, expands the 'codes' JSON array,
-- and inserts each code into the new table.
DO $$
DECLARE
    js_record RECORD;
    code_element JSONB;
BEGIN
    FOR js_record IN SELECT abbreviation, codes FROM joined_subject WHERE codes IS NOT NULL AND jsonb_typeof(codes) = 'array'
    LOOP
        FOR code_element IN SELECT * FROM jsonb_array_elements(js_record.codes)
        LOOP
            -- The element is a JSON string like '"F23L1S003"', so we remove the quotes.
            INSERT INTO joined_subject_codes (joined_subject_abbreviation, subject_id)
            VALUES (js_record.abbreviation, trim(both '"' from code_element::text))
            ON CONFLICT (joined_subject_abbreviation, subject_id) DO NOTHING;
        END LOOP;
    END LOOP;
END $$;

-- 3. (Optional but recommended) Drop the old JSONB column
ALTER TABLE joined_subject DROP COLUMN IF EXISTS codes;

-- 4. Add an index to the new table for performance
CREATE INDEX IF NOT EXISTS idx_jsc_subject_id ON joined_subject_codes(subject_id);

