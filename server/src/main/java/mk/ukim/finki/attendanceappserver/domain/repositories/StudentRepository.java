package mk.ukim.finki.attendanceappserver.domain.repositories;

import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.domain.models.Student;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigInteger;

@Repository
public interface StudentRepository extends R2dbcRepository<Student, String> {

    Mono<Student> findByStudentIndex(@NonNull String studentIndex);

    @Query("""
        SELECT count(*)
        FROM student s
        INNER JOIN student_semester_enrollment sse ON sse.student_student_index = s.student_index
        WHERE s.student_index = :studentIndex AND sse.valid = true
    """)
    Mono<BigInteger> checkStudentValidity(@NonNull String studentIndex);

    /*
     Find students which are enrolled in subject (with active semester enrollment) which professor with ID teaches.
     */
    @Query("""
        SELECT DISTINCT s.*
        FROM public.teacher_subject_allocations tsa
        JOIN public.joined_subject_codes jsc ON tsa.subject_id = jsc.joined_subject_abbreviation
        JOIN public.student_subject_enrollment sse ON jsc.subject_id = sse.subject_id
        JOIN public.student s ON sse.student_student_index = s.student_index
        JOIN public.student_semester_enrollment sse2 ON s.student_index = sse2.student_student_index
        WHERE tsa.professor_id = :professorId AND sse2.valid = true;
    """)
    Flux<Student> findStudentsEnrolledOnSubjectsWithProfessorId(@NonNull String professorId);
}
