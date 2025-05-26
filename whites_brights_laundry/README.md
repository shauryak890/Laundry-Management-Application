# Whites & Brights Laundry App

A modern Flutter 3 application for a laundry service targeting Android and iOS.

## Features

- 📱 Phone authentication with Firebase
- 🏠 Home screen with grid layout of laundry services
- 📅 Schedule pickup and delivery
- 📦 Order summary and confirmation
- 👤 User profile management
- 🧰 Clean, modern UI with Material 3 design

## Screenshots

(Screenshots will be added after the app is built and run)

## Project Structure

```
lib/
├── core/
│   ├── constants.dart (colors, strings, assets, routes)
│   └── theme.dart (app theme configuration)
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart (phone input)
│   │   │   └── otp_screen.dart (verification)
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart (service listing)
│   │   └── widgets/
│   │       └── service_card.dart
│   ├── order/
│   │   ├── screens/
│   │   │   ├── schedule_screen.dart (pickup & delivery)
│   │   │   └── order_summary_screen.dart
│   │   └── widgets/
│   │       ├── date_picker_field.dart
│   │       ├── dropdown_selector.dart
│   │       └── summary_item.dart
│   └── profile/
│       ├── screens/
│       │   └── profile_screen.dart (user info, addresses)
│       └── widgets/
│           └── address_tile.dart
├── services/
│   ├── auth_service.dart (Firebase auth)
│   └── providers/
│       ├── auth_provider.dart (login state)
│       └── order_provider.dart (order state)
├── widgets/
│   ├── buttons.dart (primary & secondary)
│   └── custom_text_field.dart (input fields)
└── main.dart (app entry point)
```

## Setup Instructions

1. Make sure you have Flutter 3.x installed
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Set up Firebase for your project:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
   - Enable Phone Authentication in the Firebase console
5. Run `flutter run` to start the app

## Dependencies

- flutter_animate / lottie - For success animations
- shimmer - For loading states
- google_fonts - For Poppins font
- provider - For state management
- go_router - For navigation
- firebase_auth & firebase_core - For phone authentication
- intl - For date formatting

## Design Notes

- Uses Material 3 design principles
- Color scheme: White background with blue and yellow accent colors
- Font: Google Fonts (Poppins)
- Consistent padding of 16px around screen content
- Responsive design that works on all screen sizes
- Support for light/dark mode

## License

This project is licensed under the MIT License.
