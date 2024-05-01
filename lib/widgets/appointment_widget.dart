// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// This file contains the AppointmentWidget class, which displays a single meet-and-greet request in a card format.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/models/meet_and_greet_request.dart';
import 'package:untitled/models/pet.dart';

class AppointmentWidget extends StatelessWidget {
  final MeetAndGreetRequest request;
  final Future<Pet> Function(String) fetchPetDetails;
  final Future<void> Function(String) cancelRequest;

  const AppointmentWidget({
    required this.request,
    required this.fetchPetDetails,
    required this.cancelRequest,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pet>(
      future: fetchPetDetails(request.petId),
      builder: (context, petSnapshot) {
        if (petSnapshot.connectionState == ConnectionState.waiting) {
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
        final petImageUrl =
            pet?.imageUrls.isNotEmpty == true ? pet!.imageUrls[0] : null;

        return Card(
          elevation: 1, // Add a subtle shadow
          child: Row(
            children: [
              petImageUrl != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(petImageUrl),
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
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                        "${DateFormat.yMMMd().format(request.meetDate)} @ ${request.meetTime}"),
                    request.status == "approved"
                        ? Text(request.status.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold))
                        : Text(request.status.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ElevatedButton(
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
                    await cancelRequest(request.requestId);
                  }
                },
                child: const Text("Cancel",
                    style: TextStyle(color: Color(0xff990000))),
              ),
            ],
          ),
        );
      },
    );
  }
}
