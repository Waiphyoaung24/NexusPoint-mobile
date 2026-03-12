# NexusPoint POS

A Flutter-based Point of Sale system for NexusPoint.

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Xcode (for iOS development)
- Android Studio (for Android development)

## Project Structure

This project uses **flavors** to manage different environments (local development and production).

## Available Flavors

| Flavor | Description | API Origin | App Name |
|--------|-------------|------------|----------|
| **local** | Development environment | Local API server | NexusPoint POS (Local) |
| **prod** | Production environment | https://nexuslab.asia/api/ | NexusPoint POS |

## How to Run

### Running with Flutter CLI

#### Local Development (Debug)
```bash
flutter run --flavor local --dart-define=APP_NAME="NexusPoint POS (Local)" --dart-define=API_ORIGIN="http://localhost:8080/api/" --dart-define=APP_ORIGIN="http://localhost:3000" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-local"
```

#### Production (Debug)
```bash
flutter run --flavor prod --dart-define=APP_NAME="NexusPoint POS" --dart-define=API_ORIGIN="https://nexuslab.asia/api/" --dart-define=APP_ORIGIN="https://nexuslab.asia" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-prod"
```

### Running from VS Code

Create a `.vscode/launch.json` file:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Local (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--flavor",
        "local",
        "--dart-define=APP_NAME=NexusPoint POS (Local)",
        "--dart-define=API_ORIGIN=http://localhost:8080/api/",
        "--dart-define=APP_ORIGIN=http://localhost:3000",
        "--dart-define=GOOGLE_CLOUD_PROJECT=nexuspoint-local"
      ]
    },
    {
      "name": "Production (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--flavor",
        "prod",
        "--dart-define=APP_NAME=NexusPoint POS",
        "--dart-define=API_ORIGIN=https://nexuslab.asia/api/",
        "--dart-define=APP_ORIGIN=https://nexuslab.asia",
        "--dart-define=GOOGLE_CLOUD_PROJECT=nexuspoint-prod"
      ]
    }
  ]
}
```

### Running from Android Studio / IntelliJ

1. Go to **Run** → **Edit Configurations**
2. Click **+** to add a new Flutter configuration
3. Set the following:
   - **Name**: Local (Debug)
   - **Dart entrypoint**: `lib/main.dart`
   - **Build flavor**: `local`
   - **Additional run args** (Local):
     ```
     --dart-define=APP_NAME="NexusPoint POS (Local)" --dart-define=API_ORIGIN="http://localhost:8080/api/" --dart-define=APP_ORIGIN="http://localhost:3000" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-local"
     ```
   - **Additional run args** (Production):
     ```
     --dart-define=APP_NAME="NexusPoint POS" --dart-define=API_ORIGIN="https://nexuslab.asia/api/" --dart-define=APP_ORIGIN="https://nexuslab.asia" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-prod"
     ```

### Building for Release

#### Android APK (Local)
```bash
flutter build apk --flavor local --dart-define=APP_NAME="NexusPoint POS (Local)" --dart-define=API_ORIGIN="http://localhost:8080/api/" --dart-define=APP_ORIGIN="http://localhost:3000" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-local"
```

#### Android APK (Production)
```bash
flutter build apk --flavor prod --dart-define=APP_NAME="NexusPoint POS" --dart-define=API_ORIGIN="https://nexuslab.asia/api/" --dart-define=APP_ORIGIN="https://nexuslab.asia" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-prod"
```

#### iOS (Local)
```bash
flutter build ios --flavor local --dart-define=APP_NAME="NexusPoint POS (Local)" --dart-define=API_ORIGIN="http://localhost:8080/api/" --dart-define=APP_ORIGIN="http://localhost:3000" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-local"
```

#### iOS (Production)
```bash
flutter build ios --flavor prod --dart-define=APP_NAME="NexusPoint POS" --dart-define=API_ORIGIN="https://nexuslab.asia/api/" --dart-define=APP_ORIGIN="https://nexuslab.asia" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-prod"
```

## Environment Variables

The following environment variables can be configured via `--dart-define`:

- `APP_NAME`: Application display name
- `API_ORIGIN`: Backend API base URL
- `APP_ORIGIN`: Web application origin URL
- `GOOGLE_CLOUD_PROJECT`: Google Cloud project ID
- `GA_MEASUREMENT_ID`: Google Analytics measurement ID (optional)

## Development Tips

### Quick Run Commands

Create shell aliases for quick access:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias flutter-local='flutter run --flavor local --dart-define=APP_NAME="NexusPoint POS (Local)" --dart-define=API_ORIGIN="http://localhost:8080/api/" --dart-define=APP_ORIGIN="http://localhost:3000" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-local"'

alias flutter-prod='flutter run --flavor prod --dart-define=APP_NAME="NexusPoint POS" --dart-define=API_ORIGIN="https://nexuslab.asia/api/" --dart-define=APP_ORIGIN="https://nexuslab.asia" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-prod"'
```

Then run with:
```bash
flutter-local    # For local development
flutter-prod     # For production testing
```

### Checking Current Environment

The app will print the current environment in debug mode:
```dart
if (AppConfig.isLocal) {
  debugPrint('Running in LOCAL environment');
  debugPrint('API Origin: ${AppConfig.apiOrigin}');
}
```

## Dependencies

Run the following to get all dependencies:
```bash
flutter pub get
```

## Code Generation

This project uses code generation. Run the following when models change:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_provider_test.dart
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
