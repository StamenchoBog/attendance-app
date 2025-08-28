--liquibase formatted sql
--changeset stamencho-bogdanovski:class-scheduling-and-attendance-system

-- =====================================================================================================================
-- CLASS SCHEDULING AND ATTENDANCE SYSTEM SETUP
-- This migration creates the complete class schedule and attendance tracking system for today and beyond
-- =====================================================================================================================

-- =====================================================================================================================
-- SECTION 1: SMART WEEKLY CLASS SCHEDULE CREATION (NO CONFLICTS)
-- =====================================================================================================================

-- Create distributed weekly scheduled class sessions with minimal strategic conflicts
-- Each course gets assigned to unique time slots, but with 2 intentional conflicts per week for testing
INSERT INTO scheduled_class_session (id, course_id, room_name, type, start_time, end_time, day_of_week, semester_code)
WITH course_schedule_assignment AS (
    -- Assign each course to specific time slots in a round-robin fashion
    SELECT
        c.id as course_id,
        c.semester_code,
        ROW_NUMBER() OVER (ORDER BY c.id) as course_sequence,
        -- Calculate which time slot this course should get (cycling through available slots)
        -- But create intentional conflicts for courses #8 and #15 to test conflict resolution
        CASE
            WHEN ROW_NUMBER() OVER (ORDER BY c.id) = 8 THEN 3  -- Conflict with course #3 (Monday 11:30)
            WHEN ROW_NUMBER() OVER (ORDER BY c.id) = 15 THEN 18 -- Conflict with course #18 (Wednesday 13:15)
            ELSE ((ROW_NUMBER() OVER (ORDER BY c.id) - 1) % 33) + 1  -- Normal round-robin for others
        END as time_slot_index
    FROM course c
    JOIN semester sem ON c.semester_code = sem.code
    WHERE sem.state = 'ACTIVE' AND c.id > 10000
),
time_slots AS (
    -- Define all available time slots across the week (33 unique slots + 2 conflicts = 35 total)
    SELECT
        slot_id,
        day_of_week,
        session_type,
        start_time,
        end_time,
        room_name
    FROM (
        VALUES
            -- MONDAY (day 1) - 7 time slots
            (1,  1, 'lecture',  '08:00'::time, '09:30'::time, 'Амф П'),
            (2,  1, 'exercise', '09:45'::time, '11:15'::time, 'Б-306'),
            (3,  1, 'lecture',  '11:30'::time, '13:00'::time, 'Амф МФ'),  -- CONFLICT SLOT #1
            (4,  1, 'lab',      '13:15'::time, '14:45'::time, 'Лаб 1'),
            (5,  1, 'exercise', '15:00'::time, '16:30'::time, 'Б 3.2'),
            (6,  1, 'lecture',  '16:45'::time, '18:15'::time, '223'),
            (7,  1, 'lab',      '18:30'::time, '20:00'::time, 'Лаб 2'),

            -- TUESDAY (day 2) - 7 time slots
            (8,  2, 'lecture',  '08:00'::time, '09:30'::time, 'Амф ТМФ'),
            (9,  2, 'exercise', '09:45'::time, '11:15'::time, 'Б-308'),
            (10, 2, 'lecture',  '11:30'::time, '13:00'::time, 'Амф П'),
            (11, 2, 'lab',      '13:15'::time, '14:45'::time, 'Лаб 1'),
            (12, 2, 'exercise', '15:00'::time, '16:30'::time, 'Б-306'),
            (13, 2, 'lecture',  '16:45'::time, '18:15'::time, '225'),
            (14, 2, 'lab',      '18:30'::time, '20:00'::time, 'Лаб 2'),

            -- WEDNESDAY (day 3) - TODAY! 7 time slots
            (15, 3, 'lecture',  '08:00'::time, '09:30'::time, 'Амф П'),
            (16, 3, 'exercise', '09:45'::time, '11:15'::time, 'Б-306'),
            (17, 3, 'lecture',  '11:30'::time, '13:00'::time, 'Амф МФ'),
            (18, 3, 'lab',      '13:15'::time, '14:45'::time, 'Лаб 1'),  -- CONFLICT SLOT #2
            (19, 3, 'exercise', '15:00'::time, '16:30'::time, 'Б 3.2'),
            (20, 3, 'lecture',  '16:45'::time, '18:15'::time, '223'),
            (21, 3, 'lab',      '18:30'::time, '20:00'::time, 'Лаб 2'),

            -- THURSDAY (day 4) - 7 time slots
            (22, 4, 'lecture',  '08:00'::time, '09:30'::time, 'Амф ТМФ'),
            (23, 4, 'exercise', '09:45'::time, '11:15'::time, 'Б-308'),
            (24, 4, 'lecture',  '11:30'::time, '13:00'::time, 'Амф П'),
            (25, 4, 'lab',      '13:15'::time, '14:45'::time, 'Лаб 2'),  -- Different room to avoid conflict
            (26, 4, 'exercise', '15:00'::time, '16:30'::time, 'Б-306'),
            (27, 4, 'lecture',  '16:45'::time, '18:15'::time, '225'),
            (28, 4, 'lab',      '18:30'::time, '20:00'::time, 'Б-308'),  -- Different room

            -- FRIDAY (day 5) - 5 time slots (reduced to accommodate conflicts)
            (29, 5, 'lecture',  '08:00'::time, '09:30'::time, 'Амф П'),
            (30, 5, 'exercise', '09:45'::time, '11:15'::time, 'Б-306'),
            (31, 5, 'lecture',  '11:30'::time, '13:00'::time, 'Амф МФ'),
            (32, 5, 'lab',      '13:15'::time, '14:45'::time, 'Лаб 1'),
            (33, 5, 'exercise', '15:00'::time, '16:30'::time, 'Б 3.2')
    ) slots(slot_id, day_of_week, session_type, start_time, end_time, room_name)
)
SELECT
    50000 + csa.course_id, -- Unique ID for each scheduled session
    csa.course_id,
    ts.room_name,
    ts.session_type,
    ts.start_time,
    ts.end_time,
    ts.day_of_week,
    csa.semester_code
FROM course_schedule_assignment csa
JOIN time_slots ts ON csa.time_slot_index = ts.slot_id
WHERE NOT EXISTS (
    SELECT 1 FROM scheduled_class_session scs
    WHERE scs.course_id = csa.course_id
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================================================================================
-- SECTION 2: TODAY'S PROFESSOR CLASS SESSIONS (Wednesday, August 27, 2025)
-- =====================================================================================================================

-- Create professor class sessions for TODAY without attendance tokens (tokens should be generated when professor starts class)
INSERT INTO professor_class_session (id, professor_id, scheduled_class_session_id, date, attendance_token, token_expiration_time)
SELECT
    60000 + scs.id,
    c.professor_id,
    scs.id,
    '2025-08-27'::date, -- Today's date
    NULL, -- No attendance token initially - professor generates when starting class
    NULL  -- No expiration time initially
FROM scheduled_class_session scs
JOIN course c ON scs.course_id = c.id
JOIN semester sem ON c.semester_code = sem.code
WHERE scs.day_of_week = 3 -- Wednesday
  AND sem.state = 'ACTIVE'
  AND c.id > 10000 -- Only our newly created courses
  AND NOT EXISTS (
    SELECT 1 FROM professor_class_session pcs
    WHERE pcs.scheduled_class_session_id = scs.id
    AND pcs.date = '2025-08-27'
  )
ON CONFLICT (id) DO NOTHING;

-- =====================================================================================================================
-- SECTION 3: EXTENDED SEMESTER SCHEDULE (August - December 2025)
-- =====================================================================================================================

-- Create professor class sessions for the entire active semester period without tokens
INSERT INTO professor_class_session (id, professor_id, scheduled_class_session_id, date, attendance_token, token_expiration_time)
SELECT
    20000 + (EXTRACT(DOY FROM d.session_date) * 100) + scs.id,  -- Unique ID using day of year
    c.professor_id,
    scs.id,
    d.session_date,
    NULL, -- No attendance token initially - professor generates when starting class
    NULL  -- No expiration time initially
FROM scheduled_class_session scs
JOIN course c ON scs.course_id = c.id
JOIN semester sem ON c.semester_code = sem.code
CROSS JOIN (
    -- Generate dates for August 28 through December 31, 2025 (excluding today which is handled above)
    SELECT generate_series(
        '2025-08-28'::date,  -- Start from tomorrow
        '2025-12-31'::date,  -- Through end of semester
        '1 day'::interval
    )::date AS session_date
) d
WHERE sem.state = 'ACTIVE'
  AND c.id > 10000 -- Only our newly created courses
  AND EXTRACT(DOW FROM d.session_date) = scs.day_of_week
  AND d.session_date NOT IN (
    -- Exclude holidays
    SELECT date FROM holiday
    WHERE date BETWEEN '2025-08-28' AND '2025-12-31'
  )
  AND EXTRACT(DOW FROM d.session_date) BETWEEN 1 AND 5  -- Monday to Friday only
  AND NOT EXISTS (
    SELECT 1 FROM professor_class_session pcs
    WHERE pcs.scheduled_class_session_id = scs.id
    AND pcs.date = d.session_date
  )
ON CONFLICT (id) DO NOTHING;

-- =====================================================================================================================
-- SECTION 4: SAMPLE ATTENDANCE DATA FOR TESTING
-- =====================================================================================================================

-- Create sample attendance records for yesterday's classes (for testing historical data)
INSERT INTO student_attendance (student_student_index, professor_class_session_id, arrival_time, status, proximity, verified_at, verified_by)
SELECT
    sse.student_student_index,
    pcs.id,
    '2025-08-26'::date + scs.start_time + (random() * INTERVAL '15 minutes'), -- Random arrival within 15 minutes of start
    CASE
        WHEN random() < 0.85 THEN 'PRESENT'::varchar
        WHEN random() < 0.95 THEN 'LATE'::varchar
        ELSE 'ABSENT'::varchar
    END,
    CASE
        WHEN random() < 0.7 THEN 'CLOSE'::varchar
        WHEN random() < 0.9 THEN 'MEDIUM'::varchar
        ELSE 'FAR'::varchar
    END,
    '2025-08-26'::date + scs.start_time + INTERVAL '30 minutes', -- Verified 30 minutes after start
    'system.auto'
FROM professor_class_session pcs
JOIN scheduled_class_session scs ON pcs.scheduled_class_session_id = scs.id
JOIN course c ON scs.course_id = c.id
JOIN student_subject_enrollment sse ON sse.course_id = c.id
WHERE pcs.date = '2025-08-26' -- Yesterday's classes
  AND sse.valid = true
  AND c.id > 10000
  AND random() < 0.75 -- 75% of enrolled students have attendance records
ON CONFLICT DO NOTHING;

-- =====================================================================================================================
-- SECTION 5: NO AUTOMATIC TOKEN GENERATION
-- =====================================================================================================================

-- NOTE: Attendance tokens are NOT generated automatically
-- Professors must start their class sessions through the mobile app to generate tokens
-- This simulates the real workflow where professors control when attendance tracking begins
