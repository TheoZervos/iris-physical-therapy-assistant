set -e

echo "--- Starting Iris Build Process ---"

cd iris

flutter clean
flutter pub get

flutter run