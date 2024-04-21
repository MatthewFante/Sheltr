import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/upgrade_request.dart';
import 'package:untitled/models/user_profile.dart';

class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({Key? key}) : super(key: key);

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  Stream<List<UpgradeRequest>> getPendingRequests() {
    return FirebaseFirestore.instance
        .collection('upgrade_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => UpgradeRequest.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(uid)
        .get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> approveRequest(String requestId, String uid) async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Update the upgrade request status to 'approved'
      await firestore.collection('upgrade_requests').doc(requestId).update({
        'status': 'approved',
      });

      // Update the user role to 'shelter' in user_profiles
      await firestore.collection('user_profiles').doc(uid).update({
        'userType': 'shelter',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Request approved, user upgraded to shelter')),
      );
    } catch (e) {
      print("Error approving request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving request: $e')),
      );
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('upgrade_requests')
          .doc(requestId)
          .update({
        'status': 'rejected',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected')),
      );
    } catch (e) {
      print("Error rejecting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Approvals'),
      ),
      body: StreamBuilder<List<UpgradeRequest>>(
        stream: getPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final requests = snapshot.data;

          if (requests == null || requests.isEmpty) {
            return const Center(
              child: Text('No pending upgrade requests'),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                child: FutureBuilder<UserProfile?>(
                  future: getUserProfile(request.uid),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        title: Text("Loading user data..."),
                      );
                    }

                    if (userSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error loading user data'),
                      );
                    }

                    final userProfile = userSnapshot.data;
                    final displayName =
                        userProfile?.displayName ?? 'Unknown User';

                    return ListTile(
                      title: Text('Request from: $displayName'),
                      subtitle:
                          Text('Requested on: ${request.requestTime.toDate()}'),
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
            },
          );
        },
      ),
    );
  }
}
