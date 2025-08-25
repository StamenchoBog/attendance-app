package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.GenerateQRCodeRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.PresentationSessionDTO;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.services.PresentationCacheService;
import mk.ukim.finki.attendanceappserver.services.QRCodeGeneratorService;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/presentation")
@AllArgsConstructor
public class PresentationController {

    private final PresentationCacheService presentationCacheService;
    private final QRCodeGeneratorService qrCodeGeneratorService;

    @PostMapping("/{sessionId}")
    public Mono<APIResponse<PresentationSessionDTO>> createPresentationSession(@PathVariable Integer sessionId) {
        String shortKey = UUID.randomUUID().toString().substring(0, 8);
        GenerateQRCodeRequestDTO dto = GenerateQRCodeRequestDTO.builder()
                .professorClassSessionId(sessionId)
                .build();
        return qrCodeGeneratorService.generateQRCode(dto)
                .map(qrBytes -> {
                    presentationCacheService.put(shortKey, qrBytes);
                    PresentationSessionDTO responseDto = new PresentationSessionDTO(shortKey, qrBytes);
                    return APIResponse.success(responseDto);
                });
    }
}
