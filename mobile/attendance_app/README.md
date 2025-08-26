# Mobile Application (Flutter)

This directory contains the source code for the Flutter-based mobile application for the FINKI Attendance system.

## Overview

This is a cross-platform application that provides a tailored UI for both **Students** and **Professors**. It communicates with the backend server to fetch schedule data, register attendance, and generate QR codes.

## Key Features

- **Role-Based UI:** Separate dashboards and functionalities for students and professors.
- **CAS Authentication:** Secure login using the university's Central Authentication System.
- **Interactive Calendars:** Daily and weekly views of class schedules.
- **QR Code Scanning:** Students use their camera to scan a professor-generated QR code.
- **Bluetooth Proximity Check:** As a security measure, the app uses Bluetooth LE to verify the student is physically in the classroom.
- **Local Filtering:** All list views (dashboards, calendars) include a local search/filter functionality for an improved user experience.
- **Attendance Summary:** Students can view a summary of their attendance statistics directly on their profile.
- **Secure Device Management:** The app enforces a single-device policy for attendance. Students can securely request to link a new device, which is then processed by an automated, auditable backend job.

## Technical Details

- **Framework:** Flutter 3 / Dart
- **State Management:** Provider
- **Caching:**
  - **Data:** A cache-first repository pattern using `shared_preferences` for static data like professor and room lists.
  - **Secure Storage:** `flutter_secure_storage` for JWTs and other sensitive info.
  - **Images:** `cached_network_image` for efficient network image handling.

## Getting Started

### Prerequisites
- Flutter SDK (version 3.x recommended)
- An appropriate IDE (VS Code, Android Studio)
- A configured emulator or physical device

### Running the App
1. **Configure Environment:** Create a `.env` file in the root of this directory (`/mobile/attendance_app`) with the necessary API and service URLs.
2. **Install Dependencies:** Run `flutter pub get` from within this directory.
3. **Run the App:** Launch the application using `flutter run`.
