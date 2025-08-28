--liquibase formatted sql
--changeset stamencho-bogdanovski:comprehensive-test-data-setup

-- =====================================================================================================================
-- COMPREHENSIVE TEST DATA SETUP FOR FINKI ATTENDANCE SYSTEM
-- This migration creates a complete test environment with realistic data for development and testing
-- =====================================================================================================================

-- =====================================================================================================================
-- SECTION 1: ACTIVE SEMESTER SETUP
-- =====================================================================================================================

-- Create active semester for testing (Winter Semester 2025)
INSERT INTO semester (code, semester_type, year, start_date, end_date, enrollment_start_date, enrollment_end_date, state)
VALUES
    ('WS2025', 'WINTER', '2025', '2025-08-01', '2025-12-31', '2025-07-15', '2025-08-15', 'ACTIVE')
ON CONFLICT (code) DO UPDATE SET
    state = 'ACTIVE',
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date;

-- Ensure we have at least one active semester by updating existing one if needed
UPDATE semester
SET state = 'ACTIVE'
WHERE code = (
    SELECT code FROM semester
    WHERE year IN ('2025', '2024')
    ORDER BY start_date DESC
    LIMIT 1
)
AND NOT EXISTS (SELECT 1 FROM semester WHERE state = 'ACTIVE');

-- =====================================================================================================================
-- SECTION 2: INFRASTRUCTURE SETUP (ROOMS, HOLIDAYS, ADMIN USERS)
-- =====================================================================================================================

-- Create authentic FINKI rooms with proper descriptions
INSERT INTO room (name, capacity, type, location_description)
VALUES
    ('Амф П', 150, 'LECTURE_HALL', 'Амфитеатар П - главна зграда'),
    ('Амф МФ', 120, 'LECTURE_HALL', 'Амфитеатар МФ - математички факултет'),
    ('Амф ТМФ', 100, 'LECTURE_HALL', 'Амфитеатар ТМФ - технолошко-металуршки факултет'),
    ('Б-301', 40, 'CLASSROOM', 'Блок Б соба 301'),
    ('Б-302', 40, 'CLASSROOM', 'Блок Б соба 302'),
    ('Б-306', 35, 'COMPUTER_LAB', 'Блок Б соба 306 - компјутерска лабораторија'),
    ('Б-308', 35, 'COMPUTER_LAB', 'Блок Б соба 308 - компјутерска лабораторија'),
    ('223', 45, 'CLASSROOM', 'Соба 223 - главна зграда'),
    ('225', 45, 'CLASSROOM', 'Соба 225 - главна зграда'),
    ('227', 40, 'CLASSROOM', 'Соба 227 - главна зграда'),
    ('Б 2.2', 30, 'COMPUTER_LAB', 'Блок Б 2-ри кат соба 2'),
    ('Б 3.2', 30, 'COMPUTER_LAB', 'Блок Б 3-ти кат соба 2'),
    ('Лаб 1', 25, 'COMPUTER_LAB', 'Лабораторија 1 - компјутерски науки'),
    ('Лаб 2', 25, 'COMPUTER_LAB', 'Лабораторија 2 - компјутерски науки')
ON CONFLICT (name) DO NOTHING;

-- Create test administrative users for system management
INSERT INTO auth_user (id, name, email, role)
VALUES
    ('admin.test', 'Тест Администратор', 'admin.test@finki.ukim.mk', 'ADMIN'),
    ('staff.test', 'Тест Персонал', 'staff.test@finki.ukim.mk', 'STAFF'),
    ('coordinator.test', 'Тест Координатор', 'coordinator.test@finki.ukim.mk', 'COORDINATOR')
ON CONFLICT (id) DO NOTHING;

-- Create comprehensive holiday calendar for 2024-2025 academic year
INSERT INTO holiday (date, name)
VALUES
    ('2024-12-25', 'Божик'),
    ('2024-12-26', 'Втор ден Божик'),
    ('2025-01-01', 'Нова Година'),
    ('2025-01-02', 'Втор ден Нова Година'),
    ('2025-01-07', 'Божик (православен)'),
    ('2025-01-19', 'Богојавление'),
    ('2025-05-01', 'Ден на трудот'),
    ('2025-05-24', 'Св. Кирил и Методиј'),
    ('2025-08-31', 'Ден на независноста - подготовки'),
    ('2025-09-08', 'Ден на независноста'),
    ('2025-09-27', 'Свети Климент Охридски')
ON CONFLICT (date) DO NOTHING;

-- =====================================================================================================================
-- SECTION 3: COMPREHENSIVE TEST STUDENT DATA
-- =====================================================================================================================

-- Create realistic test students across multiple academic years with authentic Macedonian names
INSERT INTO student (student_index, email, last_name, name, parent_name, study_program_code)
VALUES
    -- CURRENT YEAR STUDENTS (2016 generation - 4th year) - Primary test subjects
    ('161123', 'stefan.nikolovski@students.finki.ukim.mk', 'Николовски', 'Стефан', 'Александар', 'KN23'),
    ('162123', 'ana.petrovska@students.finki.ukim.mk', 'Петровска', 'Ана', 'Марко', 'SIIS23'),
    ('163123', 'marko.stojanov@students.finki.ukim.mk', 'Стојанов', 'Марко', 'Петар', 'KI23'),
    ('164123', 'elena.dimitrievska@students.finki.ukim.mk', 'Димитриевска', 'Елена', 'Никола', 'IMB23'),
    ('165123', 'aleksandar.jovanovski@students.finki.ukim.mk', 'Јовановски', 'Александар', 'Стефан', 'PIT23'),

    -- PREVIOUS YEAR STUDENTS (2015 generation - 3rd year)
    ('151123', 'petar.ivanov@students.finki.ukim.mk', 'Иванов', 'Петар', 'Марко', 'KN23'),
    ('152123', 'milica.stefanovska@students.finki.ukim.mk', 'Стефановска', 'Милица', 'Владимир', 'SIIS23'),
    ('153123', 'aleksandar.mitreski@students.finki.ukim.mk', 'Митрески', 'Александар', 'Драган', 'KI23'),
    ('154123', 'katarina.georgievska@students.finki.ukim.mk', 'Георгиевска', 'Катарина', 'Борис', 'IMB23'),
    ('155123', 'nikola.popov@students.finki.ukim.mk', 'Попов', 'Никола', 'Стефан', 'PIT23'),

    -- OLDER STUDENTS (2014 generation - graduate/repeat students)
    ('141123', 'goran.todorovski@students.finki.ukim.mk', 'Тодоровски', 'Горан', 'Петар', 'SEIS23'),
    ('142123', 'marija.kostovska@students.finki.ukim.mk', 'Костовска', 'Марија', 'Александар', 'SSP23'),
    ('143123', 'darko.velinov@students.finki.ukim.mk', 'Велинов', 'Дарко', 'Никола', 'KN23'),
    ('144123', 'tamara.ristovska@students.finki.ukim.mk', 'Ристовска', 'Тамара', 'Миле', 'SIIS23'),
    ('145123', 'vladimir.andonov@students.finki.ukim.mk', 'Андонов', 'Владимир', 'Горан', 'KI23'),

    -- IMMEDIATE TESTING STUDENTS (2020 generation - for rapid testing scenarios)
    ('201123', 'stefan.testovski@students.finki.ukim.mk', 'Тестовски', 'Стефан', 'Александар', 'KN23'),
    ('202123', 'ana.testovska@students.finki.ukim.mk', 'Тестовска', 'Ана', 'Марко', 'SIIS23'),
    ('203123', 'marko.testov@students.finki.ukim.mk', 'Тестов', 'Марко', 'Петар', 'KI23'),
    ('204123', 'elena.testova@students.finki.ukim.mk', 'Тестова', 'Елена', 'Никола', 'IMB23'),
    ('205123', 'aleksandar.testinski@students.finki.ukim.mk', 'Тестински', 'Александар', 'Стефан', 'PIT23'),

    -- ADDITIONAL DIVERSE STUDENTS for comprehensive testing
    ('131123', 'jovana.mladenovska@students.finki.ukim.mk', 'Младеновска', 'Јована', 'Владимир', 'KN23'),
    ('132123', 'bojan.stojanovski@students.finki.ukim.mk', 'Стојановски', 'Бојан', 'Петар', 'SIIS23'),
    ('133123', 'marina.dimitrova@students.finki.ukim.mk', 'Димитрова', 'Марина', 'Александар', 'KI23'),
    ('134123', 'dejan.nikolov@students.finki.ukim.mk', 'Николов', 'Дејан', 'Марко', 'IMB23'),
    ('135123', 'kristina.petrova@students.finki.ukim.mk', 'Петрова', 'Кристина', 'Стефан', 'PIT23')
ON CONFLICT (student_index) DO NOTHING;

-- =====================================================================================================================
-- SECTION 4: STUDENT ENROLLMENT SETUP
-- =====================================================================================================================

-- Create semester enrollments for all test students with realistic payment patterns
INSERT INTO student_semester_enrollment (id, semester_code, student_student_index, valid, payment_confirmed, payment_amount)
SELECT
    'sem_' || s.student_index || '_' || sem.code,
    sem.code,
    s.student_index,
    true,
    CASE
        WHEN s.student_index LIKE '20%' THEN true -- Test students always paid
        WHEN s.student_index LIKE '16%' THEN (random() < 0.95) -- 95% payment rate for current year
        WHEN s.student_index LIKE '15%' THEN (random() < 0.90) -- 90% payment rate for 3rd year
        ELSE (random() < 0.85) -- 85% payment rate for older students
    END,
    CASE
        WHEN s.student_index LIKE '16%' THEN 15000.0  -- 4th year tuition
        WHEN s.student_index LIKE '15%' THEN 14000.0  -- 3rd year tuition
        WHEN s.student_index LIKE '14%' OR s.student_index LIKE '13%' THEN 13000.0  -- Graduate/repeat students
        ELSE 16000.0  -- Current test students (premium rate)
    END
FROM student s
CROSS JOIN (
    SELECT code FROM semester WHERE state = 'ACTIVE' LIMIT 1
) sem
WHERE s.student_index LIKE '1%123' OR s.student_index LIKE '20%123'
ON CONFLICT (student_student_index, semester_code) DO NOTHING;

-- Create subject enrollments linking students to courses through joined_subjects
INSERT INTO student_subject_enrollment (id, semester_code, student_student_index, subject_id, joined_subject_abbreviation, valid, num_enrollments)
SELECT
    'subj_' || s.student_index || '_' || js.abbreviation,
    sem.code,
    s.student_index,
    js.main_subject_id,
    js.abbreviation,
    true,
    CASE
        WHEN s.student_index LIKE '20%' THEN 1  -- Test students - first enrollment
        WHEN s.student_index LIKE '16%' THEN 1  -- 4th year - mostly first enrollments
        WHEN s.student_index LIKE '15%' THEN FLOOR(random() * 2 + 1)::int  -- 3rd year - 1-2 enrollments
        WHEN s.student_index LIKE '14%' THEN FLOOR(random() * 3 + 1)::int  -- Graduate - 1-3 enrollments
        ELSE FLOOR(random() * 2 + 1)::int  -- Others - 1-2 enrollments
    END
FROM student s
CROSS JOIN (
    SELECT code FROM semester WHERE state = 'ACTIVE' LIMIT 1
) sem
CROSS JOIN (
    SELECT * FROM joined_subject
    WHERE main_subject_id IS NOT NULL
    ORDER BY abbreviation
    LIMIT 15  -- Enroll students in first 15 available subjects
) js
WHERE (s.student_index LIKE '1%123' OR s.student_index LIKE '20%123')
  AND EXISTS (SELECT 1 FROM semester WHERE state = 'ACTIVE')
  AND (s.student_index LIKE '20%' OR random() < 0.80)  -- 100% for test students, 80% for others
ON CONFLICT (student_student_index, semester_code, subject_id) DO NOTHING;

-- =====================================================================================================================
-- SECTION 5: COURSE CREATION AND ACADEMIC STRUCTURE
-- =====================================================================================================================

-- Create courses from joined_subjects that have student enrollments
INSERT INTO course (id, study_year, semester_code, joined_subject_abbreviation, professor_id, number_of_first_enrollments, number_of_re_enrollments)
SELECT
    ROW_NUMBER() OVER (ORDER BY js.abbreviation) + 10000, -- Start IDs from 10001
    CASE
        WHEN js.abbreviation LIKE '%1' OR js.abbreviation LIKE '%I' THEN 1
        WHEN js.abbreviation LIKE '%2' OR js.abbreviation LIKE '%II' THEN 2
        WHEN js.abbreviation LIKE '%3' OR js.abbreviation LIKE '%III' THEN 3
        WHEN js.abbreviation LIKE '%4' OR js.abbreviation LIKE '%IV' THEN 4
        ELSE 2 -- Default to 2nd year
    END,
    sem.code,
    js.abbreviation,
    -- Assign professors in round-robin fashion using real FINKI professors
    CASE (ROW_NUMBER() OVER (ORDER BY js.abbreviation) % 11)
        WHEN 1 THEN 'danco.davcev'           -- Данчо Давчев
        WHEN 2 THEN 'bojana.koteska'         -- Бојана Котеска
        WHEN 3 THEN 'kostadin.mishev'        -- Костадин Мишев
        WHEN 4 THEN 'marjan.gushev'          -- Марјан Гушев
        WHEN 5 THEN 'katerina.zdravkova'     -- Катерина Здравкова
        WHEN 6 THEN 'suzana.loshkovska'      -- Сузана Лошковска
        WHEN 7 THEN 'kosta.mitreski'         -- Коста Митрески
        WHEN 8 THEN 'monika.simjanoska'      -- Моника Симјаноска
        WHEN 9 THEN 'aleksandar.tenev'       -- Александар Тенев
        WHEN 10 THEN 'sasho.gramatikov'      -- Сашо Граматиков
        ELSE 'metodija.jancheski'            -- Методија Јанчески
    END,
    -- Count actual first enrollments
    COALESCE(
        (SELECT COUNT(*) FROM student_subject_enrollment sse
         WHERE sse.joined_subject_abbreviation = js.abbreviation
         AND sse.semester_code = sem.code
         AND sse.valid = true
         AND COALESCE(sse.num_enrollments, 1) = 1), 0
    ),
    -- Count actual re-enrollments
    COALESCE(
        (SELECT COUNT(*) FROM student_subject_enrollment sse
         WHERE sse.joined_subject_abbreviation = js.abbreviation
         AND sse.semester_code = sem.code
         AND sse.valid = true
         AND COALESCE(sse.num_enrollments, 1) > 1), 0
    )
FROM joined_subject js
CROSS JOIN (
    SELECT code FROM semester WHERE state = 'ACTIVE' LIMIT 1
) sem
WHERE NOT EXISTS (
    SELECT 1 FROM course c
    WHERE c.joined_subject_abbreviation = js.abbreviation
    AND c.semester_code = sem.code
)
AND EXISTS (SELECT 1 FROM semester WHERE state = 'ACTIVE')
AND EXISTS (
    -- Only create courses for subjects with actual student enrollments
    SELECT 1 FROM student_subject_enrollment sse
    WHERE sse.joined_subject_abbreviation = js.abbreviation
    AND sse.semester_code = sem.code
    AND sse.valid = true
)
LIMIT 25; -- Create courses for up to 25 subjects with enrollments

-- Link student subject enrollments to newly created courses
UPDATE student_subject_enrollment sse
SET course_id = c.id
FROM course c
JOIN semester sem ON c.semester_code = sem.code
WHERE sem.state = 'ACTIVE'
  AND sse.semester_code = c.semester_code
  AND sse.joined_subject_abbreviation = c.joined_subject_abbreviation
  AND sse.course_id IS NULL
  AND c.id > 10000; -- Only link to our newly created courses

-- =====================================================================================================================
-- SECTION 6: VERIFICATION AND SUMMARY
-- =====================================================================================================================

-- Show comprehensive summary of what was created
DO $$
DECLARE
    active_semester_count INTEGER;
    joined_subject_count INTEGER;
    student_enrollment_count INTEGER;
    course_count INTEGER;
    test_student_count INTEGER;
    total_student_count INTEGER;
    room_count INTEGER;
    admin_user_count INTEGER;
    holiday_count INTEGER;
BEGIN
    -- Collect statistics
    SELECT COUNT(*) INTO active_semester_count FROM semester WHERE state = 'ACTIVE';
    SELECT COUNT(*) INTO joined_subject_count FROM joined_subject;
    SELECT COUNT(*) INTO student_enrollment_count FROM student_subject_enrollment sse
    JOIN semester sem ON sse.semester_code = sem.code
    WHERE sem.state = 'ACTIVE' AND sse.valid = true;
    SELECT COUNT(*) INTO test_student_count FROM student WHERE student_index LIKE '20%123';
    SELECT COUNT(*) INTO total_student_count FROM student WHERE student_index LIKE '1%123' OR student_index LIKE '20%123';
    SELECT COUNT(*) INTO room_count FROM room;
    SELECT COUNT(*) INTO admin_user_count FROM auth_user WHERE id LIKE '%.test';
    SELECT COUNT(*) INTO holiday_count FROM holiday WHERE date BETWEEN '2024-12-01' AND '2025-12-31';
    SELECT COUNT(*) INTO course_count FROM course WHERE id > 10000;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'COMPREHENSIVE TEST DATA SETUP COMPLETE';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'INFRASTRUCTURE:';
    RAISE NOTICE '- Active semesters: %', active_semester_count;
    RAISE NOTICE '- FINKI rooms created: %', room_count;
    RAISE NOTICE '- Administrative users: %', admin_user_count;
    RAISE NOTICE '- Academic year holidays: %', holiday_count;
    RAISE NOTICE '';
    RAISE NOTICE 'ACADEMIC DATA:';
    RAISE NOTICE '- Available joined subjects: %', joined_subject_count;
    RAISE NOTICE '- Courses created from enrollments: %', course_count;
    RAISE NOTICE '- Valid student subject enrollments: %', student_enrollment_count;
    RAISE NOTICE '';
    RAISE NOTICE 'STUDENT POPULATION:';
    RAISE NOTICE '- Immediate test students (20x123): %', test_student_count;
    RAISE NOTICE '- Total test students (all years): %', total_student_count;
    RAISE NOTICE '';

    IF active_semester_count = 0 THEN
        RAISE NOTICE 'ERROR: No active semesters found!';
    ELSE
        RAISE NOTICE 'SUCCESS: Active semester environment ready!';
    END IF;

    IF course_count = 0 THEN
        RAISE NOTICE 'WARNING: No courses created - check subject enrollments';
    ELSE
        RAISE NOTICE 'SUCCESS: Academic course structure established!';
    END IF;

    RAISE NOTICE '========================================';
END $$;
