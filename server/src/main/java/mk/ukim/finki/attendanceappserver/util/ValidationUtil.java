package mk.ukim.finki.attendanceappserver.util;

import lombok.experimental.UtilityClass;
import mk.ukim.finki.attendanceappserver.exceptions.errors.ResourceCannotBeCreated;
import mk.ukim.finki.attendanceappserver.exceptions.errors.ResourceNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.ObjectUtils;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.List;

@UtilityClass
public class ValidationUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(ValidationUtil.class);

    public static <T> void validate(T request, String... fields) throws NoSuchFieldException, IllegalAccessException {
        List<String> missingFields = new ArrayList<>();

        for (String field : fields) {
            java.lang.reflect.Field declaredField = request.getClass().getDeclaredField(field);
            Object fieldValue = declaredField.get(request);

            if (fieldValue == null || (fieldValue instanceof String && ObjectUtils.isEmpty(fieldValue))) {
                missingFields.add(field);
            }
        }

        if (!missingFields.isEmpty()) {
            throw new ResourceCannotBeCreated("Missing required fields: " + String.join(", ", missingFields));
        }
    }

    public static <T> ResponseEntity<Object> validateCustom(T request, FieldValidation... fieldValidations) {
        List<String> errorMessages = new ArrayList<>();

        for (FieldValidation fieldValidation : fieldValidations) {
            try {
                java.lang.reflect.Field declaredField = request.getClass().getDeclaredField(fieldValidation.getFieldName());
                Object fieldValue = declaredField.get(request);

                String errorMessage = fieldValidation.validate(fieldValue);
                if (errorMessage != null) {
                    errorMessages.add(errorMessage);
                }

            } catch (NoSuchFieldException | IllegalAccessException e) {
                LOGGER.error("Error during validation: {}", e.getMessage(), e);
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error during validation.");
            }
        }

        if (!errorMessages.isEmpty()) {
            return ResponseEntity.badRequest().body(String.join("\n", errorMessages));
        }

        return null;
    }

    public static <T, E> Mono<Void> validateEntityExists(ReactiveCrudRepository<T, E> repository, E entityId) {
        return repository.existsById(entityId)
            .flatMap(exists -> {
                if (Boolean.TRUE.equals(exists)) {
                    return Mono.empty();
                } else {
                    return Mono.error(new ResourceNotFoundException(String.format("Entity with ID [%s] does not exist.", entityId)));
                }
            });
    }

    public interface FieldValidation {
        String getFieldName();
        String validate(Object fieldValue);
    }
}
