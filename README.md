# 📱 Todo Reminder - Flutter App

A modern, feature-rich Todo application built with Flutter, featuring Google Sign-In authentication, Supabase backend integration, and a beautiful user interface.

## ✨ Features

### 🔐 Authentication

- **Google Sign-In** - Seamless OAuth integration with account picker
- **Email/Password Authentication** - Traditional sign-up and login
- **Deep Linking** - Proper app redirects after OAuth authentication
- **Auto-login** - Persistent authentication state management

### 🎨 User Interface

- **Modern Design** - Clean, gradient-based UI with custom widgets
- **Splash Screen** - Animated loading screen with app branding
- **Custom Components** - Reusable buttons, text fields, and loaders
- **Responsive Layout** - Optimized for different screen sizes
- **Theme Support** - Light and dark mode ready

### 🏗️ Architecture

- **Clean Architecture** - Separation of concerns with feature-based structure
- **State Management** - Provider pattern for reactive UI updates
- **Repository Pattern** - Abstracted data layer for easy testing
- **Custom Widgets** - Reusable UI components

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Google Cloud Console account
- Supabase account

### Installation

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd todo_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Google Sign-In**

   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable Google+ API
   - Create OAuth 2.0 credentials
   - Download `google-services.json` and place it in `android/app/`

4. **Configure Supabase**

   - Create a new project at [Supabase](https://supabase.com/)
   - Get your project URL and anon key
   - Update `lib/core/services/supabase_service.dart` with your credentials
   - Configure Auth Redirect URLs in Supabase dashboard:
     - `io.supabase.flutter://login-callback/`
     - `http://localhost:3000/`
     - `https://your-domain.com/`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── app.dart                    # Main app configuration
├── main.dart                   # Entry point
├── core/
│   ├── constants/
│   │   ├── app_colors.dart     # Color definitions and gradients
│   │   ├── app_strings.dart    # String constants
│   │   └── app_constants.dart  # App-wide constants
│   ├── navigation/
│   │   └── auth_wrapper.dart   # Authentication-based navigation
│   ├── services/
│   │   ├── supabase_service.dart    # Supabase configuration
│   │   ├── notification_service.dart # Push notifications
│   │   └── storage_service.dart     # Local storage
│   ├── theme/
│   │   └── app_theme.dart      # Theme configuration
│   ├── utils/
│   │   ├── validators.dart     # Form validation utilities
│   │   └── helpers.dart        # Helper functions
│   └── widgets/
│       ├── custom_button.dart  # Reusable button component
│       ├── custom_textfield.dart # Reusable text field component
│       └── loader.dart         # Loading indicators
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart # Authentication data layer
│   │   ├── domain/
│   │   │   └── user_model.dart      # User domain model
│   │   ├── provider/
│   │   │   └── auth_provider.dart   # Authentication state management
│   │   └── presentation/
│   │       ├── splash_screen.dart   # Animated splash screen
│   │       ├── auth_choice_screen.dart # Auth method selection
│   │       ├── login_screen.dart    # Login form
│   │       └── signup_screen.dart   # Registration form
│   └── todos/
│       ├── data/
│       │   └── todo_repository.dart # Todo data layer
│       ├── domain/
│       │   └── todo_model.dart      # Todo domain model
│       ├── provider/
│       │   └── todo_provider.dart   # Todo state management
│       └── presentation/
│           ├── home_screen.dart     # Main todo list screen
│           ├── add_todo_screen.dart # Add new todo
│           └── todo_item_widget.dart # Todo item component
└── firebase_options.dart       # Firebase configuration
```

## 🎯 Key Features Explained

### Authentication Flow

1. **Splash Screen** - Shows for 2 seconds with app branding
2. **Auth Choice** - User selects Google Sign-In or Email/Password
3. **OAuth Flow** - Google account picker → redirect back to app
4. **State Management** - Automatic UI updates via Provider pattern

### Custom Widgets

- **CustomButton** - Primary, secondary, and outline button styles
- **CustomTextField** - Styled input fields with validation
- **CustomLoader** - Loading indicators and overlays

### State Management

- **AuthProvider** - Manages authentication state and user data
- **TodoProvider** - Handles todo CRUD operations
- **Real-time Updates** - Automatic UI refresh on data changes

## 🔧 Configuration

### Supabase Setup

1. Create a new Supabase project
2. Enable Authentication providers (Google, Email)
3. Configure redirect URLs:
   ```
   io.supabase.flutter://login-callback/
   http://localhost:3000/
   https://your-domain.com/
   ```
4. Update `supabase_service.dart` with your credentials

### Google Sign-In Setup

1. Create OAuth 2.0 credentials in Google Cloud Console
2. Add your app's package name and SHA-1 fingerprint
3. Download `google-services.json` to `android/app/`
4. Configure iOS URL schemes in `ios/Runner/Info.plist`

## 🚀 Deployment

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

## 📱 Screenshots

### Splash Screen

- Animated app icon and branding
- 2-second display duration
- Smooth transitions

### Authentication

- Google Sign-In with account picker
- Email/Password forms with validation
- Beautiful gradient backgrounds

### Main App

- Clean todo list interface
- Add/Edit/Delete functionality
- User profile management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Supabase](https://supabase.com/) - Backend as a Service
- [Google Sign-In](https://pub.dev/packages/google_sign_in) - Authentication
- [Provider](https://pub.dev/packages/provider) - State management

## 📞 Support

If you have any questions or need help, please:

- Open an issue on GitHub
- Check the documentation
- Contact the development team

---

**Built with ❤️ using Flutter**
