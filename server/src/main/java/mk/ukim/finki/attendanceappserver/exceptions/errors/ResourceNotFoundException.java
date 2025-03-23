package mk.ukim.finki.attendanceappserver.exceptions.errors;

public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
