--liquibase formatted sql
--changeset stamencho-bogdanovski:additional-test-data

-- Data for table `semester`
INSERT INTO semester (code, semester_type, 'year')
VALUES ('2024-25-S', 'SUMMER', '2024-25')
        ('2024-25-W', 'WINTER', '2024-25');

-- Data for table `course`
INSERT INTO course (id, study_year, semester_code, joined_subject_abbreviation, professor_id, assistant_id)
VALUES (1, '2024', '2024-25-S', 'AOK', 'igor.mishkovski', 'igor.mishkovski'),
          (2, '2024', '2024-25-S', 'OS', 'sasho.gramatikov', 'sasho.gramatikov'),
          (3, '2024', '2024-25-S', 'BS', 'aleksandra.popovska', 'aleksandra.popovska'),
          (4, '2024', '2024-25-S', 'K2', 'aleksandra.popovska', 'aleksandra.popovska'),
          (5, '2024', '2024-25-S', 'ONVD', 'dimitar.kitanovski', 'dimitar.kitanovski'),
          (6, '2024', '2024-25-S', 'OOP', 'vlatko.spasev', 'vlatko.spasev'),
          (7, '2024', '2024-25-S', 'OS', 'igor.mishkovski', 'igor.mishkovski'),
          (8, '2024', '2024-25-S', 'OS', 'sasho.gramatikov', 'sasho.gramatikov'),
          (9, '2024', '2024-25-S', 'KI', 'milos.jovanovik', 'milos.jovanovik'),
          (10, '2024', '2024-25-S', 'KNIO', 'goran.velinov', 'goran.velinov');

-- Data for table `student`
INSERT INTO student
(student_index, email, last_name, "name", parent_name, study_program_code)
VALUES
    ('1612023', 'aleksandar.petrov@students.finki.ukim.mk', 'Петров', 'Александар', 'Петров', 'KN23_1'),
    ('1622023', 'marina.ivanov@students.finki.ukim.mk', 'Иванов', 'Марина', 'Иванов', 'SI23_2'),
    ('1632023', 'nikola.jovanov@students.finki.ukim.mk', 'Јованов', 'Никола', 'Јованов', 'PIT23_3'),
    ('1642023', 'petar.stojanov@students.finki.ukim.mk', 'Стојанов', 'Петар', 'Стојанов', 'KN23'),
    ('1652023', 'davor.tasev@students.finki.ukim.mk', 'Тасев', 'Давор', 'Тасев', 'PIT23'),
    ('1662023', 'jelena.kostov@students.finki.ukim.mk', 'Костов', 'Јелена', 'Костов', 'KN23_1'),
    ('1672023', 'martin.mitrev@students.finki.ukim.mk', 'Митрев', 'Мартин', 'Митрев', 'SI23_2'),
    ('1682023', 'katerina.jankovska@students.finki.ukim.mk', 'Јанковска', 'Катерина', 'Јанковска', 'PIT23_3'),
    ('1692023', 'goran.petrov@students.finki.ukim.mk', 'Петров', 'Горан', 'Петров', 'KN23'),
    ('1702023', 'sonja.iliev@students.finki.ukim.mk', 'Илиев', 'Сонја', 'Илиев', 'PIT23'),
    ('1712023', 'bojana.kocevska@students.finki.ukim.mk', 'Коцевска', 'Бојана', 'Коцевска', 'KN23_1'),
    ('1722023', 'kristina.mladenovska@students.finki.ukim.mk', 'Младеновска', 'Кристина', 'Младеновска', 'SI23_2'),
    ('1732023', 'nikola.nikolovski@students.finki.ukim.mk', 'Николовски', 'Никола', 'Николовски', 'PIT23_3'),
    ('1742023', 'silvana.ivanovska@students.finki.ukim.mk', 'Ивановска', 'Силвана', 'Ивановска', 'KN23'),
    ('1752023', 'liljana.anderova@students.finki.ukim.mk', 'Андерова', 'Лилјана', 'Андерова', 'PIT23'),
    ('1762023', 'milan.stevanov@students.finki.ukim.mk', 'Стеванов', 'Милан', 'Стеванов', 'KN23_1'),
    ('1772023', 'vojdan.trifonov@students.finki.ukim.mk', 'Трифонов', 'Војдан', 'Трифонов', 'SI23_2'),
    ('1782023', 'mirjana.kolev@students.finki.ukim.mk', 'Колев', 'Мирјана', 'Колев', 'PIT23_3'),
    ('1792023', 'stefan.petrov@students.finki.ukim.mk', 'Петров', 'Стефан', 'Петров', 'KN23'),
    ('1802023', 'sonja.iliev2@students.finki.ukim.mk', 'Илиевска', 'Сонја', 'Илиевска', 'PIT23'),
    ('1812023', 'ivana.nikolic@students.finki.ukim.mk', 'Николиќ', 'Ивана', 'Николиќ', 'KN23_1'),
    ('1822023', 'ragena.mitrova@students.finki.ukim.mk', 'Митрова', 'Рагена', 'Митрова', 'SI23_2'),
    ('1832023', 'marina.trifonovska@students.finki.ukim.mk', 'Трифоновска', 'Марина', 'Трифоновска', 'PIT23_3'),
    ('1842023', 'davor.petrov@students.finki.ukim.mk', 'Петров', 'Давор', 'Петров', 'KN23'),
    ('1852023', 'goran.kostov@students.finki.ukim.mk', 'Костов', 'Горан', 'Костов', 'PIT23'),
    ('1862023', 'nikola.jovanov2@students.finki.ukim.mk', 'Јованов', 'Никола', 'Јованов', 'KN23_1'),
    ('1872023', 'petar.stojanov2@students.finki.ukim.mk', 'Стојанов', 'Петар', 'Стојанов', 'SI23_2'),
    ('1882023', 'davor.tasev2@students.finki.ukim.mk', 'Тасев', 'Давор', 'Тасев', 'PIT23_3'),
    ('1892023', 'jelena.kostov2@students.finki.ukim.mk', 'Костов', 'Јелена', 'Костов', 'KN23'),
    ('1902023', 'martin.nikoloski@students.finki.ukim.mk', 'Николовски', 'Мартин', 'Николовски', 'PIT23');

-- Data for table `course_rooms`
INSERT INTO course_rooms (course_id, rooms_name)
VALUES
    (1, 'Амф П'),
    (2, 'Амф МФ'),
    (3, '223'),
    (4, '225'),
    (5, 'Б 2.2'),
    (6, 'Б 3.2'),
    (7, 'Амф П'),   -- истиот простор како кај курс 1, за тестирање на распоредот
    (8, 'Б 2.2'),   -- истиот простор како кај курс 5, за тестирање на распоредот
    (9, 'Амф ТМФ'),
    (10, 'Б1');

-- Data for table `scheduled_class_session`
INSERT INTO public.scheduled_class_session
(id, course_id, room_name, type, start_time, end_time, day_of_week, semester_code)
VALUES
    (1, 1, 'Амф П', 'lecture', '09:00', '09:45', 1, '2024-25-S'),
    (2, 2, 'Амф МФ', 'lecture', '10:00', '10:45', 1, '2024-25-S'),
    (3, 3, '223', 'lecture', '11:00', '11:45', 1, '2024-25-S'),
    (4, 4, '225', 'lecture', '12:00', '12:45', 1, '2024-25-S'),
    -- Курс 8: истата сала како курс 5 (Б 2.2) но со различен временски слотов, Понеделник 16:00-16:45
    (5, 5, 'Б 2.2', 'lecture', '13:00', '13:45', 1, '2024-25-S'),
    (6, 6, 'Б 3.2', 'lecture', '14:00', '14:45', 1, '2024-25-S'),
    (7, 7, 'Амф П', 'lecture', '15:00', '15:45', 1, '2024-25-S'),
    -- Курс 8: истата сала како курс 5 (Б 2.2) но со различен временски слотов, Понеделник 16:00-16:45
    (8, 8, 'Б 2.2', 'lecture', '16:00', '16:45', 1, '2024-25-S'),
    (9, 9, 'Амф ТМФ', 'lecture', '09:00', '09:45', 2, '2024-25-S'),
    (10, 10, 'Б1', 'lecture', '10:00', '10:45', 2, '2024-25-S');

-- Data for table `professor_class_session`
INSERT INTO public.professor_class_session
(id, professor_id, scheduled_class_session_id, date)
VALUES
    (1, 'igor.mishkovski', 1, '2025-03-11'),
    (2, 'sasho.gramatikov', 2, '2025-03-11'),
    (3, 'aleksandra.popovska', 3, '2025-03-11'),
    (4, 'aleksandra.popovska', 4, '2025-03-11'),
    (5, 'dimitar.kitanovski', 5, '2025-03-11'),
    (6, 'vlatko.spasev', 6, '2025-03-11'),
    (7, 'igor.mishkovski', 7, '2025-03-11'),
    (8, 'sasho.gramatikov', 8, '2025-03-11'),
    (9, 'milos.jovanovik', 9, '2025-03-12'),
    (10, 'goran.velinov', 10, '2025-03-12');

-- Data for table `student_semester_enrollment`
INSERT INTO public.student_semester_enrollment
(id, semester_code, student_student_index, valid)
VALUES
    (1, '2024-25-S', '1612023', true),
    (2, '2024-25-S', '1622023', true),
    (3, '2024-25-S', '1632023', true),
    (4, '2024-25-S', '1642023', true),
    (5, '2024-25-S', '1652023', true),
    (6, '2024-25-S', '1662023', true),
    (7, '2024-25-S', '1672023', true),
    (8, '2024-25-S', '1682023', true),
    (9, '2024-25-S', '1692023', true),
    (10, '2024-25-S', '1702023', true),
    (11, '2024-25-S', '1712023', true),
    (12, '2024-25-S', '1722023', true),
    (13, '2024-25-S', '1732023', true),
    (14, '2024-25-S', '1742023', true),
    (15, '2024-25-S', '1752023', true),
    (16, '2024-25-S', '1762023', true),
    (17, '2024-25-S', '1772023', true),
    (18, '2024-25-S', '1782023', true),
    (19, '2024-25-S', '1792023', true),
    (20, '2024-25-S', '1802023', true),
    (21, '2024-25-S', '1812023', true),
    (22, '2024-25-S', '1822023', true),
    (23, '2024-25-S', '1832023', true),
    (24, '2024-25-S', '1842023', true),
    (25, '2024-25-S', '1852023', true),
    (26, '2024-25-S', '1862023', true),
    (27, '2024-25-S', '1872023', true),
    (28, '2024-25-S', '1882023', true),
    (29, '2024-25-S', '1892023', true),
    (30, '2024-25-S', '1902023', true);

-- Data for table `student_subject_enrollment`
INSERT INTO public.student_subject_enrollment
(id, semester_code, student_student_index, subject_id, valid, joined_subject_abbreviation, professor_id, course_id)
VALUES
    -- Студент 1612023 е запишан во AOK и OS
    (1, '2024-25-S', '1612023', 'F23L1S003', true, 'AOK', 'igor.mishkovski', 1),
    (2, '2024-25-S', '1612023', 'F23L2S017', true, 'OS', 'sasho.gramatikov', 2),

    -- Студент 1622023 е запишан во AOK и BS
    (3, '2024-25-S', '1622023', 'F23L1S003', true, 'AOK', 'igor.mishkovski', 1),
    (4, '2024-25-S', '1622023', 'F23L1S023', true, 'BS', 'aleksandra.popovska', 3),

    -- Студент 1632023 е запишан во OS и K2
    (5, '2024-25-S', '1632023', 'F23L2S017', true, 'OS', 'sasho.gramatikov', 2),
    (6, '2024-25-S', '1632023', 'F23L2S034', true, 'K2', 'aleksandra.popovska', 4),

    -- Студент 1642023 е запишан во K2 и ONVD
    (7, '2024-25-S', '1642023', 'F23L2S034', true, 'K2', 'aleksandra.popovska', 4),
    (8, '2024-25-S', '1642023', 'F23L1S146', true, 'ONVD', 'dimitar.kitanovski', 5),

    -- Студент 1652023 е запишан во ONVD и OOP
    (9, '2024-25-S', '1652023', 'F23L1S146', true, 'ONVD', 'dimitar.kitanovski', 5),
    (10, '2024-25-S', '1652023', 'F23L1S016', true, 'OOP', 'vlatko.spasev', 6),

    -- Студент 1662023 е запишан во OOP и OS
    (11, '2024-25-S', '1662023', 'F23L1S016', true, 'OOP', 'vlatko.spasev', 6),
    (12, '2024-25-S', '1662023', 'F23L2S017', true, 'OS', 'igor.mishkovski', 7),

    -- Студент 1672023 е запишан во OS и KI
    (13, '2024-25-S', '1672023', 'F23L2S017', true, 'OS', 'sasho.gramatikov', 8),
    (14, '2024-25-S', '1672023', 'F23L3S118', true, 'KI', 'milos.jovanovik', 9),

    -- Студент 1682023 е запишан во KI и KNIO
    (15, '2024-25-S', '1682023', 'F23L3S118', true, 'KI', 'milos.jovanovik', 9),
    (16, '2024-25-S', '1682023', 'F23L2S119', true, 'KNIO', 'goran.velinov', 10),

    -- Студент 1692023 е запишан во KNIO и AOK
    (17, '2024-25-S', '1692023', 'F23L2S119', true, 'KNIO', 'goran.velinov', 10),
    (18, '2024-25-S', '1692023', 'F23L1S003', true, 'AOK', 'igor.mishkovski', 1),

    -- Повторување на шаблонот за останатите студенти
    (19, '2024-25-S', '1702023', 'F23L1S003', true, 'AOK', 'igor.mishkovski', 1),
    (20, '2024-25-S', '1702023', 'F23L2S017', true, 'OS', 'sasho.gramatikov', 2),

    (21, '2024-25-S', '1712023', 'F23L1S023', true, 'BS', 'aleksandra.popovska', 3),
    (22, '2024-25-S', '1712023', 'F23L2S034', true, 'K2', 'aleksandra.popovska', 4),

    (23, '2024-25-S', '1722023', 'F23L1S146', true, 'ONVD', 'dimitar.kitanovski', 5),
    (24, '2024-25-S', '1722023', 'F23L1S016', true, 'OOP', 'vlatko.spasev', 6),

    (25, '2024-25-S', '1732023', 'F23L2S017', true, 'OS', 'igor.mishkovski', 7),
    (26, '2024-25-S', '1732023', 'F23L3S118', true, 'KI', 'milos.jovanovik', 9),

    (27, '2024-25-S', '1742023', 'F23L2S119', true, 'KNIO', 'goran.velinov', 10),
    (28, '2024-25-S', '1742023', 'F23L1S003', true, 'AOK', 'igor.mishkovski', 1),

    (29, '2024-25-S', '1752023', 'F23L2S017', true, 'OS', 'sasho.gramatikov', 2),
    (30, '2024-25-S', '1752023', 'F23L1S023', true, 'BS', 'aleksandra.popovska', 3);

-- Data for table `student_attendance`
INSERT INTO public.student_attendance(id, student_student_index, professor_class_session_id, arrival_time)
VALUES
    -- Students not attending
    -- Student '1692023' from AOK class (professor_class_session_id = 1)
    -- Student '1752023' from OS class (professor_class_session_id = 2)
    -- Student '1662023' from OOP class (professor_class_session_id = 6)
    -- Student '1732023' from KI class (professor_class_session_id = 9)

    -- Студенти кои посетуваат AOK (професор igor.mishkovski, professor_class_session_id = 1)
    (1, '1612023', 1, '2025-03-11 09:02:00'),
    (2, '1622023', 1, '2025-03-11 09:00:00'),
    (3, '1702023', 1, '2025-03-11 09:01:00'),
    (4, '1742023', 1, '2025-03-11 09:03:00'),

    -- Студенти кои посетуваат OS (професор sasho.gramatikov, professor_class_session_id = 2)
    (5, '1612023', 2, '2025-03-11 10:00:00'),
    (6, '1632023', 2, '2025-03-11 10:02:00'),
    (7, '1702023', 2, '2025-03-11 10:01:00'),

    -- Студенти кои посетуваат BS (професор aleksandra.popovska, professor_class_session_id = 3)
    (8, '1622023', 3, '2025-03-11 11:00:00'),
    (9, '1712023', 3, '2025-03-11 11:01:00'),
    (10, '1752023', 3, '2025-03-11 11:02:00'),

    -- Студенти кои посетуваат K2 (професор aleksandra.popovska, professor_class_session_id = 4)
    (11, '1632023', 4, '2025-03-11 12:00:00'),
    (12, '1642023', 4, '2025-03-11 12:01:00'),
    (13, '1712023', 4, '2025-03-11 12:03:00'),

    -- Студенти кои посетуваат ONVD (професор dimitar.kitanovski, professor_class_session_id = 5)
    (14, '1642023', 5, '2025-03-11 13:00:00'),
    (15, '1652023', 5, '2025-03-11 13:01:00'),
    (16, '1722023', 5, '2025-03-11 13:02:00'),

    -- Студенти кои посетуваат OOP (професор vlatko.spasev, professor_class_session_id = 6)
    (17, '1652023', 6, '2025-03-11 14:00:00'),
    (18, '1722023', 6, '2025-03-11 14:03:00'),

    -- Студенти кои посетуваат OS (професор igor.mishkovski, professor_class_session_id = 7)
    (19, '1662023', 7, '2025-03-11 15:00:00'),
    (20, '1732023', 7, '2025-03-11 15:01:00'),

    -- Студенти кои посетуваат OS (професор sasho.gramatikov, professor_class_session_id = 8)
    (21, '1672023', 8, '2025-03-11 16:00:00'),

    -- Студенти кои посетуваат KI (професор milos.jovanovik, professor_class_session_id = 9)
    (22, '1672023', 9, '2025-03-12 09:00:00'),
    (23, '1682023', 9, '2025-03-12 09:01:00'),

    -- Студенти кои посетуваат KNIO (професор goran.velinov, professor_class_session_id = 10)
    (24, '1682023', 10, '2025-03-12 10:00:00'),
    (25, '1692023', 10, '2025-03-12 10:01:00'),
    (36, '1742023', 10, '2025-03-12 10:02:00');
