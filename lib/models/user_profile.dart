import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String email;
  final String? displayName;
  final String userType; // Can be 'admin', 'shelter', or 'user'
  final String? profilePictureUrl; // Optional profile picture
  final List<String>? favoritePets; // Optional list of pet IDs

  UserProfile({
    required this.userId,
    required this.email,
    required this.userType,
    this.displayName,
    this.profilePictureUrl,
    this.favoritePets,
  });

  // Method to create UserProfile object from Firestore DocumentSnapshot
  factory UserProfile.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserProfile(
      userId: snapshot.id,
      email: data['email'] ?? '',
      userType:
          data['userType'] ?? 'user', // Default to 'user' if not specified
      displayName: data['displayName'],
      profilePictureUrl: data['profilePictureUrl'],
      favoritePets: data['favoritePets'] != null
          ? List<String>.from(data['favoritePets'])
          : null,
    );
  }

  // Method to convert UserProfile object to a Map (for storing in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'userType': userType,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'favoritePets': favoritePets,
    };
  }

  // Factory method to create UserProfile from a Map
  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId:
          map.containsKey('userId') ? map['userId'] : '', // Default if missing
      email: map.containsKey('email') ? map['email'] : '',
      userType: map.containsKey('userType')
          ? map['userType']
          : 'user', // Default to 'user'
      displayName: map.containsKey('displayName') ? map['displayName'] : null,
      profilePictureUrl: map.containsKey('profilePictureUrl')
          ? map['profilePictureUrl']
          : null,
      favoritePets: map.containsKey('favoritePets')
          ? List<String>.from(map['favoritePets'])
          : null,
    );
  }
}
