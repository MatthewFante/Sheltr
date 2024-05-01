// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// This file contains the AppointmentsPage class, which displays a list of meet-and-greet requests for the current user.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/meet_and_greet_request.dart';
import 'package:untitled/models/pet.dart';
import 'package:untitled/widgets/appointment_widget.dart'; // Import the new file with the widget logic

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  Future<String> _getCurrentUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    } else {
      throw Exception("User is not signed in");
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      await MeetAndGreetRequest.deleteMeetAndGreetRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request cancelled successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cancelling request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: _getCurrentUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching user ID."));
          }

          final userId = snapshot.data!;

          return StreamBuilder<List<MeetAndGreetRequest>>(
            stream: MeetAndGreetRequest.streamRequestsByRequesterId(userId),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (streamSnapshot.hasError) {
                return const Center(
                    child: Text("Error fetching meet & greet requests."));
              }

              final requests = streamSnapshot.data ?? [];

              if (requests.isEmpty) {
                return const Center(
                    child: Text("No meet & greet requests found."));
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return AppointmentWidget(
                    request: request,
                    cancelRequest: _cancelRequest,
                    fetchPetDetails: _fetchPetDetails,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Pet> _fetchPetDetails(String petId) async {
    final petDoc =
        await FirebaseFirestore.instance.collection('pets').doc(petId).get();
    if (!petDoc.exists) {
      throw Exception("Pet not found");
    }
    return Pet.fromJson(petDoc.data()!);
  }
}
