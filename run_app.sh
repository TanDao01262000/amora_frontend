#!/bin/bash

# Amora - Flutter Frontend Startup Script

echo "🚀 Starting Amora Flutter Frontend..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "🔧 Generating JSON serialization code..."
flutter packages pub run build_runner build

echo ""
echo "🔍 Running Flutter analysis..."
flutter analyze --no-fatal-infos

echo ""
echo "✅ Setup complete! You can now run the app with:"
echo "   flutter run"
echo ""
echo "📱 Make sure your backend API is running on http://localhost:8000"
echo "💕 Happy coding!"
