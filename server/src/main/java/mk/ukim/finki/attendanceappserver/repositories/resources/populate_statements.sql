INSERT INTO public.semester (code, semester_type, "year", start_date, end_date,
                             enrollment_start_date, enrollment_end_date, state)
VALUES
    ('SEM2024-1', 'Spring', '2024', '2024-02-01', '2024-06-30', '2024-01-15', '2024-01-31', 'Active');

INSERT INTO public.student (student_index, email, last_name, "name", parent_name, study_program_code)
VALUES
    ('S2024001', 'john.doe@example.com', 'Doe', 'John', 'Michael', 'CS2024'),
    ('S2024002', 'jane.smith@example.com', 'Smith', 'Jane', 'Elizabeth', 'CS2024');

INSERT INTO public.student_group (id, "name", study_year, last_name_regex, semester_code, programs, english, default_size)
VALUES
    (1, 'CS First Year Group A', 1, '[A-M]', 'SEM2024-1', 'CS2024', false, 30),
    (2, 'CS First Year Group B', 1, '[N-Z]', 'SEM2024-1', 'CS2024', false, 30);

INSERT INTO public.teacher_subjects (id, professor_id, subject_id)
VALUES
    (1, 'P123', 'CS101'),
    (2, 'P124', 'CS102');

INSERT INTO public.course (id, study_year, last_name_regex, semester_code, joined_subject_abbreviation, professor_id, assistant_id, number_of_first_enrollments, number_of_re_enrollments, group_portion, professors, assistants, "groups", english)
VALUES
    (1, 1, '[A-M]', 'SEM2024-1', 'CS101', 'P123', NULL, 30, 5, 1.0, 'P123', '', '1', false),
    (2, 1, '[N-Z]', 'SEM2024-1', 'CS102', 'P124', NULL, 30, 5, 1.0, 'P124', '', '2', false);

INSERT INTO public.course_rooms (course_id, rooms_name)
VALUES
    (1, 'Room 101'),
    (2, 'Room 102');

INSERT INTO public.scheduled_class_session (id, course_id, room_name, "type", start_time, end_time, day_of_week)
VALUES
    (1, 1, 'Room 101', 'Lecture', '08:00:00', '10:00:00', 1),
    (2, 2, 'Room 102', 'Lecture', '10:00:00', '12:00:00', 3);

INSERT INTO public.student_courses (id, student_student_index, course_id)
VALUES
    (1, 'S2024001', 1),
    (2, 'S2024002', 2);

INSERT INTO public.student_subject_enrollment (id, semester_code, student_student_index, subject_id, "valid", invalid_note, num_enrollments, group_name, group_id, joined_subject_abbreviation, professor_id, professors, assistants, course_id)
VALUES
    ('E1', 'SEM2024-1', 'S2024001', 'CS101', true, NULL, 1, 'CS First Year Group A', 1, 'CS101', 'P123', 'P123', '', 1),
    ('E2', 'SEM2024-1', 'S2024002', 'CS102', true, NULL, 1, 'CS First Year Group B', 2, 'CS102', 'P124', 'P124', '', 2);

INSERT INTO public.subject_exam_rooms (subject_exam_id, rooms_name)
VALUES
    ('EXAM1', 'Room 201'),
    ('EXAM2', 'Room 202');

INSERT INTO public.professor_class_session (id, professor_id, scheduled_class_session_id, "date", professor_arrival_time, attendance_token)
VALUES
    (1, 'P123', 1, '2024-02-10', '07:50:00', 'TOKEN123'),
    (2, 'P124', 2, '2024-02-12', '09:50:00', 'TOKEN124');
