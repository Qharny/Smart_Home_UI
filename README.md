# Smart Home Flutter App

A modern, intuitive Flutter application for controlling smart home devices with a beautiful UI and seamless user experience.

## 🏠 Overview

Smart Home is a cross-platform mobile application built with Flutter that allows users to control and manage their smart home devices. The app provides an intuitive interface for adding devices, controlling their states, and monitoring their status in real-time.

## ✨ Features

### 🎯 Core Features
- **Device Management**: Add, remove, and organize smart home devices
- **Real-time Control**: Toggle devices on/off with instant feedback
- **Device Types Support**: 
  - Smart bulbs (with brightness control)
  - Smart fans (with speed control)
  - Other IoT devices
- **QR Code Scanner**: Easy device pairing using QR codes
- **User Authentication**: Secure login with OTP verification
- **Theme Support**: Light and dark theme modes
- **Offline Support**: Local caching for device states and user preferences

### 🎨 User Interface
- **Modern Design**: Clean, intuitive Material Design interface
- **Responsive Layout**: Optimized for various screen sizes
- **Smooth Animations**: Engaging user interactions
- **Bottom Navigation**: Easy navigation between main sections
- **Device Cards**: Visual representation of device status

### 🔧 Technical Features
- **State Management**: Provider pattern for efficient state management
- **Local Storage**: SharedPreferences for data persistence
- **Device Synchronization**: Real-time device state updates
- **Error Handling**: Comprehensive error handling and user feedback
- **Performance Optimized**: Efficient data loading and caching

## 📱 Screenshots

The app includes the following main screens:
- **Splash Screen**: App loading and initialization
- **Welcome Screen**: User onboarding and introduction
- **Home Screen**: Main dashboard with device overview
- **Devices Screen**: Detailed device management
- **Control Screen**: Individual device control interface
- **Add Device Screen**: Device pairing and configuration
- **QR Scanner Screen**: QR code-based device pairing
- **Notification Screen**: System notifications and alerts
- **OTP Screen**: Authentication and verification

## 🛠️ Technology Stack

- **Framework**: Flutter 3.9.0+
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **QR Scanning**: qr_code_scanner_plus
- **Icons**: flutter_launcher_icons
- **SVG Support**: flutter_svg

## 📋 Prerequisites

Before running this project, make sure you have the following installed:

- **Flutter SDK**: 3.9.0 or higher
- **Dart SDK**: Latest stable version
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **Git** for version control

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd smart_home
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Platform-Specific Settings

#### Android
- Ensure Android SDK is properly configured
- Update `android/app/build.gradle.kts` if needed
- Configure signing for release builds

#### iOS (macOS only)
- Install Xcode and iOS development tools
- Run `cd ios && pod install` to install iOS dependencies
- Configure signing certificates in Xcode

### 4. Run the Application

#### Development Mode
```bash
flutter run
```

#### Release Mode
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── device.dart          # Device data model
├── repositories/
│   └── device_repository.dart # Data access layer
├── route/
│   └── app_route.dart       # Navigation routes
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── devices_screen.dart
│   ├── control_screen.dart
│   ├── add_device_screen.dart
│   ├── qr_scanner_screen.dart
│   ├── notification_screen.dart
│   ├── welcome_screen.dart
│   ├── otp.dart
│   └── splash.dart
├── services/
│   ├── cache_service.dart   # Local storage service
│   └── theme_service.dart   # Theme management
└── widgets/                 # Reusable UI components
    ├── bottom_nav_bar.dart
    ├── device_page_card.dart
    └── home_device_card.dart
```

## 🔧 Configuration

### Environment Setup
The app uses the following key configurations:

- **Flutter SDK**: ^3.9.0
- **Dependencies**: See `pubspec.yaml` for complete list
- **Assets**: Images and icons in `asset/` directory
- **Platform Support**: Android and iOS

### Device Configuration
Devices are configured with the following properties:
- **ID**: Unique device identifier
- **Name**: User-friendly device name
- **Type**: Device category (bulb, fan, etc.)
- **Image Path**: Device icon/thumbnail
- **State**: On/off status
- **Properties**: Type-specific settings (brightness, speed, etc.)

## 🎮 Usage

### Adding a Device
1. Navigate to the "Add Device" screen
2. Use the QR scanner to scan device QR code
3. Configure device settings and name
4. Save and start controlling your device

### Controlling Devices
1. View all devices on the home screen
2. Tap on a device card to access detailed controls
3. Use toggle switches for on/off control
4. Adjust brightness/speed sliders for supported devices

### Managing Settings
- Access theme settings through the app
- View notifications in the notification screen
- Manage device preferences and configurations

## 🧪 Testing

Run tests using the following commands:

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (if configured)
flutter test integration_test/
```

## 📦 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Known Issues

- Device synchronization may require manual refresh in some cases
- QR scanner performance may vary on different devices
- Some advanced device features may not be supported on all device types

## 🔮 Future Enhancements

- [ ] Voice control integration
- [ ] Device automation and scheduling
- [ ] Multi-user support
- [ ] Cloud synchronization
- [ ] Advanced device analytics
- [ ] Integration with popular smart home platforms
- [ ] Push notifications for device events

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the documentation in the code comments
- Review the Flutter documentation for general Flutter questions

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Contributors and maintainers
- The open-source community for various packages used

---

**Note**: This is a demonstration project. For production use, ensure proper security measures, API integrations, and device compatibility testing.
