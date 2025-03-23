package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@AllArgsConstructor
public class AuthController {

    // TODO: Fix Login endpoints to be used with the mocked CAS system

    private static final Logger LOGGER = LoggerFactory.getLogger(AuthController.class);

    // Mock login of professor
    @GetMapping(value = "/login/{professorId}")
    public void loginAsProfessor(@PathVariable String professorId) {
        LOGGER.info("Login as professor with ID [{}]", professorId);
        // Login as professor
    }

}
