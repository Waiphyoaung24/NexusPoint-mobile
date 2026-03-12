#!/bin/bash
# Run Flutter app against local backend on port 5173
flutter run --flavor local --dart-define=APP_NAME="NexusPoint POS (Local)" --dart-define=API_ORIGIN="http://localhost:5173/api/" --dart-define=APP_ORIGIN="http://localhost:5173" --dart-define=GOOGLE_CLOUD_PROJECT="nexuspoint-local"
