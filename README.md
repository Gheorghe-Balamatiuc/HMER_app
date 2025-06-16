# HMER App - Handwritten Mathematical Expression Recognition

HMER App is a Flutter application that allows users to upload images of handwritten mathematical expressions and get them recognized, converted to text, and read aloud.

## Features

- Upload images of handwritten mathematical expressions
- View recognized mathematical expressions
- Copy expressions to clipboard
- Listen to the expressions using text-to-speech
- Delete uploaded images
- Pull to refresh for the latest content

## Requirements

To run this project, you'll need:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version ^3.6.1)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- An Android emulator or physical device for testing
- [VS Code](https://code.visualstudio.com/) (optional, but recommended)

## Setup Instructions

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/HMER_app.git
   ```

2. Navigate to the project directory:
   ```
   cd HMER_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Make sure you have an Android emulator running or a device connected:
   ```
   flutter devices
   ```

5. Run the application:
   ```
   flutter run
   ```

## Android
- Make sure Android Studio is installed with the Android SDK
- Start an Android emulator or connect a physical device
- Run `flutter run`

## Backend API

The application communicates with a backend API running on `http://10.0.2.2:5071` (which points to localhost:5071 from an Android emulator). Make sure your backend service is running for full functionality.

## Project Structure

```
lib/
  ├── api/
  │   ├── api.dart
  │   └── repository.dart
  ├── bloc/
  │   ├── product_bloc.dart
  │   ├── product_event.dart
  │   └── product_state.dart
  ├── models/
  │   ├── image.dart
  │   └── product.dart
  ├── pages/
  │   └── product_page.dart
  ├── main.dart
  └── product_bloc_observer.dart
```

## Technologies Used

- [Flutter](https://flutter.dev/) - UI toolkit
- [Bloc](https://bloclibrary.dev/) - State management
- [HTTP](https://pub.dev/packages/http) - API communication
- [Flutter TTS](https://pub.dev/packages/flutter_tts) - Text-to-speech functionality
- [File Picker](https://pub.dev/packages/file_picker) - For selecting images
- [Equatable](https://pub.dev/packages/equatable) - Value equality
- [Logger](https://pub.dev/packages/logger) - Enhanced logging

## Testing

Run tests using the following command:
```
flutter test
```

This project has thorough test coverage for API clients, repositories, and Bloc components.