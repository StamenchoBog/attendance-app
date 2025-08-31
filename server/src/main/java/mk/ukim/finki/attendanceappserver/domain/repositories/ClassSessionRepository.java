package mk.ukim.finki.attendanceappserver.domain.repositories;

import mk.ukim.finki.attendanceappserver.dto.db.ClassSessionOverview;
import mk.ukim.finki.attendanceappserver.dto.db.ProfessorClassSession;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Repository
public interface ClassSessionRepository extends R2dbcRepository<mk.ukim.finki.attendanceappserver.domain.models.ProfessorClassSession, Integer> {

    Mono<mk.ukim.finki.attendanceappserver.domain.models.ProfessorClassSession> getProfessorClassSessionsByScheduledClassSessionId(@NonNull int scheduledClassSessionId);

    Mono<mk.ukim.finki.attendanceappserver.domain.models.ProfessorClassSession> findByAttendanceToken(String attendanceToken);

    @Query("""
        SELECT pcs.id as professor_class_session_id, scs.id as scheduled_class_session_id,
                su.id as subject_id, su.name as subject_name, scs."type", scs.room_name, pcs.date, scs.start_time, scs.end_time
        from professor_class_session pcs
        join scheduled_class_session scs on pcs.scheduled_class_session_id = scs.id
        join course c on scs.course_id = c.id
        join joined_subject js on c.joined_subject_abbreviation = js.abbreviation
        join subject su on js.main_subject_id = su.id
        where pcs.professor_id = :professorId and pcs."date" = :date;
    """)
    Flux<ProfessorClassSession> getClassSessionByProfessorForDate(@NonNull String professorId, @NonNull LocalDate date);

    @Query("""
        SELECT pcs.id as professor_class_session_id, scs.id as scheduled_class_session_id,
                scs."type", scs.room_name, pcs.date, scs.start_time, scs.end_time
        FROM professor_class_session pcs
        JOIN scheduled_class_session scs ON pcs.scheduled_class_session_id = scs.id
        JOIN course c ON scs.course_id = c.id
        JOIN joined_subject js ON c.joined_subject_abbreviation = js.abbreviation
        WHERE pcs.professor_id = :professorId AND pcs.date BETWEEN :startDate AND :endDate;
    """)
    Flux<ProfessorClassSession> getProfessorClassSessionsByProfessorIdFromDateToDate(@NonNull String professorId, @NonNull LocalDate startDate, @NonNull LocalDate endDate);

    @Query("""
        SELECT DISTINCT
            pcs.id AS professor_class_session_id,
            scs.id AS scheduled_class_session_id,
            p.id AS professor_id,
            p.name AS professor_name,
            c.id AS course_id,
            su.id AS subject_id,
            su.name AS subject_name,
            pcs.date AS class_date,
            scs."type" AS class_type,
            scs.room_name AS class_room_name,
            scs.start_time AS class_start_time,
            scs.end_time AS class_end_time,
            CASE WHEN :time::time BETWEEN scs.start_time AND scs.end_time THEN true ELSE false END AS has_class_started,
            COALESCE(sa.status, 'not_attended') AS attendance_status
        FROM student_subject_enrollment sse
        JOIN student s ON sse.student_student_index = s.student_index
        JOIN course c ON sse.course_id = c.id
        JOIN subject su ON sse.subject_id = su.id
        JOIN scheduled_class_session scs ON c.id = scs.course_id
        JOIN professor_class_session pcs ON scs.id = pcs.scheduled_class_session_id
        JOIN professor p ON pcs.professor_id = p.id
        JOIN student_semester_enrollment sse2 ON s.student_index = sse2.student_student_index
        LEFT JOIN student_attendance sa ON sa.student_student_index = s.student_index
            AND sa.professor_class_session_id = pcs.id
        WHERE s.student_index = :studentIndex
          AND pcs.date = :date
          AND (:time::time BETWEEN scs.start_time AND scs.end_time OR scs.start_time > :time::time)
          AND sse2.valid = true
        ORDER BY class_start_time;
    """)
    Flux<ClassSessionOverview> getClassSessionByStudentForDateAndTime(@NonNull String studentIndex, @NonNull LocalDate date, @NonNull LocalTime time);
    @Query("UPDATE professor_class_session SET attendance_token = :token, token_expiration_time = :expirationTime WHERE id = :id")
    Mono<Void> updateAttendanceToken(int id, String token, LocalDateTime expirationTime);
}