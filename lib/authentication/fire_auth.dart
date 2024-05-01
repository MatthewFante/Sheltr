// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// this class describes the Firebase Authentication methods for the app to use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/user_profile.dart';

class FireAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registration method
  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Create a new UserProfile
        final userProfile = UserProfile(
          userId: user.uid,
          email: email,
          displayName: name,
          userType: 'user', // Default user type
        );

        // Add the UserProfile to Firestore
        await FirebaseFirestore.instance
            .collection('user_profiles')
            .doc(user.uid)
            .set(userProfile.toMap());

        // Optionally update Firebase Auth profile with display name
        await user.updateDisplayName(name);

        return user;
      }

      return null;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }

  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      }
    }

    return user;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}
