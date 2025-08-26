package mk.ukim.finki.attendanceappserver.config;

import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.repositories.models.*;
import org.reactivestreams.Publisher;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.r2dbc.mapping.OutboundRow;
import org.springframework.data.r2dbc.mapping.event.BeforeSaveCallback;
import org.springframework.data.relational.core.sql.SqlIdentifier;
import reactor.core.publisher.Mono;

import java.util.Set;

@Configuration
public class PersistenceConfig {

    @Bean
    public BeforeSaveCallback<Object> beforeSaveCallback() {
        return new PreventAnyUpdateCallback();
    }

    private static class PreventAnyUpdateCallback implements BeforeSaveCallback<Object> {

        private static final Set<Class<?>> READ_ONLY_ENTITIES = Set.of(
            Course.class,
            CourseRooms.class,
            CourseStudentGroups.class,
            ExamDefinition.class,
            JoinedSubject.class,
            Professor.class,
            ProfessorEngagement.class,
            Room.class,
            ScheduledClassSession.class,
            Semester.class,
            Student.class,
            StudentGroup.class,
            StudentSemesterEnrollment.class,
            StudentSubjectEnrollment.class,
            StudyProgram.class,
            StudyProgramSubject.class,
            StudyProgramSubjectProfessor.class,
            Subject.class,
            SubjectExam.class,
            SubjectExamRooms.class,
            TeacherSubject.class,
            TeacherSubjectAllocation.class,
            YearExamSession.class
        );

        @Override
        public @NonNull Publisher<Object> onBeforeSave(Object entity, OutboundRow outboundRow, SqlIdentifier table) {
            if (READ_ONLY_ENTITIES.contains(entity.getClass())) {
                return Mono.error(new IllegalStateException("Entity of type " + entity.getClass().getSimpleName() + " is read-only and cannot be saved."));
            }
            return Mono.just(entity);
        }
    }
}
