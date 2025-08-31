# FINKI Attendance Mobile App

Flutter-based mobile application for the FINKI Attendance system with role-based interfaces for students and professors.

## Quick Start

### Prerequisites

- Flutter 3.x+
- Physical device (camera + Bluetooth required)
- Android SDK 21+ or iOS 11+

### Setup

1. **Environment Configuration**
   ```bash
   # Create .env file
   echo "API_BASE_URL=http://localhost:8080/api" > .env
   echo "PRESENTATION_URL=http://localhost::8080/api" >> .env
   echo "CAS_LOGIN_URL=https://cas.finki.ukim.mk" >> .env
   ```

2. **Install & Run**
   ```bash
   flutter pub get
   flutter run
   ```

## Key Features

### Student App

- **QR Scanner**: Camera-based attendance with Bluetooth proximity verification
- **Schedule Dashboard**: Live class highlighting and attendance tracking
- **Device Management**: Secure device registration and linking

### Professor App

- **QR Generation**: Time-limited attendance codes
- **Class Management**: Real-time attendance monitoring
- **Analytics**: Attendance statistics and reporting

## Architecture

### Core Dependencies

```yaml
provider: ^6.0.5              # State management
mobile_scanner: ^3.5.6        # QR scanning
flutter_blue_plus: ^1.17.0    # Bluetooth LE proximity
flutter_secure_storage: ^9.0.0 # Secure token storage
```

### Project Structure

```
lib/
├── main.dart
├── core/                     # Services, utilities, constants
│   ├── bluetooth/           # BLE beacon scanning
│   ├── services/            # API, device, permission services
│   └── utils/               # Error handling, notifications
├── data/                    # Models, repositories, providers
├── presentation/            # Screens and widgets
└── providers/              # State management
```

### State Management

- **Provider Pattern**: Reactive UI updates
- **Repository Pattern**: Data abstraction layer
- **Cache-First**: Offline-first with network fallback

## Security & Proximity

### Authentication

- **CAS Integration**: University SSO
- **JWT Management**: Auto-refresh with secure storage
- **Device Fingerprinting**: Hardware-based identification

### Proximity Verification

- **Bluetooth LE**: Arduino beacon detection in classrooms
- **RSSI Calculation**: Distance-based attendance validation
- **Beacon Types**: `DEDICATED` (Arduino) / `PROFESSOR_PHONE`

## Development

### Build Commands

```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Release builds
flutter build apk --release          # Android
flutter build ios --release          # iOS
```

### Testing

```bash
flutter test                         # Unit tests
flutter test integration_test/       # E2E tests
```

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- Use `flutter_lints` for analysis
- Feature branches: `feature/description`

## Troubleshooting

### Common Issues

```bash
# Permission issues
# Add to android/app/src/main/AndroidManifest.xml:
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

# Build issues
flutter clean && flutter pub get
```

### Performance Tips

- Use `const` constructors
- Implement `ListView.builder` for large lists
- Use `Provider.of(listen: false)` for non-UI operations

## API Integration

The app communicates with a Spring Boot backend for:

- Authentication & user management
- Class schedules & attendance data
- Proximity verification logging

See [Server README](../../server/README.md) for API documentation.

---

**Tech Stack**: Flutter • Dart • Provider • Bluetooth LE • JWT • SQLite
