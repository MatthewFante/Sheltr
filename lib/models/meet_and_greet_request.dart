// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// This file contains the MeetAndGreetRequest class, which represents a meet-and-greet request object in the Firestore database.

import 'package:cloud_firestore/cloud_firestore.dart';

class MeetAndGreetRequest {
  final String requestId;
  final String requesterId;
  final String petId;
  final DateTime meetDate;
  final String meetTime;
  final String status;
  final DateTime createDate;
  final DateTime? updateDate;
  final String? lastUpdatedBy;
  final String? notes;

  MeetAndGreetRequest({
    required this.requestId,
    required this.requesterId,
    required this.petId,
    required this.meetDate,
    required this.meetTime,
    required this.status,
    required this.createDate,
    this.updateDate,
    this.lastUpdatedBy,
    this.notes,
  });

  // Convert the object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'requesterId': requesterId,
      'petId': petId,
      'meetDate': meetDate.toIso8601String(),
      'meetTime': meetTime,
      'status': status,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'lastUpdatedBy': lastUpdatedBy,
      'notes': notes,
    };
  }

  // Convert from Firestore Map to object
  static MeetAndGreetRequest fromMap(Map<String, dynamic> map) {
    return MeetAndGreetRequest(
      requestId: map['requestId'],
      requesterId: map['requesterId'],
      petId: map['petId'],
      meetDate: DateTime.parse(map['meetDate']),
      meetTime: map['meetTime'],
      status: map['status'],
      createDate: DateTime.parse(map['createDate']),
      updateDate: map.containsKey('updateDate') && map['updateDate'] != null
          ? DateTime.parse(map['updateDate'])
          : null,
      lastUpdatedBy: map['lastUpdatedBy'],
      notes: map['notes'],
    );
  }

  // Create a new meet-and-greet request in Firestore
  static Future<MeetAndGreetRequest> createMeetAndGreetRequest({
    required String requesterId,
    required String petId,
    required DateTime meetDate,
    required String meetTime,
    String notes = '',
  }) async {
    // Create the initial meet and greet request data
    final createDate = DateTime.now();
    final newRequest = MeetAndGreetRequest(
      requestId: '',
      requesterId: requesterId,
      petId: petId,
      meetDate: meetDate,
      meetTime: meetTime,
      status: 'pending', // Default status
      createDate: createDate,
      notes: notes,
    );

    // Add to Firestore and get the generated document ID
    final docRef = await FirebaseFirestore.instance
        .collection('meet_and_greet_requests')
        .add(newRequest.toMap());

    // Update the requestId in the object
    final updatedRequest = newRequest.copyWith(
      requestId: docRef.id,
    );

    // Update Firestore with the correct requestId
    await FirebaseFirestore.instance
        .collection('meet_and_greet_requests')
        .doc(docRef.id)
        .update({
      'requestId': docRef.id,
    });

    return updatedRequest;
  }

  MeetAndGreetRequest copyWith({
    String? requestId,
    String? requesterId,
    String? petId,
    DateTime? meetDate,
    String? meetTime,
    String? status,
    DateTime? createDate,
    DateTime? updateDate,
    String? lastUpdatedBy,
    String? notes,
  }) {
    return MeetAndGreetRequest(
      requestId: requestId ?? this.requestId,
      requesterId: requesterId ?? this.requesterId,
      petId: petId ?? this.petId,
      meetDate: meetDate ?? this.meetDate,
      meetTime: meetTime ?? this.meetTime,
      status: status ?? this.status,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      notes: notes ?? this.notes,
    );
  }

  // Update an existing meet-and-greet request in Firestore
  static Future<void> updateMeetAndGreetRequest(
    String requestId, {
    required String status,
    required String lastUpdatedBy,
    DateTime? meetDate,
    String? meetTime,
    String? notes,
  }) async {
    final updateData = {
      'status': status,
      'lastUpdatedBy': lastUpdatedBy,
      'updateDate': DateTime.now().toIso8601String(),
    };

    if (meetDate != null) {
      updateData['meetDate'] = meetDate.toIso8601String();
    }

    if (meetTime != null) {
      updateData['meetTime'] = meetTime;
    }

    if (notes != null) {
      updateData['notes'] = notes;
    }

    await FirebaseFirestore.instance
        .collection('meet_and_greet_requests')
        .doc(requestId)
        .update(updateData);
  }

  static Future<void> deleteMeetAndGreetRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('meet_and_greet_requests')
        .doc(requestId)
        .delete();
  }

  // Stream meet-and-greet requests by pet ID
  static Stream<List<MeetAndGreetRequest>> streamRequestsByPetId(
    String petId,
  ) {
    return FirebaseFirestore.instance
        .collection('meet_and_greet_requests')
        .where('petId', isEqualTo: petId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MeetAndGreetRequest.fromMap(doc.data()))
            .toList());
  }

  // Stream meet-and-greet requests by requester ID
  static Stream<List<MeetAndGreetRequest>> streamRequestsByRequesterId(
    String requesterId,
  ) {
    return FirebaseFirestore.instance
        .collection('meet_and_greet_requests')
        .where('requesterId', isEqualTo: requesterId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MeetAndGreetRequest.fromMap(doc.data()))
            .toList());
  }
}
