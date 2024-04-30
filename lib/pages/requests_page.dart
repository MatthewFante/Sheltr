import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/meet_and_greet_request.dart';
import 'package:untitled/models/pet.dart';
import 'package:intl/intl.dart';
import 'package:untitled/models/user_profile.dart'; // For fetching user profile
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

  Future<UserProfile> _fetchUserProfile(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      throw Exception("User profile not found");
    }

    return UserProfile.fromDocumentSnapshot(userDoc);
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

          return StreamBuilder<List<MeetAndGreetRequest>>(
            stream: Rx.combineLatest<List<MeetAndGreetRequest>,
                List<MeetAndGreetRequest>>(
              pets.map((pet) =>
                  MeetAndGreetRequest.streamRequestsByPetId(pet.documentId)),
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

              allRequests.sort((a, b) => a.meetDate.compareTo(b.meetDate));

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
                          title: Text("Error loading pet details."),
                        );
                      }

                      final pet = petSnapshot.data;
                      final petName = pet?.name ?? "Unknown";

                      return Card(
                        child: Row(
                          children: [
                            pet?.imageUrls.isNotEmpty == true
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 30, 15, 30),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(pet!.imageUrls[0]),
                                    ),
                                  )
                                : const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(15, 30, 15, 30),
                                    child: CircleAvatar(
                                      child: Icon(Icons.pets),
                                    ),
                                  ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<UserProfile>(
                                  future:
                                      _fetchUserProfile(request.requesterId),
                                  builder: (context, userProfileSnapshot) {
                                    if (userProfileSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text("Loading requester...");
                                    }

                                    if (userProfileSnapshot.hasError) {
                                      return const Text(
                                          "Error loading requester.");
                                    }

                                    final requesterName =
                                        userProfileSnapshot.data?.displayName ??
                                            "Unknown";

                                    return Text("$petName w/ $requesterName",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold));
                                  },
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 240,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${DateFormat.yMMMd().format(request.meetDate)} @ ${request.meetTime}"),
                                          status == "approved"
                                              ? Text(
                                                  status.toUpperCase(),
                                                  style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : Text(
                                                  status.toUpperCase(),
                                                  style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                          request.notes == ""
                                              ? const SizedBox(
                                                  width: 0, height: 0)
                                              : const Text("Notes:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          Text("${request.notes}",
                                              style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.visible,
                                                  fontStyle: FontStyle.italic)),
                                        ],
                                      ),
                                    ),
                                    status == "pending"
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.check,
                                                    color: Colors.green),
                                                onPressed: () async {
                                                  await _updateRequestStatus(
                                                    request.requestId,
                                                    "approved",
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close,
                                                    color: Colors.red),
                                                onPressed: () async {
                                                  await _updateRequestStatus(
                                                    request.requestId,
                                                    "rejected",
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                  );
                                                },
                                              ),
                                            ],
                                          )
                                        : const SizedBox(width: 0, height: 0),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
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
