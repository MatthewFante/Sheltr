import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String email;
  final String? displayName;
  final String userType; // Can be 'admin', 'shelter', or 'user'
  final String? profilePictureUrl; // Optional profile picture
  final List<String>? favoritePets; // Optional list of pet IDs
  final String? phoneNumber; // Optional phone number
  final String? address; // Optional address
  final String? city; // Optional city
  final String? state; // Optional state
  final String? zipCode; // Optional zip code
  final String? hoursOfOperation; // Optional hours of operation
  final String? website; // Optional website
  final String? bio; // Optional bio

  UserProfile({
    required this.userId,
    required this.email,
    required this.userType,
    this.displayName,
    this.profilePictureUrl,
    this.favoritePets,
    this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.hoursOfOperation,
    this.website,
    this.bio,
  });

  factory UserProfile.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data =
        snapshot.data() as Map<String, dynamic>? ?? {}; // Ensure data is a map

    return UserProfile(
      userId: snapshot.id,
      email: data['email'] ?? '',
      userType: data.containsKey('userType')
          ? data['userType']
          : 'user', // Default to 'user'
      displayName: data['displayName'] as String?,
      profilePictureUrl: data['profilePictureUrl'] as String?,
      favoritePets: data['favoritePets'] is List
          ? List<String>.from(data['favoritePets'])
          : null,
      phoneNumber: data['phoneNumber'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      zipCode: data['zipCode'] as String?,
      hoursOfOperation: data['hoursOfOperation'] as String?,
      website: data['website'] as String?,
      bio: data['bio'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'userType': userType,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'favoritePets': favoritePets,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'hoursOfOperation': hoursOfOperation,
      'website': website,
      'bio': bio,
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId:
          map.containsKey('userId') ? map['userId'] : '', // Default if missing
      email: map.containsKey('email') ? map['email'] : '',
      userType: map.containsKey('userType')
          ? map['userType']
          : 'user', // Default to 'user'
      displayName: map['displayName'] as String?,
      profilePictureUrl: map['profilePictureUrl'] as String?,
      favoritePets: map['favoritePets'] is List
          ? List<String>.from(map['favoritePets'])
          : null,
      phoneNumber: map['phoneNumber'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      zipCode: map['zipCode'] as String?,
      hoursOfOperation: map['hoursOfOperation'] as String?,
      website: map['website'] as String?,
      bio: map['bio'] as String?,
    );
  }
}
