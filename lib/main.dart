import 'package:flutter/material.dart';
import 'package:hedieaty/home/home_screen/home_screen.dart';
import 'package:hedieaty/onboarding/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'home/base_tab_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HedieatyApp());
}

class HedieatyApp extends StatelessWidget {
  const HedieatyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Amr Hamouda's Hediaety",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF25DBFF),
          secondary: const Color(0xFFFF2581),
        ),
      ),
      // Check authentication state before deciding the home screen
      home: const AuthStateHandler(),
    );
  }
}

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a FutureBuilder to determine the initial route
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        // If the future is still loading, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If the user is logged in, navigate to BaseTabScreen
        if (snapshot.hasData) {
          return const BaseTabScreen();
        }

        // Otherwise, navigate to WelcomeScreen
        return const WelcomeScreen();
      },
    );
  }
}
