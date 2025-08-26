package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.services.PresentationCacheService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import reactor.core.publisher.Mono;

import java.util.Base64;
import java.util.Optional;

@Controller
@AllArgsConstructor
public class WebController {

    private final PresentationCacheService presentationCacheService;

    @GetMapping(value = "/p/{shortKey}", produces = MediaType.TEXT_HTML_VALUE)
    @ResponseBody
    public Mono<ResponseEntity<String>> getPresentationPage(@PathVariable String shortKey) {
        return Mono.just(Optional.ofNullable(presentationCacheService.get(shortKey)))
                .map(qrBytes -> {
                    if (qrBytes.isPresent()) {
                        String base64Image = Base64.getEncoder().encodeToString(qrBytes.get());
                        String html = "<html><body style='margin:0; background:#f0f0f0; display:flex; align-items:center; justify-content:center;'><img src='data:image/png;base64," + base64Image + "'/></body></html>";
                        return ResponseEntity.ok(html);
                    } else {
                        return ResponseEntity.notFound().build();
                    }
                });
    }
}
