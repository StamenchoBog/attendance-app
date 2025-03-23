package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.dto.db.CustomProfessorClassSession;
import mk.ukim.finki.attendanceappserver.repositories.models.ProfessorClassSession;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;

@Repository
public interface ProfessorClassSessionRepository extends ReactiveCrudRepository<ProfessorClassSession, Integer> {

    Mono<ProfessorClassSession> getProfessorClassSessionsByScheduledClassSessionId(@NonNull int scheduledClassSessionId);

    @Query("""
        SELECT pcs.id as professor_scheduled_class_session_id, scs.id as scheduled_class_session_id,
                scs."type", scs.room_name, pcs.date, scs.start_time, scs.end_time
        from professor_class_session pcs
        join scheduled_class_session scs on pcs.scheduled_class_session_id = scs.id
        join course c on scs.course_id = c.id
        join joined_subject js on c.joined_subject_abbreviation = js.abbreviation
        where pcs.professor_id = :professorId and pcs."date" = :date;
    """)
    Flux<CustomProfessorClassSession> getClassSessionByProfessorForDate(@NonNull String professorId, @NonNull String date);

    @Query("""
        SELECT pcs.id as professor_scheduled_class_session_id, scs.id as scheduled_class_session_id,
                scs."type", scs.room_name, pcs.date, scs.start_time, scs.end_time
        FROM professor_class_session pcs
        JOIN scheduled_class_session scs ON pcs.scheduled_class_session_id = scs.id
        JOIN course c ON scs.course_id = c.id
        JOIN joined_subject js ON c.joined_subject_abbreviation = js.abbreviation
        WHERE pcs.professor_id = :professorId AND pcs.date BETWEEN :startDate AND :endDate;
    """)
    Flux<CustomProfessorClassSession> getProfessorClassSessionsByProfessorIdFromDateToDate(@NonNull String professorId, @NonNull LocalDate startDate, @NonNull LocalDate endDate);


    //TODO: Try to use it or fix it
    @Query("""
        SELECT pcs.id as professor_scheduled_class_session_id, scs.id as scheduled_class_session_id,
                scs."type", scs.room_name, pcs.date, scs.start_time, scs.end_time, scs.day_of_week
        from professor_class_session pcs
        join scheduled_class_session scs on pcs.scheduled_class_session_id = scs.id
        join course c on scs.course_id = c.id
        join joined_subject js on c.joined_subject_abbreviation = js.abbreviation
        where pcs.professor_id = :professorId and (
                SELECT count(*)
                FROM jsonb_array_elements(js.codes) AS elem
                CROSS JOIN LATERAL UNNEST(string_to_array(elem ->> 'code', ';')) AS code
                WHERE code = :subjectId
            ) > 0;
    """)
    Flux<CustomProfessorClassSession> getClassSessionBySubjectAndProfessorForCurrentDate(@NonNull String subjectId, @NonNull String professorId);
}
