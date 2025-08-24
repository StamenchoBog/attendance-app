package mk.ukim.finki.attendanceappserver;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.r2dbc.repository.config.EnableR2dbcRepositories;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.data.r2dbc.repository.config.EnableR2dbcRepositories;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
@EnableR2dbcRepositories
@OpenAPIDefinition
public class AttendanceAppServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(AttendanceAppServerApplication.class, args);
	}

}
