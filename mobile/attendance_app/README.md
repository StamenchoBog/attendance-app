# Attendance Management Application

## Project Overview

The Attendance Management Application is a cross-platform mobile solution developed using Flutter framework to streamline the process of tracking and managing attendance records in educational or corporate environments. The application provides an intuitive user interface coupled with robust backend integration to ensure accurate and efficient attendance management.

## Prerequisites

Ensure your development environment meets the following requirements before proceeding:

- **Flutter SDK** v3.19.0 or higher ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK** v3.3.0 or higher (included with Flutter SDK)
- **Android Studio** v2023.1.1 or higher ([Download](https://developer.android.com/studio))
  - Android SDK 34 or higher
  - Android SDK Command-line Tools
  - Android Emulator
- **Xcode** v15.0 or higher (for iOS development, Mac only) ([App Store](https://developer.apple.com/xcode/))
- **Visual Studio Code** (recommended IDE) with the following extensions:
  - Flutter extension
  - Dart extension
  - Dart DevTools

**Note**: In the project [_asdf_](https://asdf-vm.com) is used as a tool to manage the versions of the tools.

## System Architecture

The application follows a layered architecture:

- **Presentation Layer**: Implements the UI using Flutter widgets
- **Business Logic Layer**: Manages the application state and business rules
- **Data Layer**: Handles data persistence and API communication
- **Domain Layer**: Contains the core business models and entities

## Setup & Configuration

### Development Environment Verification

Verify your Flutter installation and dependencies:

```bash
flutter doctor -v
```

Address any issues reported by the doctor command before proceeding with development.

### iOS Development Setup (Mac Only)

1. Install Xcode from the App Store
2. Install Xcode Command Line Tools:

   ```bash
   xcode-select --install
   ```

3. Configure iOS signing certificates:

   ```bash
   cd ios
   pod install
   open Runner.xcworkspace
   ```

   Navigate to Signing & Capabilities tab and configure your team ID.

4. Launch iOS Simulator:

   ```bash
   open -a Simulator
   ```

### Android Development Setup

1. List all system images:

   ```bash
   sdkmanager --list | grep system-images
   ```

2. Install Android SDK command-line tools:

   ```bash
   # Using sdkmanager to install required components
   sdkmanager --install "system-images;android-35;google_apis_playstore;arm64-v8a"
   ```

3. Create a development AVD (Android Virtual Device) from the terminal:

   For M1/M2 MacBooks, use `arm64-v8a` as your `abi` and mention in `package`. For Intel MacBooks use `x86`.

   ```bash
   # List devices and choose one which will be used in --device tag
   avdmanager list devices
   
   # Create a new AVD (replace parameters as needed)
   # Example variables:
   # avd_device_name = android_35
   # device_model = pixel_7_pro

   echo "no" | avdmanager create avd \
   --name "<avd_device_name>" \
   --package "system-images;android-35;google_apis_playstore;arm64-v8a" \
   --tag "google_apis_playstore" \
   --abi "arm64-v8a" \
   --device "<device_model>"
   ```

4. Configure AVD hardware properties (optional):

   ```bash
   # Edit config.ini file to modify hardware properties
   nano ~/.android/avd/Pixel6_API34.avd/config.ini
   
   # Common properties to modify:
   # hw.ram.size=4096 (RAM in MB)
   # hw.gpu.enabled=yes (Enable GPU acceleration)
   # hw.keyboard=yes (Enable hardware keyboard)
   ```

5. Commands to manage emulators:

   ```bash
   # List available emulators
   flutter emulators
   
   # Start an emulator by name
   flutter emulators --launch <avd_device_name>

   # Delete an emulator
   avdmanager delete avd -n <avd_device_name>
   ```

**Note**: The `echo "no" |` part automatically answers "no" to any confirmation prompts. Usually, this is for skipping the creation of a custom hardware profile if the specified --device isn't found. Since the goal is likely to use a standard device profile, this might not be necessary once you provide a valid device. If you still encounter issues, try running the command without echo "no" | to see exactly what `avdmanager` is asking or complaining about.

## Development Workflow

### Getting Started

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Run the application:

   ```bash
   # Development mode
   flutter run

   # Specify device
   flutter run -d <device_id>
   
   # Production/release mode
   flutter run --release
   ```

### Project Structure

```text
lib/
|-- main.dart
|
|-- data/
|   |-- models/             # Data models (user.dart, product.dart)
|   |-- repositories/       # Repositories (auth_repository.dart, product_repository.dart)
|   |-- data_sources/       # API clients, local DB access (api_client.dart, local_storage.dart)
|
|-- domain/                 # Optional (Clean Arch): Entities, Use Cases
|   |-- entities/
|   |-- use_cases/
|   |-- repositories/       # Abstract repository interfaces
|
|-- presentation/
|   |-- screens/ or pages/  # Full app screens (login_screen.dart, home_screen.dart)
|   |-- widgets/            # Reusable widgets (custom_button.dart, product_card.dart)
|   |-- controllers/ or state/ # State management logic (auth_bloc.dart, product_provider.dart)
|
|-- core/
|   |-- constants/
|   |-- theme/
|   |-- navigation/
|   |-- utils/
|   |-- services/
|
|-- app.dart
|-- l10n/
|-- generated/
```

### Testing

Execute tests using the following commands:

```bash
# Run all unit tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Deployment

### Android Deployment

1. Update version in `pubspec.yaml`
2. Generate release build:

   ```bash
   flutter build appbundle
   ```

3. The release bundle will be at `build/app/outputs/bundle/release/app-release.aab`

### iOS Deployment

1. Update version in `pubspec.yaml` and iOS `Info.plist`
2. Generate release build:

   ```bash
   flutter build ipa
   ```

3. The IPA file will be located at `build/ios/ipa/*.ipa`
4. Use Application Loader to upload to App Store Connect

## Documentation

For detailed documentation on the Flutter framework:

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Programming Language](https://dart.dev/guides)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

## Improvements

- Allow a professor user to 
  - Choose in which room will the class take place if not pre-defined. But allow for changing the room if pre-defined.
  - Filter classes by subject, room, date.
  - Subjects and rooms (currently ongoing) for the professor should appear as ongoing classes in the home page. So a professor can easily start the process for attendance for a class session.
  - When a class session is selected show which of the students are already marked as present, not present or late.
  - On-the-fly creation of QR codes for attendance marking.
  Additional:
  - See overview of historical attendance for a subject by date, student.
  - See overview of future class sessions and rooms where are they scheduled.
  - Overview of the professor badge and profile.