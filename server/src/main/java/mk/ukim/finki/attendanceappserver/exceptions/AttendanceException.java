package mk.ukim.finki.attendanceappserver.exceptions;

/**
 * Exception thrown when there is an issue with attendance operations
 */
public class AttendanceException extends RuntimeException {

    /**
     * Constructs a new AttendanceException with the specified detail message.
     *
     * @param message the detail message
     */
    public AttendanceException(String message) {
        super(message);
    }

    /**
     * Constructs a new AttendanceException with the specified detail message and cause.
     *
     * @param message the detail message
     * @param cause the cause
     */
    public AttendanceException(String message, Throwable cause) {
        super(message, cause);
    }
}
