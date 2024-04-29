import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/meet_and_greet_request.dart';
import 'package:untitled/models/pet.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  Future<List<Pet>> _fetchShelterPets() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not signed in");
    }

    final petsQuery = FirebaseFirestore.instance
        .collection('pets')
        .where('createdByUserId', isEqualTo: currentUser.uid)
        .get();

    final petsDocs = (await petsQuery).docs;
    return petsDocs.map((doc) => Pet.fromJson(doc.data())).toList();
  }

  Future<void> _updateRequestStatus(
      String requestId, String newStatus, String updatedBy) async {
    try {
      await MeetAndGreetRequest.updateMeetAndGreetRequest(
        requestId,
        status: newStatus,
        lastUpdatedBy: updatedBy,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $newStatus successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Pet>>(
        future: _fetchShelterPets(),
        builder: (context, petsSnapshot) {
          if (petsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (petsSnapshot.hasError) {
            return const Center(
              child: Text("Error fetching pets."),
            );
          }

          final pets = petsSnapshot.data ?? [];

          if (pets.isEmpty) {
            return const Center(
              child: Text("No pets found for the shelter."),
            );
          }

          // Use rxdart to combine all streams of meet-and-greet requests
          final requestStreams = pets.map((pet) =>
              MeetAndGreetRequest.streamRequestsByPetId(pet.documentId));

          // Combine all meet-and-greet requests into a single list
          return StreamBuilder<List<MeetAndGreetRequest>>(
            stream: Rx.combineLatest<List<MeetAndGreetRequest>,
                List<MeetAndGreetRequest>>(
              requestStreams,
              (listOfLists) => listOfLists.expand((x) => x).toList(),
            ),
            builder: (context, requestsSnapshot) {
              if (requestsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (requestsSnapshot.hasError) {
                return const Center(
                  child: Text("Error fetching meet & greet requests."),
                );
              }

              final allRequests = requestsSnapshot.data ?? [];

              if (allRequests.isEmpty) {
                return const Center(
                  child: Text("No meet & greet requests found."),
                );
              }

              return ListView.builder(
                itemCount: allRequests.length,
                itemBuilder: (context, index) {
                  final request = allRequests[index];
                  final status = request.status;

                  return FutureBuilder<Pet>(
                    future: _fetchPetDetails(request.petId),
                    builder: (context, petSnapshot) {
                      if (petSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          title: Text("Loading pet details..."),
                          trailing: CircularProgressIndicator(),
                        );
                      }

                      if (petSnapshot.hasError) {
                        return const ListTile(
                          title: Text("Error loading pet details"),
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
                          "Requester: ${request.requesterId}\nMeet Date: ${DateFormat.yMMMd().format(request.meetDate)}\nMeet Time: ${request.meetTime}\nStatus: ${status}",
                        ),
                        trailing: status == 'pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: () async {
                                      await _updateRequestStatus(
                                        request.requestId,
                                        "approved",
                                        FirebaseAuth.instance.currentUser!.uid,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () async {
                                      await _updateRequestStatus(
                                        request.requestId,
                                        "rejected",
                                        FirebaseAuth.instance.currentUser!.uid,
                                      );
                                    },
                                  ),
                                ],
                              )
                            : null,
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
