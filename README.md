# Splitwise Clone

A Flutter application that replicates the functionality of Splitwise, allowing users to manage and split expenses among groups.

## Features

- User Authentication (Login, Register)
- Profile Management
- Group Management
- Expense Tracking and Splitting
- Dark and Light Theme Support

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: Comes with Flutter
- A code editor (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/yourusername/splitwise_clone.git
   cd splitwise_clone
   ```

2. Install dependencies:

   ```sh
   flutter pub get
   ```

3. Run the app:
   ```sh
   flutter run
   ```

## Project Structure

```plaintext
lib/
├── Comman/
│   ├── Colors.dart
│   ├── SplashScreen.dart
├── View/
│   ├── Group/
│   │   └── GroupListScreen.dart
│   ├── HomeScreen.dart
│   ├── User/
│   │   ├── ChangePasswordScreen.dart
│   │   ├── LoginScreen.dart
│   │   ├── ProfileEditScreen.dart
│   │   └── RegisterScreen.dart
├── ViewModel/
│   └── Controller/
│       └── Auth.Controller.dart
└── main.dart
```
