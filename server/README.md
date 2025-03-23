# Attendance Application API Server

## Overview
This document outlines the setup and deployment procedures for the Attendance Application API Server, a Spring Boot-based application that manages student attendance tracking and processing.

## System Requirements

### Development Dependencies
- Java Development Kit (JDK) 21 or higher
- Gradle 8.5 or higher
- Docker Engine 24.0 or higher
- Docker Compose 2.0 or higher

## Development Setup

### Local Development Environment
To initiate the server with development profile configurations, execute:

```bash
./gradlew bootRun --args='--spring.profiles.active=dev'
```

## Containerization

### Docker Image Construction

The application supports linux/arm64 and linux/amd64  deployment. Follow these steps to build the container image:

Generate container image(s) using the following command:
```bash
# For arm64 architecture
docker buildx build --platform linux/arm64 --load -t attendance-app-server:latest .
# For amd64 architecture
docker buildx build --platform linux/amd64 --load -t attendance-app-server:latest .
```

### Container Deployment

To deploy and execute the containerized application:

```bash
docker run -p 8080:8080 -d attendance-app-server:latest
```

Note: The application is accessible at `http://localhost:8080`.
