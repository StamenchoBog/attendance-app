# Backend API Server (Spring Boot)

RESTful API server for the FINKI Attendance Application, built with Spring Boot 3 and reactive programming principles.

## 🚀 Overview

This Spring Boot application serves as the central hub for all attendance system operations, providing secure APIs for mobile clients, managing QR code generation, processing attendance verification, and handling automated workflows.

## 🛠 Technologies & Dependencies

### Core Framework
- **Java**: 21 (LTS)
- **Spring Boot**: 3.x
- **Spring WebFlux**: Reactive web framework
- **R2DBC**: Reactive database connectivity
- **PostgreSQL**: Primary database

### Key Dependencies
```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-webflux'
    implementation 'org.springframework.boot:spring-boot-starter-data-r2dbc'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-cache'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    
    // Database
    implementation 'org.postgresql:postgresql'
    implementation 'org.postgresql:r2dbc-postgresql'
    implementation 'org.liquibase:liquibase-core'
    
    // Documentation
    implementation 'org.springdoc:springdoc-openapi-starter-webflux-ui'
    
    // Caching
    implementation 'com.github.ben-manes.caffeine:caffeine'
    
    // QR Code Generation
    implementation 'com.google.zxing:core:3.5.1'
    implementation 'com.google.zxing:javase:3.5.1'
    
    // JWT
    implementation 'io.jsonwebtoken:jjwt-api:0.11.5'
    implementation 'io.jsonwebtoken:jjwt-impl:0.11.5'
    implementation 'io.jsonwebtoken:jjwt-jackson:0.11.5'
}
```

## 🚀 Getting Started

### Prerequisites
- **Java JDK**: 21 or higher
- **Gradle**: 8.5 or higher
- **PostgreSQL**: 14+ (or Docker)
- **Docker**: For containerized deployment

### Installation

1. **Navigate to Server Directory**
   ```bash
   cd server
   ```

2. **Environment Configuration**
   Create `application-dev.yml`:
   ```yaml
   spring:
     r2dbc:
       url: r2dbc:postgresql://localhost:5432/attendance_db
       username: attendance_user
       password: your_password
     
   app:
     jwt:
       secret: your-256-bit-secret-key
       expiration: 86400000  # 24 hours
   ```

3. **Database Setup**
   ```bash
   # Using Docker
   docker run -d \
     --name postgres-attendance \
     -e POSTGRES_DB=attendance_db \
     -e POSTGRES_USER=attendance_user \
     -e POSTGRES_PASSWORD=your_password \
     -p 5432:5432 \
     postgres:15
   ```

4. **Run the Application**
   ```bash
   # Development mode
   ./gradlew bootRun --args='--spring.profiles.active=dev'
   
   # With specific JVM options
   ./gradlew bootRun -Dspring.profiles.active=dev
   ```

## 📁 Project Structure

```
src/main/java/mk/ukim/finki/attendanceappserver/
├── AttendanceAppServerApplication.java
├── config/                     # Configuration classes
│   ├── SecurityConfig.java
│   ├── R2dbcConfig.java
│   ├── CacheConfig.java
│   └── WebConfig.java
├── controller/                 # REST controllers
│   ├── AttendanceController.java
│   ├── AuthController.java
│   ├── QRController.java
│   └── StudentController.java
├── service/                    # Business logic
│   ├── AttendanceService.java
│   ├── AuthService.java
│   ├── QRCodeService.java
│   └── DeviceLinkingService.java
├── repository/                 # Data access layer
│   ├── StudentRepository.java
│   ├── AttendanceRepository.java
│   └── CourseRepository.java
├── dto/                       # Data transfer objects
│   ├── request/
│   └── response/
├── entity/                    # Database entities
│   ├── Student.java
│   ├── Attendance.java
│   └── Course.java
├── security/                  # Security components
│   ├── JwtAuthenticationManager.java
│   └── JwtUtil.java
├── exception/                 # Exception handling
│   ├── GlobalExceptionHandler.java
│   └── custom/
└── scheduled/                 # Scheduled jobs
    └── DeviceLinkingJob.java

src/main/resources/
├── application.yml            # Main configuration
├── application-dev.yml        # Development profile
├── application-prod.yml       # Production profile
└── db/changelog/             # Liquibase migrations
    ├── db.changelog-master.xml
    └── changes/
```

## 🔧 Development Setup

### IDE Configuration

**IntelliJ IDEA**
1. Import as Gradle project
2. Enable annotation processing
3. Install Lombok plugin
4. Set Java SDK to 21

**VS Code**
1. Install Extension Pack for Java
2. Install Spring Boot Extension Pack
3. Configure Java runtime

### Database Migration

The application uses **Liquibase** for database schema management:

```bash
# Generate changelog
./gradlew liquibaseDiffChangeLog

# Update database
./gradlew liquibaseUpdate

# Rollback
./gradlew liquibaseRollbackCount -PliquibaseCommandValue=1
```

### Running Tests
```bash
# Unit tests
./gradlew test

# Integration tests
./gradlew integrationTest

# All tests with coverage
./gradlew test jacocoTestReport
```

## 🔒 Security Configuration

### JWT Authentication
```java
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        return http
            .csrf().disable()
            .authorizeExchange(exchanges -> 
                exchanges
                    .pathMatchers("/api/auth/**").permitAll()
                    .pathMatchers("/api/students/**").hasRole("STUDENT")
                    .pathMatchers("/api/professors/**").hasRole("PROFESSOR")
                    .anyExchange().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt())
            .build();
    }
}
```

### CORS Configuration
```java
@Configuration
public class WebConfig {
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }
}
```

## 📡 API Endpoints

### Authentication
```
POST /api/auth/login          # User login
POST /api/auth/refresh        # Token refresh
POST /api/auth/logout         # User logout
```

### Attendance Management
```
POST /api/attendance/register    # Register attendance (QR scan)
POST /api/attendance/confirm     # Confirm attendance (proximity)
GET  /api/attendance/{id}        # Get attendance details
GET  /api/attendance/student/{studentId} # Student attendance history
```

### QR Code Generation
```
POST /api/qr/generateQR         # Generate QR code for class
GET  /api/qr/validate/{token}   # Validate QR token
```

### Student Management
```
GET    /api/students/{id}                        # Get student details
GET    /api/students/{id}/attendance-summary     # Attendance statistics
POST   /api/students/{id}/device-link-request    # Request device change
GET    /api/students/{id}/schedule               # Student schedule
```

### Data Management
```
GET /api/professors          # List professors
GET /api/rooms              # List rooms  
GET /api/subjects           # List subjects
GET /api/courses            # List courses
```

## 🏗 Architecture Patterns

### Reactive Programming
```java
@Service
public class AttendanceService {
    
    public Mono<AttendanceResponse> registerAttendance(AttendanceRequest request) {
        return validateQRToken(request.getToken())
            .flatMap(token -> createPendingAttendance(token, request))
            .map(this::mapToResponse)
            .onErrorMap(this::handleError);
    }
}
```

### Repository Pattern
```java
@Repository
public interface AttendanceRepository extends R2dbcRepository<Attendance, Long> {
    
    @Query("SELECT * FROM attendance WHERE student_id = :studentId AND semester = :semester")
    Flux<Attendance> findByStudentAndSemester(Long studentId, String semester);
    
    @Query("SELECT COUNT(*) FROM attendance WHERE student_id = :studentId AND status = 'PRESENT'")
    Mono<Long> countPresentAttendances(Long studentId);
}
```

### Caching Strategy
```java
@Service
public class QRCodeService {
    
    @Cacheable(value = "qrCodes", key = "#shortKey")
    public Mono<byte[]> getQRCodeImage(String shortKey) {
        return generateQRCode(shortKey);
    }
    
    @CacheEvict(value = "qrCodes", key = "#shortKey")
    public void invalidateQRCode(String shortKey) {
        // Cache eviction handled by annotation
    }
}
```

## ⚡ Performance Optimization

### Database Optimization
- **Connection Pooling**: R2DBC connection pool configuration
- **Query Optimization**: Use of database indexes
- **Pagination**: Efficient large dataset handling

### Caching
- **Caffeine Cache**: In-memory caching for frequently accessed data
- **QR Code Cache**: 15-minute TTL matching token validity
- **Static Data Cache**: Long-lived cache for reference data

### Reactive Streams
- **Non-blocking I/O**: Improved throughput and resource utilization
- **Backpressure Handling**: Prevents memory overflow
- **Stream Processing**: Efficient data transformation

## 🔄 Scheduled Jobs

### Device Linking Automation
```java
@Component
public class DeviceLinkingJob {
    
    @Scheduled(fixedRate = 300000) // 5 minutes
    public void processDeviceLinkRequests() {
        deviceLinkingService.processPendingRequests()
            .doOnNext(this::logProcessedRequest)
            .doOnError(this::logError)
            .subscribe();
    }
}
```

### Cleanup Jobs
- **Expired Tokens**: Remove old QR tokens
- **Log Rotation**: Archive old application logs
- **Cache Eviction**: Clean up stale cached data

## 🐳 Docker Deployment

### Dockerfile
```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app
COPY build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Docker Compose
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
    depends_on:
      - postgres
      
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=attendance_db
      - POSTGRES_USER=attendance_user
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Building and Running
```bash
# Build application
./gradlew build

# Build Docker image
docker build -t attendance-api-server:latest .

# Run with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f app
```

## 📊 Monitoring & Logging

### Application Metrics
- **Spring Boot Actuator**: Health checks and metrics
- **Custom Metrics**: Business-specific measurements
- **Performance Monitoring**: Response time tracking

### Logging Configuration
```yaml
logging:
  level:
    mk.ukim.finki.attendanceappserver: DEBUG
    org.springframework.security: DEBUG
  pattern:
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/attendance-app.log
    max-size: 10MB
    max-history: 30
```

## 🧪 Testing Strategy

### Unit Tests
```java
@ExtendWith(MockitoExtension.class)
class AttendanceServiceTest {
    
    @Mock
    private AttendanceRepository repository;
    
    @InjectMocks
    private AttendanceService service;
    
    @Test
    void shouldRegisterAttendanceSuccessfully() {
        // Test implementation
    }
}
```

### Integration Tests
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(properties = {"spring.profiles.active=test"})
class AttendanceControllerIntegrationTest {
    
    @Autowired
    private WebTestClient webTestClient;
    
    @Test
    void shouldProcessAttendanceFlow() {
        // Integration test implementation
    }
}
```

## 🐛 Troubleshooting

### Common Issues

**Database Connection Failed**
```bash
# Check PostgreSQL status
docker ps | grep postgres

# Verify connection string
psql -h localhost -p 5432 -U attendance_user -d attendance_db
```

**Application Won't Start**
```bash
# Check Java version
java -version

# Verify Gradle build
./gradlew build --info

# Check port availability
lsof -i :8080
```

**Memory Issues**
```bash
# Increase JVM heap size
export JAVA_OPTS="-Xmx2g -Xms1g"
./gradlew bootRun
```

### Performance Issues
- Enable SQL logging for query analysis
- Use database query profiling
- Monitor cache hit rates
- Profile with JProfiler or similar tools

## 📚 Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring WebFlux Guide](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html)
- [R2DBC Documentation](https://r2dbc.io/)
- [Liquibase Documentation](https://docs.liquibase.com/)
- [API Documentation](http://localhost:8080/swagger-ui.html) (when running)

## 🔐 Security Best Practices

### JWT Configuration
- Use strong, random secret keys
- Implement proper token rotation
- Set appropriate expiration times
- Validate all incoming tokens

### Database Security
- Use connection encryption
- Implement proper user privileges
- Regular security updates
- Backup encryption

### API Security
- Rate limiting implementation
- Input validation
- CORS configuration
- HTTPS enforcement
