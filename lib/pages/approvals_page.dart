import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/upgrade_request.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/widgets/approval_widget.dart';

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
    try {
      await FirebaseFirestore.instance
          .collection('upgrade_requests')
          .doc(requestId)
          .update({
        'status': 'approved',
      });

      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(uid)
          .update({
        'userType': 'shelter',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Request approved, user upgraded to shelter')),
      );
    } catch (e) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<UpgradeRequest>>(
        stream: getPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final requests = snapshot.data;

          if (requests == null || requests.isEmpty) {
            return const Center(child: Text('No pending upgrade requests'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return ApprovalWidget(
                request: request,
                getUserProfile: getUserProfile,
                approveRequest: approveRequest,
                rejectRequest: rejectRequest,
              );
            },
          );
        },
      ),
    );
  }
}
