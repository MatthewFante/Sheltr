import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:untitled/models/meet_and_greet_request.dart';
import 'package:untitled/models/pet.dart';

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
        SnackBar(content: Text("Request cancelled successfully.")),
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error fetching user ID"),
            );
          }

          final userId = snapshot.data!;

          return StreamBuilder<List<MeetAndGreetRequest>>(
            stream: MeetAndGreetRequest.streamRequestsByRequesterId(userId),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (streamSnapshot.hasError) {
                return Center(
                  child: Text("Error fetching meet & greet requests."),
                );
              }

              final requests = streamSnapshot.data ?? [];

              if (requests.isEmpty) {
                return Center(
                  child: Text("No meet & greet requests found."),
                );
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final status = request.status;

                  return FutureBuilder<Pet>(
                    future: _fetchPetDetails(request.petId),
                    builder: (context, petSnapshot) {
                      if (petSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(
                          title: const Text("Loading pet details..."),
                          trailing: const CircularProgressIndicator(),
                        );
                      }

                      if (petSnapshot.hasError) {
                        return ListTile(
                          title: const Text("Error loading pet details"),
                        );
                      }

                      final pet = petSnapshot.data;
                      final petName = pet?.name ?? "Unknown";
                      final petImageUrl = pet?.imageUrls.isNotEmpty == true
                          ? pet!.imageUrls[0]
                          : null;

                      return ListTile(
                        leading: petImageUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(petImageUrl),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.pets),
                              ),
                        title: Text("Meet & Greet with $petName"),
                        subtitle: Text(
                          "Meet Date: ${DateFormat.yMMMd().format(request.meetDate)}\nMeet Time: ${request.meetTime}\nStatus: ${status}",
                        ),
                        trailing: (status == 'pending' || status == 'approved')
                            ? IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () async {
                                  final confirmCancel = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Cancel Request"),
                                      content: const Text(
                                          "Are you sure you want to cancel this request?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text("No"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text("Yes"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmCancel == true) {
                                    await _cancelRequest(request.requestId);
                                  }
                                },
                              )
                            : null, // No cancellation for other statuses
                      );
                    },
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
