import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wajhatuk/firebase_options.dart';
import 'package:wajhatuk/splash_page.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

// void main() async {
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Directionality(
//       textDirection: TextDirection.rtl,
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'وجـهــتك',
//         home: SplashPage(),
//       ),
//     );
//   }
// }

//aaaaaaaaaaaaaa

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وجـهــتك',
      locale: languageProvider.locale,
      home: SplashPage(),
    );
  }
}
