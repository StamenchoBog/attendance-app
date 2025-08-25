package mk.ukim.finki.attendanceappserver.services;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.qrcode.QRCodeWriter;
import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.GenerateQRCodeRequestDTO;
import mk.ukim.finki.attendanceappserver.repositories.ClassSessionRepository;
import mk.ukim.finki.attendanceappserver.repositories.StudentAttendanceRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@AllArgsConstructor
public class QRCodeGeneratorService {

    private static final Logger LOGGER = LoggerFactory.getLogger(QRCodeGeneratorService.class);

    private final ClassSessionRepository classSessionRepository;
    private final StudentAttendanceRepository studentAttendanceRepository;

    public Mono<byte[]> generateQRCode(GenerateQRCodeRequestDTO dto) {
        LOGGER.info("Generating QR code for professor class session with ID [{}]", dto.getProfessorClassSessionId());

        return studentAttendanceRepository.resetAttendanceStatusForSession(dto.getProfessorClassSessionId())
                .then(classSessionRepository.findById(dto.getProfessorClassSessionId()))
                .switchIfEmpty(Mono.error(new IllegalArgumentException("ProfessorClassSession not found")))
                .flatMap(session -> {
                    String token = UUID.randomUUID().toString();
                    LocalDateTime expirationTime = LocalDateTime.now().plusMinutes(5); // 5 minute expiration

                    return classSessionRepository.updateAttendanceToken(session.getId(), token, expirationTime)
                            .then(Mono.fromCallable(() -> {
                                try {
                                    var outputStream = new ByteArrayOutputStream();
                                    var writer = new QRCodeWriter();
                                    var bitMatrix = writer.encode(token, BarcodeFormat.QR_CODE, 300, 300);
                                    MatrixToImageWriter.writeToStream(bitMatrix, "PNG", outputStream);
                                    return outputStream.toByteArray();
                                } catch (WriterException | IOException e) {
                                    LOGGER.error("Error generating QR code image: {}", e.getMessage());
                                    throw new RuntimeException(e);
                                }
                            }));
                });
    }
}