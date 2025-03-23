package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;

@Data
@Table(name = "teacher_subject_allocations")
@EntityListeners(PreventAnyUpdate.class)
public class TeacherSubjectAllocation {

    @Id
    @NonNull
    @Column(name = "id")
    private Long id;

    @Column(name = "number_of_exercise_groups")
    private float numberOfExerciseGroups;

    @Column(name = "number_of_lab_groups")
    private float numberOfLabGroups;

    @Column(name = "number_of_lecture_groups")
    private float numberOfLectureGroups;

    @Column(name = "total_exercise_classes")
    private float totalExerciseClasses;

    @Column(name = "total_lab_classes")
    private float totalLabClasses;

    @Column(name = "total_lecture_classes")
    private float totalLectureClasses;

    @ManyToOne(fetch = FetchType.LAZY)
    @Column(name = "professor")
    private Professor professor;

    @ManyToOne(fetch = FetchType.LAZY)
    @Column(name = "semester_code")
    private Semester semester;

    @ManyToOne(fetch = FetchType.LAZY)
    @Column(name = "subject_id")
    private Subject subject;

    @Column(name = "english_group")
    private boolean englishGroup;

    @Column(name = "validation_message", length = 4000)
    private String validationMessage;

    @Column(name = "mentorship_course")
    private boolean mentorshipCourse;
}
