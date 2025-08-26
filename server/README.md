# Attendance Application API Server

## Overview
This document outlines the setup and deployment procedures for the Attendance Application API Server, a Spring Boot-based application that manages student attendance tracking and processing.

For a high-level overview of how this server fits into the entire project, please see the main [**PRESENTATION_README.md**](../../PRESENTATION_README.md).

## System Requirements

### Development Dependencies
- Java Development Kit (JDK) 21 or higher
- Gradle 8.5 or higher
- Docker Engine 24.0 or higher
- Docker Compose 2.0 or higher

## API Features

- **Reactive Stack:** Built with Spring WebFlux and R2DBC for a fully non-blocking, reactive architecture.
- **Role-Based Access:** Serves data and functionality tailored to Students and Professors.
- **Attendance Logic:** Manages the secure, multi-step attendance verification process (QR Token + Proximity).
- **QR Code Generation:** Creates time-limited, single-use tokens for attendance and embeds them in QR code images.
- **Web Presentation:** Serves a temporary webpage for displaying the QR code via a link.
- **Attendance Summary:** Provides a dedicated endpoint (`/api/students/{studentIndex}/attendance-summary`) to calculate and serve student attendance statistics.
- **Automated Device Linking:** A secure, automated system for processing student requests to change their registered device. A scheduled job handles approvals and flags suspicious activity for administrative review.

## Caching

The server utilizes the Spring Cache abstraction with a **Caffeine** implementation for in-memory caching. This is primarily used for the **Presentation Service**, where generated QR codes are cached for 15 minutes to correspond with the attendance token's validity period.

## Development Setup

### Local Development Environment
To initiate the server with development profile configurations, execute:

```bash
./gradlew bootRun --args='--spring.profiles.active=dev'
```

The application will be accessible at `http://localhost:8080`. API documentation is available via Swagger UI at `http://localhost:8080/swagger-ui.html`.

## Containerization

### Docker Image Construction
The application supports `linux/arm64` and `linux/amd64` deployment. To build the container image:

```bash
# For a specific architecture (e.g., arm64)
docker build --platform linux/arm64 -t attendance-api-server:latest .
```

### Container Deployment
To deploy and execute the containerized application using Docker Compose (for local/dev):

```bash
docker compose up -d
```