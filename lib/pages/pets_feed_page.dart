import 'package:flutter/material.dart';
import 'package:untitled/models/pet.dart';
import 'package:untitled/pages/pet_profile_page.dart';
import 'package:untitled/widgets/new_pet_dialog.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({Key? key}) : super(key: key);

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool showAddPetButton = false; // Initially hide the button

  String userRole = 'user'; // Default to 'user'

  @override
  void initState() {
    super.initState();
    getCurrentUserRole().then((role) {
      setState(() {
        userRole = role;
        showAddPetButton =
            role == 'shelter'; // Show button only for 'admin' or 'shelter'
      });
    });
  }

  Future<String> getCurrentUserRole() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception("No user logged in");
      }

      final userDoc = await _firestore
          .collection('user_profiles')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User profile does not exist");
      }

      final UserProfile userProfile = UserProfile.fromDocumentSnapshot(userDoc);

      return userProfile.userType; // Return the user's role
    } catch (e) {
      print("Error fetching user role: $e");
      return 'user'; // Default to 'user' on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Pet>>(
        stream: Pet.readPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final pets = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 images wide
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              childAspectRatio: 1.0, // Square aspect ratio
            ),
            itemCount: pets.length,
            itemBuilder: (BuildContext context, int index) {
              final pet = pets[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to the pet profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetProfilePage(pet: pet),
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 1.0, // Ensure each image is square
                  child: pet.imageUrls.isNotEmpty
                      ? Image.network(
                          pet.imageUrls.first, // Display the first image
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'lib/assets/placeholder.jpeg'), // Display a placeholder if no image URLs
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: showAddPetButton,
        child: FloatingActionButton.extended(
          label: const Text('Add Pet', style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xff990000),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const NewPetDialog();
              },
            );
          },
        ),
      ),
    );
  }
}
