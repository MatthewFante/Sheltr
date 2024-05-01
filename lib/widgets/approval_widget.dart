// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// This file contains the ApprovalWidget class, which displays a single upgrade request for approval.

import 'package:flutter/material.dart';
import 'package:untitled/models/upgrade_request.dart';
import 'package:untitled/models/user_profile.dart';

class ApprovalWidget extends StatelessWidget {
  final UpgradeRequest request;
  final Future<UserProfile?> Function(String) getUserProfile;
  final Future<void> Function(String, String) approveRequest;
  final Future<void> Function(String) rejectRequest;

  const ApprovalWidget({
    required this.request,
    required this.getUserProfile,
    required this.approveRequest,
    required this.rejectRequest,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder<UserProfile?>(
        future: getUserProfile(request.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const ListTile(title: Text("Loading user data..."));
          }

          if (userSnapshot.hasError) {
            return ListTile(
              title: Text('Error loading user data'),
            );
          }

          final userProfile = userSnapshot.data;
          final displayName = userProfile?.displayName ?? 'Unknown User';

          return ListTile(
            title: Text('Request from: $displayName'),
            leading: const Icon(Icons.person),
            subtitle: Text(
              'Requested on: ${request.requestTime.toDate()}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    approveRequest(request.requestId, request.uid);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    rejectRequest(request.requestId);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
