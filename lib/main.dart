import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:legacy_carry/views/splace_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legacy Carry',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplaceScreen(),
    );
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyA2WNmfCYVWCmCsN5YYEZGt7QfQrHldTlQ',
      appId: '1:217124623975:android:140a3fbd4da60a9a3126c2',
      messagingSenderId: '217124623975',
      projectId: 'legacycarry',
      storageBucket: 'legacycarry.firebasestorage.app',
    );
  }
}
