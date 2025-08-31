# Attendance App - Backend Service

A Spring Boot-based reactive backend service for the FINKI Attendance Management System.

## Overview

This backend service handles student attendance tracking, proximity-based verification, and provides APIs for both student and professor applications.

## Tech Stack

- **Java 21**
- **Spring Boot 3.x** with WebFlux for reactive programming
- **PostgreSQL** with R2DBC for reactive database access
- **Spring Security** with JWT authentication
- **Liquibase** for database migrations
- **Springdoc OpenAPI** for API documentation

## Features

- **Attendance Management**: Register, verify, and track student attendance
- **Proximity Verification**: Location-based verification system
- **QR Code Generation**: Dynamic QR codes for class sessions
- **Student/Professor Dashboards**: Attendance statistics and reports
- **Device Management**: Secure device registration and verification
- **Real-time Notifications**: Reactive event processing

## Getting Started

### Prerequisites
- Java JDK 21+
- PostgreSQL 14+
- Docker (optional)

### Local Development Setup

1. **Clone the repository**

2. **Configure database**
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

3. **Configure application**
   Create or update `application-local.yaml` with your database credentials

4. **Run the application**
   ```bash
   ./gradlew bootRun --args='--spring.profiles.active=local'
   ```

5. **Access API documentation**
   Open [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

## Project Structure

```
src/main/java/mk/ukim/finki/attendanceappserver/
├── config/              # Application configuration
├── controllers/         # REST API controllers
├── domain/              # Domain models and repositories
│   ├── enums/           # Enumeration types
│   ├── models/          # Entity models
│   └── repositories/    # Database repositories
├── dto/                 # Data Transfer Objects
├── exceptions/          # Custom exceptions and error handling
├── security/            # Authentication and authorization
├── services/            # Business logic
│   └── shared/          # Shared service components
└── utils/               # Utility classes
```

## Key Services

- **AttendanceService**: Manages student attendance records and verification
- **ClassSessionService**: Handles class session management and QR code generation
- **ProximityVerificationService**: Processes location-based attendance verification
- **DeviceManagementService**: Manages student device registration and verification
- **StudentService**: Student-related operations and data access
- **ProfessorService**: Professor-related operations and dashboards

## API Endpoints

The API is documented using OpenAPI. When the application is running, visit:
- [Swagger UI](http://localhost:8080/swagger-ui.html)
- [OpenAPI JSON](http://localhost:8080/v3/api-docs)

## Deployment

### Docker

```bash
# Build Docker image
docker build -t attendance-app-server .

# Run container
docker run -p 8080:8080 -e SPRING_PROFILES_ACTIVE=prod attendance-app-server
```

### Docker Compose

```bash
# Start all services
docker-compose up -d
```

## Environment Configuration

| Profile | Description                             |
|---------|-----------------------------------------|
| local   | Local development with debugging        |
| dev     | Development environment                 |
| prod    | Production environment with optimizations|

## Monitoring and Logging

- Logs are available in the `logs/` directory
- Structured logging is configured in `logback-spring.xml`

## License

[MIT License](LICENSE)
