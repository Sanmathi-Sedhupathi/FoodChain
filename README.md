# FoodChain

FoodChain is an open source Flutter app to help reduce food waste by connecting donors, receivers, and delivery drivers in your community.

## Features

- Donor: Create and manage food donations
- Receiver: Request and view available food nearby
- Driver: Deliver food from donors to receivers
- Location-based search and filtering
- Role-based dashboards

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install)
- [Firebase account](https://firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/foodchain.git
   cd foodchain
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Configure Firebase:**

   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Enable Authentication, Firestore, and Storage.
   - Install FlutterFire CLI:
     ```sh
     dart pub global activate flutterfire_cli
     ```
   - Run FlutterFire configure:
     ```sh
     flutterfire configure
     ```
   - This will generate `lib/firebase_options.dart` with your credentials.

4. **Do NOT commit your `firebase_options.dart` file.**  
   Use `lib/firebase_options copy.dart` as a template for contributors.

### Running the App

```sh
flutter run
```

## Project Structure

- `lib/screens/` - UI screens for each role
- `lib/models/` - Data models
- `lib/services/` - Business logic and Firebase integration
- `lib/utils/` - Theme and utilities
- `lib/widgets/` - Reusable UI components

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

---

**Note:**  
Replace all Firebase placeholder values with your own credentials.  
Do not share your actual Firebase API keys in public
