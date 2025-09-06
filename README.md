# Amora - Flutter Frontend 

A beautiful Flutter app for couples to connect, share routines, timeline entries, and manage their relationship together.

## 🚀 Features

- **Authentication**: Secure login and registration system
- **Partner Connection**: Connect with your partner using username
- **Routines**: Create and manage daily routines together
- **Timeline**: Share moments and memories with your partner
- **Calendar**: Plan and track important events
- **Profile Management**: Update your profile and manage account settings

## 📱 Screenshots

The app features a beautiful pink-themed UI with:
- Clean and modern design
- Intuitive navigation with bottom tab bar
- Responsive layouts for all screen sizes
- Beautiful cards and animations

## 🛠️ Setup Instructions

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Backend API running on `http://localhost:8000`

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd amora_frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate JSON serialization code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Backend API Configuration

The app is configured to connect to your backend API at `http://localhost:8000`. To change this:

1. Open `lib/services/api_service.dart`
2. Update the `baseUrl` constant:
   ```dart
   static const String baseUrl = 'http://your-api-url:port';
   ```

### Environment Setup

For different environments (development, staging, production), you can:

1. Create environment-specific configuration files
2. Use Flutter's environment variables
3. Update the API service accordingly

## 📁 Project Structure

```
lib/
├── models/           # Data models with JSON serialization
├── providers/        # State management with Provider
├── screens/          # UI screens
│   ├── auth/        # Authentication screens
│   └── main/        # Main app screens
├── services/         # API service and business logic
└── main.dart        # App entry point
```

## 🔌 API Integration

The app integrates with your FastAPI backend and supports:

- **Authentication**: Login, register, logout
- **User Management**: Profile updates, partner connection
- **Routines**: CRUD operations for daily routines
- **Timeline**: Create and manage timeline entries
- **Calendar**: Event management
- **File Upload**: Image and audio file uploads

## 🎨 UI/UX Features

- **Material Design 3**: Modern Material Design components
- **Pink Theme**: Beautiful pink color scheme for couples
- **Responsive Design**: Works on phones and tablets
- **Loading States**: Proper loading indicators
- **Error Handling**: User-friendly error messages
- **Pull to Refresh**: Refresh data by pulling down

## 🚀 Getting Started

1. **Start your backend API** on `http://localhost:8000`
2. **Run the Flutter app** using `flutter run`
3. **Register a new account** or login with existing credentials
4. **Connect with your partner** using their username
5. **Start using the app** to manage routines, timeline, and events!

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web (with some limitations)
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🔒 Security Features

- JWT token-based authentication
- Secure token storage using SharedPreferences
- Automatic token refresh
- Secure API communication

## 🐛 Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Ensure your backend is running on `http://localhost:8000`
   - Check network connectivity
   - Verify API endpoints are correct

2. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Regenerate JSON serialization: `flutter packages pub run build_runner build`

3. **Authentication Issues**
   - Check if JWT tokens are being stored correctly
   - Verify backend authentication endpoints

### Debug Mode

Run the app in debug mode to see detailed logs:
```bash
flutter run --debug
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 💕 Made with Love

This app is designed to help couples stay connected and build stronger relationships through shared routines, memories, and experiences.

---

**Happy coding with Amora! 🚀💕**