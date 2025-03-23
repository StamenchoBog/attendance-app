-- Table `course`
INSERT INTO public.course(id, study_year, last_name_regex, semester_code, joined_subject_abbreviation, professor_id, assistant_id, number_of_first_enrollments, number_of_re_enrollments, group_portion, professors, assistants, groups, english)
VALUES (),
       (),
       (),
       (),
       ();


-- Table `semester`
INSERT INTO public.semester (code, semester_type, year, start_date, end_date, enrollment_start_date, enrollment_end_date, state)
VALUES ('2024-25-W', 'WINTER', '2024-25', null, null, null, null, null),
       ('2024-25-S', 'SUMMER', '2024-25', null, null, null, null, null);

-- Table `student`
INSERT INTO public.student (student_index, email, last_name, "name", parent_name, study_program_code)
VALUES
    ('243140', 'bojan.bojanovski@example.com', 'Bojanovski', 'Bojan', 'Vlatko', 'PIT23'),
    ('243150', 'mihail.mihajlovski@example.com', 'Mihajlovski', 'Mihail', 'Aleksandar', 'SIIS23'),
    ('243160', 'simona.simonovska@example.com', 'Simonovska', 'Simona', 'Simon', 'PIT23'),
    ('243170', 'aleksej.aleksandrovski@example.com', 'Aleksandrovski', 'Aleksej', 'Sasha', 'PIT23'),
    ('243180', 'viktor.prentov@example.com', 'Prentov','Viktor', 'Filip', 'KN23');

-- Table `student_group`
INSERT INTO public.student_group (id, "name", study_year, last_name_regex, semester_code, programs, english, default_size)
VALUES
    (1, 'CS First Year Group A', 2, '[A-M]', '2024-25-W', 'PIT23', false, 30),
    (2, 'CS First Year Group B', 2, '[N-Z]', '2024-25-W', 'PIT23', false, 30);

INSERT INTO public.teacher_subjects (id, professor_id, subject_id)
VALUES
    (1, 'marjan.gushev', 'F23L2W096'),
    (2, 'ljupcho.antovski', 'CS102'),
    (3, 'marija.mihova', 'F18W3S085'),
    (4, 'slobodan.kalajdziski', 'F18L3S022'),
    (5, 'anastas.mishev', 'F18L3S062'),
    (6, 'sonja.filiposka', 'F23L3W134'),
    (7, 'igor.mishkovski', 'F23L3S141'),
    (8, 'smilka.janeska', 'F23L3W152'),
    (9, 'mile.jovanov', 'F18L3S107'),
    (10, 'biljana.stojkoska', 'F18L3S138'),
    (11, 'ana.madevska', 'F23L3W145'),
    (12, 'suzana.loshkovska', 'F23L3W133');


INSERT INTO public.course (id, study_year, last_name_regex, semester_code, joined_subject_abbreviation, professor_id, assistant_id, number_of_first_enrollments, number_of_re_enrollments, group_portion, professors, assistants, groups, english)
VALUES (1, '', '', '2024-25-S', '', 'marjan.gushev','boban.joksimoski', '', '', '', 'dimitar.trajanov', '', '', false),
       (2, '', '', '2024-25-S', '', 'marjan.gushev','bojan.ilijoski', '', '', '', 'dimitar.trajanov,goran.velinov', 'monika.simjanoska,emil.stankov', '', false),
       (3, '', '', '2024-25-S', '', 'marjan.gushev','bojan.ilijoski', '', '', '', 'dimitar.trajanov,goran.velinov', 'monika.simjanoska,emil.stankov', '', false),
       (4, '', '', '2024-25-S', '', 'marjan.gushev','bojan.ilijoski', '', '', '', 'dimitar.trajanov,goran.velinov', 'monika.simjanoska,emil.stankov', '', false),
       (5, '', '', '2024-25-S', '', 'marjan.gushev','bojan.ilijoski', '', '', '', 'dimitar.trajanov,goran.velinov', 'monika.simjanoska,emil.stankov', '', false),
       (6, '', '', '2024-25-S', '', 'marjan.gushev','bojan.ilijoski', '', '', '', 'dimitar.trajanov,goran.velinov', 'monika.simjanoska,emil.stankov', '', false),
       (7, '', '', '2024-25-S', '', 'marjan.gushev','bojan.ilijoski', '', '', '', 'dimitar.trajanov,goran.velinov', 'monika.simjanoska,emil.stankov', '', false);

--- Table
INSERT INTO public.

--- Table