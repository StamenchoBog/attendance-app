package mk.ukim.finki.attendanceappserver.repositories.models.converters;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

@Converter
public class StringToSetConverter implements AttributeConverter<Set<String>, String> {

    private static final Logger LOGGER = LoggerFactory.getLogger(StringToSetConverter.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(Set<String> strings) {
        if (strings == null || strings.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(strings);
        } catch (JsonProcessingException ex) {
            LOGGER.error("Cannot convert Set<String> to JSON. Exception: {}", ex.getMessage());
            return null;
        }
    }

    @Override
    public Set<String> convertToEntityAttribute(String s) {
        if (s == null || s.trim().isEmpty()) {
            return Collections.emptySet();
        }
        try {
            return objectMapper.readValue(s, new TypeReference<HashSet<String>>() {});
        } catch (JsonProcessingException ex) {
            LOGGER.error("Cannot convert JSON to Set<String>. Exception: {}", ex.getMessage());
            return Collections.emptySet();
        }
    }
}
