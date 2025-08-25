package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.dto.db.CustomStudentAttendance;
import mk.ukim.finki.attendanceappserver.repositories.models.StudentAttendance;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;

@Repository
public interface StudentAttendanceRepository extends ReactiveCrudRepository<StudentAttendance, Integer> {

    @Query("""
        SELECT sa.id as student_attendance_id, sa.student_student_index as student_index,
                s.name as student_name, s.study_program_code,
                pcs.professor_id as professor_id, p.name as professor_name,
                professor_class_session_id, scheduled_class_session_id, scs.course_id as course_id,
                pcs.date as class_date, scs.type as class_type, scs.room_name as class_room_name,
                scs.start_time as class_start_time, scs.end_time as class_end_time,
                pcs.professor_arrival_time as professor_arrival_time, sa.arrival_time as student_arrival_time
        FROM student_attendance sa
        INNER JOIN student s ON sa.student_student_index = s.student_index
        INNER JOIN professor_class_session pcs ON sa.professor_class_session_id = pcs.id
        INNER JOIN scheduled_class_session scs ON pcs.scheduled_class_session_id = scs.id
        INNER JOIN professor p ON pcs.professor_id = p.id
        WHERE sa.id = :studentAttendanceId
    """)
    Mono<CustomStudentAttendance> getStudentAttendanceById(@NonNull int studentAttendanceId);

    @Query("""
        SELECT sa.id as student_attendance_id, sa.student_student_index as student_index,
                s.name as student_name, s.study_program_code,
                pcs.professor_id as professor_id, p.name as professor_name,
                professor_class_session_id, scheduled_class_session_id, scs.course_id as course_id,
                pcs.date as class_date, scs.type as class_type, scs.room_name as class_room_name,
                scs.start_time as class_start_time, scs.end_time as class_end_time,
                pcs.professor_arrival_time as professor_arrival_time, sa.arrival_time as student_arrival_time
        FROM student_attendance sa
        INNER JOIN student s ON sa.student_student_index = s.student_index
        INNER JOIN professor_class_session pcs ON sa.professor_class_session_id = pcs.id
        INNER JOIN scheduled_class_session scs ON pcs.scheduled_class_session_id = scs.id
        INNER JOIN professor p ON pcs.professor_id = p.id
        WHERE sa.professor_class_session_id = :professorClassSessionId AND sa.status = 'PRESENT'
    """)
    Flux<CustomStudentAttendance> getStudentAttendanceByProfessorClassSessionId(@NonNull int professorClassSessionId);

    @Query("""
        SELECT sa.id as student_attendance_id, pcs.professor_id as professor_id, p.name as professor_name,
               professor_class_session_id, scheduled_class_session_id, scs.course_id as course_id,
               pcs.date as class_date, scs.type as class_type, scs.room_name as class_room_name,
               scs.start_time as class_start_time, scs.end_time as class_end_time,
               pcs.professor_arrival_time as professorArrivalTime, sa.arrival_time as studentArrivalTime
        FROM student_attendance sa
        INNER JOIN professor_class_session pcs ON sa.professor_class_session_id = pcs.id
        INNER JOIN scheduled_class_session scs ON pcs.scheduled_class_session_id = scs.id
        INNER JOIN professor p ON pcs.professor_id = p.id
        WHERE sa.student_student_index = :studentIndex AND pcs.date BETWEEN :startDate AND :endDate
    """)
    Flux<CustomStudentAttendance> getStudentAttendanceByStudentIndexFromDateToDate(@NonNull String studentIndex, @NonNull LocalDate startDate, @NonNull LocalDate endDate);

    Mono<Boolean> existsStudentAttendanceByStudentIndexAndProfessorClassSessionId(String studentIndex, int professorClassSessionId);
    @Query("UPDATE student_attendance SET status = 'PENDING_VERIFICATION' WHERE professor_class_session_id = :professorClassSessionId")
    Mono<Void> resetAttendanceStatusForSession(int professorClassSessionId);
}
