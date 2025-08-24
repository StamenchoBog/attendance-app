package mk.ukim.finki.attendanceappserver.services;

import org.springframework.stereotype.Service;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Optional;

@Service
public class PresentationCacheService {

    private final ConcurrentHashMap<String, Integer> cache = new ConcurrentHashMap<>();

    public void put(String key, Integer value) {
        // In a production scenario, you would add an expiration policy here.
        // For this implementation, the cache is ephemeral and will be cleared on restart.
        cache.put(key, value);
    }

    public Optional<Integer> get(String key) {
        return Optional.ofNullable(cache.get(key));
    }
}
