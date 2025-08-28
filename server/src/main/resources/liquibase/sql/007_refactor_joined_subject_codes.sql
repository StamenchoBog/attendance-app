--liquibase formatted sql
--changeset stamencho-bogdanovski:refactor-joined-subject-codes

-- Create the new join table
CREATE TABLE IF NOT EXISTS joined_subject_codes (
    joined_subject_abbreviation VARCHAR(255) NOT NULL,
    subject_id VARCHAR(255) NOT NULL,
    PRIMARY KEY (joined_subject_abbreviation, subject_id),
    FOREIGN KEY (joined_subject_abbreviation) REFERENCES joined_subject(abbreviation)
);

-- Migrate data from text/varchar codes column to new table
-- Handle the case where codes might be text, not JSONB
DO $migration$
DECLARE
    js_record RECORD;
    code_value TEXT;
BEGIN
    -- Check if codes column exists and has data
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_name = 'joined_subject' AND column_name = 'codes') THEN

        FOR js_record IN SELECT abbreviation, codes FROM joined_subject WHERE codes IS NOT NULL AND codes != '' AND codes != 'null'
        LOOP
            -- Handle different formats of codes
            IF js_record.codes LIKE '[%]' THEN
                -- Already JSON-like format, extract values
                FOR code_value IN
                    SELECT trim(both '"' from unnest(string_to_array(
                        trim(both '[]' from js_record.codes), ','
                    )))
                LOOP
                    IF code_value != '' THEN
                        INSERT INTO joined_subject_codes (joined_subject_abbreviation, subject_id)
                        VALUES (js_record.abbreviation, trim(code_value))
                        ON CONFLICT (joined_subject_abbreviation, subject_id) DO NOTHING;
                    END IF;
                END LOOP;
            ELSIF js_record.codes LIKE '%,%' THEN
                -- Comma-separated values
                FOR code_value IN
                    SELECT trim(unnest(string_to_array(js_record.codes, ',')))
                LOOP
                    IF code_value != '' THEN
                        INSERT INTO joined_subject_codes (joined_subject_abbreviation, subject_id)
                        VALUES (js_record.abbreviation, code_value)
                        ON CONFLICT (joined_subject_abbreviation, subject_id) DO NOTHING;
                    END IF;
                END LOOP;
            ELSE
                -- Single value
                INSERT INTO joined_subject_codes (joined_subject_abbreviation, subject_id)
                VALUES (js_record.abbreviation, js_record.codes)
                ON CONFLICT (joined_subject_abbreviation, subject_id) DO NOTHING;
            END IF;
        END LOOP;
    END IF;
END $migration$;

-- Drop the old codes column
ALTER TABLE joined_subject DROP COLUMN IF EXISTS codes;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_jsc_subject_id ON joined_subject_codes(subject_id);
