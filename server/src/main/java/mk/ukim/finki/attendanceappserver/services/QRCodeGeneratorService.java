package mk.ukim.finki.attendanceappserver.services;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.qrcode.QRCodeWriter;
import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.GenerateQRCodeRequestDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.util.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.Instant;

@AllArgsConstructor
@Service
public class QRCodeGeneratorService {

    private static final Logger LOGGER = LoggerFactory.getLogger(QRCodeGeneratorService.class);

    public byte[] generateQRCode(@NonNull GenerateQRCodeRequestDTO dto) throws WriterException, IOException {
        LOGGER.info("Generating QR code for professor class session with ID [{}].", dto.getProfessorClassSessionId());
        var qrCodeText =
                String.format("professorClassSessionId:%s,creationTime:%s",
                        dto.getProfessorClassSessionId(), Instant.now());
        var outputStream = new ByteArrayOutputStream();
        var writer = new QRCodeWriter();
        var bitMatrix = writer.encode(qrCodeText, BarcodeFormat.QR_CODE, 300, 300);
        MatrixToImageWriter.writeToStream(bitMatrix, "PNG", outputStream);
        return outputStream.toByteArray();
    }
}
