package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.GenerateQRCodeRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.services.PresentationCacheService;
import mk.ukim.finki.attendanceappserver.services.QRCodeGeneratorService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.Base64;
import java.util.UUID;

@RestController
@AllArgsConstructor
public class PresentationController {

    private final PresentationCacheService presentationCacheService;
    private final QRCodeGeneratorService qrCodeGeneratorService;

    @PostMapping("/api/presentation/{sessionId}")
    public Mono<APIResponse<String>> createPresentationSession(@PathVariable Integer sessionId) {
        String shortKey = UUID.randomUUID().toString().substring(0, 8);
        presentationCacheService.put(shortKey, sessionId);
        return Mono.just(APIResponse.success(shortKey));
    }

    @GetMapping(value = "/p/{shortKey}", produces = MediaType.TEXT_HTML_VALUE)
    public Mono<ResponseEntity<String>> getPresentationPage(@PathVariable String shortKey) {
        return presentationCacheService.get(shortKey)
                .map(sessionId -> qrCodeGeneratorService.generateQRCode(
                                GenerateQRCodeRequestDTO.builder()
                                        .professorClassSessionId(sessionId)
                                        .build()
                                )
                        .map(qrBytes -> {
                            String base64Image = Base64.getEncoder().encodeToString(qrBytes);
                            String html = "<html><body style='margin:0; background:#f0f0f0; display:flex; align-items:center; justify-content:center;'><img src='data:image/png;base64," + base64Image + "'/></body></html>";
                            return ResponseEntity.ok().body(html);
                        })
                )
                .orElse(Mono.just(ResponseEntity.notFound().build()));
    }
}
