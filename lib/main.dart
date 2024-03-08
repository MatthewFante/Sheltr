// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

import 'package:flutter/material.dart';
import 'package:untitled/assets/palatte.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/pages/home_page.dart';
import 'package:untitled/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Determine the starting page
  User? user = FirebaseAuth.instance.currentUser;
  Widget startPage = const LoginPage();

  // If the user is already logged in, go to the home page
  if (user != null) {
    startPage = const HomePage();
  }

  // Run the app
  runApp(MyApp(startPage: startPage));
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  final Widget startPage;
  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheltr',
      theme: ThemeData(
        // Using a custom color palette defined in assets/palette.dart
        primarySwatch: Palette.crimson,
      ),
      home: startPage,
    );
  }
}
