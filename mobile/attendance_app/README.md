# Mobile Application (Flutter)

Cross-platform mobile application for the FINKI Attendance system, providing role-based interfaces for students and professors.

## 📱 Overview

This Flutter application serves as the primary interface for both students and professors to interact with the attendance system. It features role-based UI, QR code scanning, Bluetooth proximity verification, and offline-first architecture.

## 🛠 Technologies & Dependencies

### Core Framework
- **Flutter**: 3.x
- **Dart**: Latest stable version
- **Platform Support**: iOS, Android

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5              # State management
  http: ^1.1.0                  # API communication
  shared_preferences: ^2.2.2    # Local data caching
  flutter_secure_storage: ^9.0.0 # Secure token storage
  mobile_scanner: ^3.5.6        # QR code scanning
  flutter_blue_plus: ^1.17.0    # Bluetooth LE
  cached_network_image: ^3.3.0  # Image caching
  flutter_dotenv: ^5.1.0        # Environment configuration
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x or higher
- Android Studio / VS Code with Flutter extensions
- Physical device or emulator (camera required for QR scanning)
- iOS: Xcode (for iOS development)
- Android: Android SDK 21+ (API level 21)

### Installation

1. **Clone and Navigate**
   ```bash
   cd mobile/attendance_app
   ```

2. **Environment Configuration**
   Create a `.env` file in the root directory:
   ```env
   API_BASE_URL=http://localhost:8080
   CAS_LOGIN_URL=https://cas.finki.ukim.mk
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the Application**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

## 📁 Project Structure

```
lib/
├── main.dart                    # Application entry point
├── config/                     # Configuration and constants
│   ├── app_config.dart
│   └── theme.dart
├── data/                       # Data layer
│   ├── models/                 # Data models
│   ├── repositories/          # Data repositories
│   └── services/              # API services
├── providers/                  # State management
│   ├── user_provider.dart
│   ├── date_provider.dart
│   └── time_provider.dart
├── screens/                    # UI screens
│   ├── auth/                  # Authentication screens
│   ├── student/               # Student-specific screens
│   ├── professor/             # Professor-specific screens
│   └── shared/                # Shared screens
├── widgets/                    # Reusable UI components
└── utils/                      # Utility functions
```

## 🔧 Development Setup

### VS Code Configuration
Install recommended extensions:
- Flutter
- Dart
- Flutter Intl (for internationalization)

### Android Setup
1. Install Android Studio
2. Configure Android SDK (API 21+)
3. Create AVD (Android Virtual Device)

### iOS Setup (macOS only)
1. Install Xcode
2. Configure iOS Simulator
3. Install CocoaPods: `sudo gem install cocoapods`

## ✨ Key Features

### Authentication
- **CAS Integration**: University Single Sign-On
- **JWT Token Management**: Secure storage with automatic refresh
- **Role Detection**: Automatic student/professor role assignment

### Student Features
- **Dashboard**: Daily schedule with live class highlighting
- **QR Scanner**: Camera-based attendance marking
- **Calendar View**: Timeline schedule display
- **Profile**: Attendance statistics and settings
- **Device Management**: Secure device linking

### Professor Features
- **Class Management**: Teaching schedule overview
- **QR Generation**: Secure attendance codes
- **Attendance Tracking**: Student attendance monitoring
- **Web Sharing**: Shareable QR code links

### Technical Features
- **Offline-First**: Cache-first data strategy
- **State Management**: Provider pattern for reactive UI
- **Bluetooth Integration**: BLE proximity verification
- **Image Caching**: Optimized network image loading
- **Error Handling**: Comprehensive error management

## 🏗 Architecture

### State Management
Uses **Provider** pattern with separation of concerns:
- `UserProvider`: Authentication and user state
- `DateProvider`: Date selection and calendar state
- `TimeProvider`: Time-based UI updates

### Data Flow
1. **Repository Pattern**: Abstracts data sources
2. **Cache-First Strategy**: Local storage → Network fallback
3. **Reactive UI**: Provider notifies widget rebuilds

### Caching Strategy
- **Static Data**: Professors, rooms, subjects (SharedPreferences)
- **Secure Data**: JWT tokens (FlutterSecureStorage)
- **Images**: Network images (CachedNetworkImage)
- **Cache Invalidation**: TTL-based and manual refresh

## 🔒 Security

### Data Protection
- **Secure Storage**: Sensitive data encrypted locally
- **Token Management**: Automatic JWT refresh
- **Device Fingerprinting**: Hardware-based device identification

### Proximity Verification
- **Bluetooth LE**: Classroom beacon detection
- **RSSI Measurement**: Distance calculation
- **Signal Validation**: Prevent spoofing attacks

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Test Structure
- **Unit Tests**: Business logic and utilities
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end workflows

## 📦 Build & Deployment

### Android Release
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS Release
```bash
flutter build ios --release
```

### Environment-Specific Builds
```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Production
flutter run --dart-define=ENVIRONMENT=prod
```

## 🐛 Troubleshooting

### Common Issues

**Camera Permission Denied**
```bash
# Add to android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />
```

**Bluetooth Not Working**
```bash
# Ensure location permissions are granted
# Add to AndroidManifest.xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**Build Failures**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Performance Optimization
- Use `const` constructors for static widgets
- Implement `ListView.builder` for large lists
- Cache network requests appropriately
- Profile with Flutter DevTools

## 📋 Development Guidelines

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- Use `flutter_lints` for code analysis
- Maintain consistent file naming (snake_case)

### Git Workflow
- Feature branches: `feature/description`
- Commit messages: Follow conventional commits
- PR reviews required for main branch

### Performance Best Practices
- Minimize widget rebuilds
- Use Provider.of(listen: false) for non-UI operations
- Implement proper disposal in StatefulWidgets
- Profile memory usage regularly

## 🔗 API Integration

### Base Configuration
```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');
  static const Duration timeout = Duration(seconds: 30);
}
```

### Error Handling
```dart
try {
  final response = await http.get(url);
  // Handle response
} on SocketException {
  // Handle network errors
} on TimeoutException {
  // Handle timeout
} catch (e) {
  // Handle other errors
}
```

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus)
- [Mobile Scanner](https://pub.dev/packages/mobile_scanner)
