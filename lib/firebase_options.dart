import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Return the configuration based on the platform (iOS, Android, Web)
    return const FirebaseOptions(
      apiKey: 'AIzaSyCGfLeHFW4qJqLfh5_mcf0zMBFXFWElLjU',
      appId: '1:152724057071:android:7eebe5a0672c58a7e4e41a',
      messagingSenderId: '',
      projectId: 'wajhatuk2030-8d8f3',
      storageBucket: 'wajhatuk2030-8d8f3.appspot.com',
      // other platform-specific configurations...
    );
  }
}
