import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legacy_carry/views/splace_screen.dart';
import 'package:legacy_carry/views/providers/user_profile_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  


  // await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProfileProvider()..fetchProfile(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Legacy Carry',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplaceScreen(),
      ),
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
