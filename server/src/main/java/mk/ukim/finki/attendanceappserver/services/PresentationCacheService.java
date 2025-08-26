package mk.ukim.finki.attendanceappserver.services;

import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class PresentationCacheService {

    @CachePut(value = "presentations", key = "#key")
    public byte[] put(String key, byte[] value) {
        return value;
    }

    @Cacheable(value = "presentations", key = "#key")
    public byte[] get(String key) {
        // This method is backed by the cache. If the key is not found, Spring will return null.
        return null;
    }
}
