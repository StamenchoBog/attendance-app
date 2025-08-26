package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("teacher_subjects")
public class TeacherSubject {

    @Id
    @NonNull
    @Column("id")
    private Long id;

    @Column("number_of_exercise_groups")
    private float numberOfExerciseGroups;

    @Column("number_of_lab_groups")
    private float numberOfLabGroups;

    @Column("number_of_lecture_groups")
    private float numberOfLectureGroups;

    @Column("total_exercise_classes")
    private float totalExerciseClasses;

    @Column("total_lab_classes")
    private float totalLabClasses;

    @Column("total_lecture_classes")
    private float totalLectureClasses;

    @Column("professor_id")
    private String professorId;

    @Column("semester_code")
    private String semesterCode;

    @Column("subject_id")
    private String subjectId;

    @Column("english_group")
    private boolean englishGroup;

    @Column("validation_message")
    private String validationMessage;

    @Column("mentorship_course")
    private boolean mentorshipCourse;

}
