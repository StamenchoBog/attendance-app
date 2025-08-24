# Attendance App

A comprehensive attendance tracking system for educational institutions that uses QR code scanning and Bluetooth proximity verification to accurately record student attendance.

## Overview

This application automates the attendance tracking process for universities by combining several technologies:

- QR code scanning for initial attendance registration
- Bluetooth Beacon verification to confirm physical presence
- Integration with university CAS (Central Authentication Service)
- Secure verification of student enrollment in courses

## Technology Stack

### Mobile Application
- **Flutter** for cross-platform mobile development (Android and iOS)
- QR code scanning libraries
- Bluetooth communication libraries for proximity verification

### Backend Server
- **Java** with **Spring Boot** for the server application
- **PostgreSQL** database for data storage
- Integration with university CAS for authentication and authorization
- QR code generation libraries

## How It Works

1. **Authentication**: Students log in using their university credentials through the CAS system.

2. **Verification**: The system verifies the student's enrollment status and course registration.

3. **QR Code Generation**: For each class session, the server generates a unique QR code containing:
   - Course metadata
   - Classroom information
   - Professor information
   - Time period data

4. **Attendance Process**:
   - Professor displays the QR code (via projector or other means)
   - Students scan the QR code using the mobile app
   - Bluetooth Beacons in the classroom verify the student's physical presence
   - Upon successful verification, attendance is recorded in the system

5. **Validation**: The system verifies that:
   - The student is actively enrolled
   - The student is registered for the course
   - The professor is teaching in the specified classroom
   - The student is physically present in the classroom (Bluetooth proximity)

## Security Features

- Secure authentication through university CAS
- Proximity verification prevents remote check-ins
- Time-sensitive QR codes
- Encrypted data transmission

## Project Structure

- `/server` - Backend API server (Java Spring Boot)
- `/mobile` - Flutter mobile application
