import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  String createdByUserId;
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
    this.createdByUserId = '',
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

  static Stream<List<Pet>> readPets() => FirebaseFirestore.instance
      .collection('pets')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());

  static Future<void> createPet(Pet pet) async {
    final petData = pet.toJson();
    await FirebaseFirestore.instance.collection('pets').add(petData);
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

  static Stream<List<Pet>> streamAvailablePets() => FirebaseFirestore.instance
      .collection('pets')
      .where('available', isEqualTo: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Pet.fromJson(doc.data())).toList());
}
