import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/pet.dart';
import 'package:untitled/models/user_profile.dart';

class PetProfilePage extends StatefulWidget {
  final Pet pet;

  const PetProfilePage({Key? key, required this.pet}) : super(key: key);

  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    isAvailable = widget.pet.available; // Initialize availability status
  }

  Future<String> getCurrentUserType() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return ''; // No user is signed in
    }

    try {
      final userProfileDoc = await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(currentUserId)
          .get();

      if (userProfileDoc.exists) {
        final userProfile = UserProfile.fromDocumentSnapshot(userProfileDoc);
        return userProfile.userType;
      } else {
        return ''; // If no profile found
      }
    } catch (e) {
      debugPrint("Error getting user type: $e");
      return ''; // If there's an error
    }
  }

  void toggleAvailability() async {
    try {
      await Pet.updatePetAvailability(widget.pet.documentId, !isAvailable);
      setState(() {
        isAvailable = !isAvailable; // Update local state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Availability set to ${isAvailable ? "Yes" : "No"}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling availability: $e'),
        ),
      );
    }
  }

  void deletePet() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Delete ${widget.pet.name}?'),
        content: const Text('Are you sure you want to delete this pet?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // Cancel
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true); // Confirm deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await Pet.deletePet(widget.pet.documentId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.pet.name} has been deleted.'),
          ),
        );
        Navigator.pop(context); // Close profile page after deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting pet: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display pet images
            if (widget.pet.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.pet.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        widget.pet.imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16.0),
            Text('Breed: ${widget.pet.breed}',
                style: const TextStyle(fontSize: 18.0)),
            Text('Size: ${widget.pet.size}',
                style: const TextStyle(fontSize: 18.0)),
            Text('Sex: ${widget.pet.sex}',
                style: const TextStyle(fontSize: 18.0)),
            Text(
              'Age: ${widget.pet.age["years"]} years, ${widget.pet.age["months"]} months',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Available: ${isAvailable ? "Yes" : "No"}', // Display availability status
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            FutureBuilder<String>(
              future: getCurrentUserType(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData && snapshot.data == 'user') {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Implement logic for meet & greet request
                        },
                        child: const Text('Request a Meet & Greet'),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox(); // No meet & greet for non-users
                }
              },
            ),
            const SizedBox(height: 16.0),
            FutureBuilder<bool>(
              future: getCurrentUserType().then((value) => value == 'admin'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData &&
                    (snapshot.data! ||
                        currentUserId == widget.pet.createdByUserId)) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: toggleAvailability,
                        child: Text(
                            isAvailable ? 'Set Unavailable' : 'Set Available'),
                      ),
                      ElevatedButton(
                        onPressed: deletePet,
                        child: const Text('Delete Pet'),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox(); // No admin or creator access
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
