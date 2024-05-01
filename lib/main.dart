// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// This file contains the main entry point for the application.

import 'package:flutter/material.dart';
import 'package:untitled/assets/palatte.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled/widgets/menu_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Determine the starting page
  Widget startPage = const MenuScaffold();

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
        // Using a custom IU color palette defined in assets/palatte.dart
        primarySwatch: Palatte.crimson,
      ),
      home: startPage,
    );
  }
}
