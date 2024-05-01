// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// This file contains the Pet class, which represents a pet object in the Firestore database.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Pet {
  String documentId;
  final String createdByUserId;
  final String name;
  final String species;
  final String breed;
  final String size; // small, medium, large
  final String sex; // male, female
  final Map<String, int> age; // { 'years': x, 'months': y }
  final String description;
  final List<String> imageUrls; // Array of image URLs
  final bool available;

  Pet({
    required this.documentId,
    required this.createdByUserId,
    required this.name,
    required this.species,
    required this.breed,
    required this.size,
    required this.sex,
    required this.age,
    required this.description,
    required this.imageUrls,
    required this.available,
  });

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'createdByUserId': createdByUserId,
        'name': name,
        'species': species,
        'breed': breed,
        'size': size,
        'sex': sex,
        'age': age,
        'description': description,
        'imageUrls': imageUrls,
        'available': available,
      };

  static Pet fromJson(Map<String, dynamic> json) => Pet(
        documentId: json['documentId'],
        createdByUserId: json['createdByUserId'],
        name: json['name'],
        species: json['species'],
        breed: json['breed'],
        size: json['size'],
        sex: json['sex'],
        age: Map<String, int>.from(json['age']),
        description: json['description'],
        imageUrls: List<String>.from(json['imageUrls']),
        available: json['available'],
      );

  static Stream<List<Pet>> streamAllPets() => FirebaseFirestore.instance
      .collection('pets')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());

  static Stream<List<Pet>> streamMyPets() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    return FirebaseFirestore.instance
        .collection('pets')
        .where('createdByUserId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());
  }

  static Stream<List<Pet>> streamAvailablePets() => FirebaseFirestore.instance
      .collection('pets')
      .where('available', isEqualTo: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());

  static Future<Pet> createPet(Pet pet) async {
    // Create the new pet document in Firestore
    final petData = pet.toJson();

    // Add the document to Firestore and get the document reference
    final docRef =
        await FirebaseFirestore.instance.collection('pets').add(petData);

    // Get the Firestore-generated document ID
    final documentId = docRef.id;

    // Update the Firestore document to include the document ID
    await FirebaseFirestore.instance.collection('pets').doc(documentId).update({
      'documentId': documentId,
    });

    // Return the updated Pet object with the correct document ID
    return Pet(
      documentId: documentId,
      createdByUserId: pet.createdByUserId,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      size: pet.size,
      sex: pet.sex,
      age: pet.age,
      description: pet.description,
      imageUrls: pet.imageUrls,
      available: pet.available,
    );
  }

  static Future<void> updatePet(String id, Pet pet) async {
    final petData = pet.toJson();
    await FirebaseFirestore.instance.collection('pets').doc(id).update(petData);
  }

  static Future<void> deletePet(String id) async {
    await FirebaseFirestore.instance.collection('pets').doc(id).delete();
  }

  static Future<void> updatePetAvailability(String id, bool available) async {
    await FirebaseFirestore.instance
        .collection('pets')
        .doc(id)
        .update({'available': available});
  }
}
