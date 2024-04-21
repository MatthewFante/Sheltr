import 'package:cloud_firestore/cloud_firestore.dart';

class UpgradeRequest {
  final String requestId;
  final String uid;
  final Timestamp requestTime;
  final String status;

  UpgradeRequest({
    required this.requestId,
    required this.uid,
    required this.requestTime,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'uid': uid,
      'requestTime': requestTime,
      'status': status,
    };
  }

  static UpgradeRequest fromDocumentSnapshot(DocumentSnapshot doc) {
    return UpgradeRequest(
      requestId: doc.id,
      uid: doc['uid'],
      requestTime: doc['requestTime'],
      status: doc['status'],
    );
  }
}
