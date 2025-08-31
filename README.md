# Attendance Application

A modern, cross-platform mobile solution for tracking student attendance at university, replacing manual sign-in sheets with a secure system using QR
codes and Bluetooth proximity verification.

## 📋 Table of Contents

- [System Overview](#system-overview)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Component Documentation](#component-documentation)
- [Architecture](#architecture)
- [Academic Presentation](#academic-presentation)

## 🔍 System Overview

The system consists of three main components:

- **Mobile App (Flutter)**: Cross-platform app for students and professors
- **Backend API (Spring Boot)**: RESTful API with PostgreSQL database
- **BLE Beacon**: Bluetooth Low Energy beacon for proximity verification

## 📁 Project Structure

```
attendance-app/
├── mobile/attendance_app/    # Flutter mobile application
├── server/                   # Spring Boot backend API
├── blt-beacon/              # Bluetooth LE beacon component
├── mockups/                 # UI wireframes and design assets
├── PRESENTATION_README.md   # Academic presentation guide
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** 3.x
- **Java JDK** 21+
- **Docker & Docker Compose**
- **Python** 3.7+ (for BLE beacon)

### 1. Start the Backend

```bash
cd server
./gradlew bootRun --args='--spring.profiles.active=dev'
```

### 2. Run Mobile App

```bash
cd mobile/attendance_app
flutter pub get
flutter run
```

### 3. Setup BLE Beacon (Optional)

```bash
cd ble-beacon
pip install -r requirements.txt
python beacon.py
```

## 📚 Component Documentation

Each component has its own detailed README with specific setup instructions, dependencies, and development guidelines:

- **[Mobile App](./mobile/attendance_app/README.md)** - Flutter development setup, state management, and features
- **[Backend API](./server/README.md)** - Spring Boot configuration, database setup, and API documentation
- **[BLE Beacon](ble-beacon/python/README.md)** - Hardware setup, beacon configuration, and proximity verification

## 🏗 Architecture

### System Flow

1. **Professor** generates QR code for their class
2. **Student** scans QR code with mobile app
3. **Backend** validates QR token and creates pending attendance
4. **Mobile app** scans for BLE beacon to verify proximity
5. **Backend** confirms attendance based on proximity data

### Security Features

- Time-limited QR tokens (15 minutes)
- Bluetooth proximity verification
- Device fingerprinting and linking
- Automated suspicious activity detection
- Role-based access control

## 📚 Academic Presentation

For a detailed technical presentation suitable for academic review, including system architecture diagrams, implementation details, and feature
deep-dives, see **[PRESENTATION_README.md](./PRESENTATION_README.md)**.

## 📄 License

This project is developed for academic purposes at FINKI, University Ss. Cyril and Methodius.
