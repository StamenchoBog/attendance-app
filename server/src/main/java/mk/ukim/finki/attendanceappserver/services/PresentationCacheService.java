package mk.ukim.finki.attendanceappserver.services;

import org.springframework.stereotype.Service;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Optional;

@Service
public class PresentationCacheService {

    // This cache now stores the generated QR code image bytes directly.
    private final ConcurrentHashMap<String, byte[]> cache = new ConcurrentHashMap<>();

    public void put(String key, byte[] value) {
        // In a production scenario, you would add an expiration policy here.
        cache.put(key, value);
    }

    public Optional<byte[]> get(String key) {
        return Optional.ofNullable(cache.get(key));
    }
}
