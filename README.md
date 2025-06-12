# Whites & Brights Laundry Management System

A comprehensive laundry management system with multi-role support (customers, riders, admins) built with Flutter and Node.js/Express backend with MongoDB integration.

## System Architecture

The system consists of three main components:

1. **Backend API Server** (`laundry-backend`): Node.js/Express server with MongoDB database
2. **Customer App** (`whites_brights_laundry`): Flutter app for customers to place orders
3. **Rider App** (`whites_brights_rider`): Flutter app for delivery personnel
4. **Admin Dashboard** (`whites_brights_admin`): Web-based dashboard for administrators

## Features

### Customer App
- 🔐 User authentication and profile management
- 🧺 Browse laundry services with pricing
- 📅 Schedule pickup and delivery
- 📍 Address management
- 📊 Order history and status tracking
- 💳 Payment integration
- 📦 Order summary and confirmation
- 📱 Push notifications

### Rider App
- 🔐 Rider authentication and profile management
- 📱 Update availability status (available, busy, offline)
- 🚚 View and manage assigned orders
- 📊 Order history and analytics
- 📍 Real-time location tracking
- 💰 Revenue tracking and performance metrics

### Admin Dashboard
- 🔐 Admin authentication and role-based access
- 📊 Comprehensive analytics and reporting
- 👥 User management (customers and riders)
- 🧺 Service management
- 📦 Order management and tracking
- 🚚 Rider assignment and monitoring

## Technology Stack

### Backend
- **Framework**: Node.js with Express.js
- **Database**: MongoDB
- **Authentication**: JWT (JSON Web Tokens)
- **API**: RESTful API design
- **Middleware**: Role-based access control

### Frontend (Customer & Rider Apps)
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Location Services**: Geolocator

### Admin Dashboard
- **Framework**: Flutter Web
- **State Management**: Provider
- **Charts**: fl_chart
- **Data Tables**: data_table_2
- 📊 Order history with filtering
- 👤 User profile management
- 🧰 Clean, modern UI with Material 3 design

## Setup Instructions

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd laundry-backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file with the following variables:
   ```
   PORT=5000
   MONGO_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<dbname>?retryWrites=true&w=majority
   JWT_SECRET=your_jwt_secret_key
   JWT_EXPIRES_IN=30d
   ```

4. Start the server:
   ```bash
   npm start
   ```
   For development with auto-reload:
   ```bash
   npm run dev
   ```

### Customer App Setup

1. Navigate to the customer app directory:
   ```bash
   cd whites_brights_laundry
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Update the API base URL in `lib/services/api_service.dart`

4. Run the app:
   ```bash
   flutter run
   ```

### Rider App Setup

1. Navigate to the rider app directory:
   ```bash
   cd whites_brights_rider
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Update the API base URL in `lib/services/api_service.dart`

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

### Backend Structure

```
laundry-backend/
├── controllers/       # Request handlers
├── middleware/        # Auth and role-based access control
├── models/            # MongoDB schemas
├── routes/            # API routes
├── utils/             # Helper functions
├── .env               # Environment variables (not in repo)
├── package.json       # Dependencies
└── server.js          # Entry point
```

### Flutter Apps Structure

```
whites_brights_laundry/ or whites_brights_rider/
├── lib/
│   ├── constants/     # App constants, themes
│   ├── models/        # Data models
│   ├── providers/     # State management
│   ├── screens/       # UI screens
│   ├── services/      # API services
│   ├── utils/         # Helper functions
│   ├── widgets/       # Reusable UI components
│   └── main.dart      # Entry point
├── assets/            # Images, fonts
└── pubspec.yaml       # Dependencies
```

## State Management

The app uses Provider for state management with the following key providers:

1. **AddressProvider**: Manages address data with MongoDB integration
2. **ServiceProvider**: Manages service data with minimal implementation
3. **UserProvider**: Manages user authentication and profile data
4. **OrderProvider**: Manages order data and status
5. **AuthProvider**: Handles authentication logic
6. **RiderProvider**: Manages rider-specific functionality (rider app only)

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Screenshots

(Screenshots will be added after the app is built and run)

## Firebase Integration

### Development Mode with Mock Services

The app includes a mock implementation of Firebase services for development purposes. This allows you to develop and test the app without an actual Firebase connection.

- **MockFirebaseService**: Provides basic Firebase functionality
- **MockAuthService**: Simulates user authentication
- **MockFirestoreService**: Simulates Firestore database operations

To toggle between mock and real Firebase services, modify the `useMockServices` flag in `main.dart`:

```dart
// Set to true for mock services, false for real Firebase
firebaseServiceFactory.useMockServices = true;
```

### Setup Instructions for Real Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Register your app with the package name `com.example.whites_brights_laundry` (or your custom package name)
3. Download `google-services.json` and place it in `android/app/`
4. For iOS, download `GoogleService-Info.plist` and place it in `ios/Runner/`
5. Update `firebase_options.dart` with your project's configuration values
6. Set `useMockServices = false` in `main.dart`

### Firestore Collections

The app uses the following Firestore collections:

- **users**: User profiles and authentication data
- **orders**: Customer laundry orders with status tracking
- **services**: Available laundry services and pricing
- **addresses**: User delivery addresses
- **riders**: Delivery personnel information

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
│   ├── main_app_screen.dart (bottom navigation controller)
│   ├── order/
│   │   ├── screens/
│   │   │   ├── schedule_screen.dart (pickup & delivery)
│   │   │   ├── order_summary_screen.dart
│   │   │   ├── order_history/
│   │   │   │   ├── order_history_screen.dart
│   │   │   │   └── order_card.dart
│   │   │   └── order_tracking/
│   │   │       ├── order_status_screen.dart
│   │   │       ├── status_timeline.dart
│   │   │       └── rider_info_card.dart
│   │   └── widgets/
│   │       ├── date_picker_field.dart
│   │       ├── dropdown_selector.dart
│   │       └── summary_item.dart
│   └── profile/
│       ├── screens/
│       │   └── profile_screen.dart (user info, addresses)
│       └── widgets/
│           └── address_tile.dart
├── models/
│   ├── user_model.dart
│   ├── order_model.dart
│   ├── service_model.dart
│   ├── address_model.dart
│   └── rider_model.dart
├── services/
│   ├── firebase/
│   │   ├── firebase_service.dart (Firebase initialization)
│   │   ├── firebase_service_factory.dart (Service factory for mock/real services)
│   │   ├── auth_service.dart (Auth service interface)
│   │   ├── auth_service_firebase.dart (Firebase auth implementation)
│   │   ├── firestore_service_interface.dart (Firestore service interface)
│   │   ├── firestore_service.dart (Firestore operations implementation)
│   │   ├── mock_firebase_service.dart (Mock Firebase service)
│   │   ├── mock_auth_service.dart (Mock auth service)
│   │   ├── mock_firestore_service.dart (Mock Firestore service)
│   │   └── notification_service.dart (FCM)
│   └── providers/
│       ├── auth_provider.dart (legacy provider)
│       ├── user_provider.dart (Firebase user state)
│       ├── order_provider.dart (legacy provider)
│       ├── order_provider_firebase.dart (Firebase orders)
│       ├── service_provider.dart (Firebase services)
│       └── address_provider.dart (Firebase addresses)
├── widgets/
│   ├── buttons.dart
│   ├── custom_text_field.dart
│   └── bottom_nav_bar.dart (custom navigation)
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
