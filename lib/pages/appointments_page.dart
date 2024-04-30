import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error fetching user ID."),
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
                return const Center(
                  child: Text("Error fetching meet & greet requests."),
                );
              }

              final requests = streamSnapshot.data ?? [];

              if (requests.isEmpty) {
                return const Center(
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
                        return const Card(
                          child: ListTile(
                            title: Text("Loading pet details..."),
                            trailing: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (petSnapshot.hasError) {
                        return const Card(
                          child: ListTile(
                            title: Text("Error loading pet details"),
                          ),
                        );
                      }

                      final pet = petSnapshot.data;
                      final petName = pet?.name ?? "Unknown";
                      final petImageUrl = pet?.imageUrls.isNotEmpty == true
                          ? pet!.imageUrls[0]
                          : null;

                      return Card(
                          elevation: 1, // Add a subtle shadow
                          child: Row(
                            children: [
                              petImageUrl != null
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 30, 15, 30),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(petImageUrl),
                                      ),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: CircleAvatar(
                                        child: Icon(Icons.pets),
                                      ),
                                    ),
                              SizedBox(
                                width: 250,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Meet & Greet w/ $petName",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      "${DateFormat.yMMMd().format(request.meetDate)} @ ${request.meetTime}",
                                    ),
                                    status == "approved"
                                        ? Text(status.toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold))
                                        : Text(status.toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final confirmCancel = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        "Cancel Request",
                                      ),
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
                                child: const Text("Cancel",
                                    style: TextStyle(color: Color(0xff990000))),
                              ),
                            ],
                          ));
                      //;
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
