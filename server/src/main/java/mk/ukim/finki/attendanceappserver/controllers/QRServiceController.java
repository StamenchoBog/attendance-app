package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.GenerateQRCodeRequestDTO;
import mk.ukim.finki.attendanceappserver.services.QRCodeGeneratorService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/qr")
@AllArgsConstructor
public class QRServiceController {

    private static final Logger LOGGER = LoggerFactory.getLogger(QRServiceController.class);

    private QRCodeGeneratorService qrCodeGeneratorService;

    @PostMapping("/generateQR")
    public Mono<ResponseEntity<byte[]>> generateQRCode(@RequestBody GenerateQRCodeRequestDTO dto) {
        return Mono.fromCallable(() -> qrCodeGeneratorService.generateQRCode(dto))
                .map(qrCodeBytes -> {
                    HttpHeaders headers = new HttpHeaders();
                    headers.setContentType(MediaType.IMAGE_PNG);
                    LOGGER.info("QR code for attendance verification has been generated.");
                    return ResponseEntity.ok().headers(headers).body(qrCodeBytes);
                })
                .onErrorResume(e -> {
                    LOGGER.error("Error generating QR code: {}", e.getMessage());
                    return Mono.just(ResponseEntity.badRequest().body(null));
                });
    }
}
