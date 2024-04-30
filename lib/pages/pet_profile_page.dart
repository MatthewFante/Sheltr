import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/pet.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/widgets/edit_pet_profile_modal.dart';
import 'package:untitled/widgets/new_meet_and_greet_request_modal.dart';

class PetProfilePage extends StatefulWidget {
  final Pet pet;

  const PetProfilePage({Key? key, required this.pet}) : super(key: key);

  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  late bool isAvailable;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isAvailable = widget.pet.available; // Initialize availability status
    _checkIfFavorite(); // Check if this pet is already a favorite
  }

  void _checkIfFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      final userProfile = UserProfile.fromDocumentSnapshot(userDoc);
      final favoritePets = userProfile.favoritePets ?? [];
      setState(() {
        isFavorite = favoritePets.contains(widget.pet.documentId);
      });
    }
  }

  void _toggleFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(currentUser.uid);

    if (isFavorite) {
      // Remove pet from favorites
      await userDoc.update({
        'favoritePets': FieldValue.arrayRemove([widget.pet.documentId]),
      });
      setState(() {
        isFavorite = false; // Update local state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from favorites.")),
      );
    } else {
      // Add pet to favorites
      await userDoc.update({
        'favoritePets': FieldValue.arrayUnion([widget.pet.documentId]),
      });
      setState(() {
        isFavorite = true; // Update local state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to favorites.")),
      );
    }
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
            'Marked ${isAvailable ? "available" : "unavailable"}',
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
        backgroundColor: const Color(0xff990000),
        title: const Text(
          'Pet Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          FutureBuilder<String>(
            future: getCurrentUserType(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show loading indicator while fetching user type
              }

              if (snapshot.hasError || snapshot.data != "user") {
                return const SizedBox
                    .shrink(); // Don't show anything if not user type
              }

              // Show the favorite toggle only if user type is 'user'
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite, // Toggle favorite status
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Name',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Text(widget.pet.name),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Species',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Text(widget.pet.species),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Breed',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Text(widget.pet.breed),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Size',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Text(widget.pet.size),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Sex',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Text(widget.pet.sex),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Age',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Text(
                            '${widget.pet.age["years"]}yr, ${widget.pet.age["months"]}mo'),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 16.0),
                const Text('Description',
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold)),
                Text(widget.pet.description,
                    style: const TextStyle(fontSize: 18.0)),
                const SizedBox(height: 65),
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                // color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    FutureBuilder<String>(
                      future: getCurrentUserType(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasData && snapshot.data == 'user') {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all<Size>(
                                        const Size(250, 60))),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        NewMeetAndGreetRequestModal(
                                            pet: widget.pet),
                                  );
                                },
                                child: const Text('Request a Meet & Greet',
                                    style: TextStyle(color: Color(0xff990000))),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox(); // No meet & greet for non-users
                        }
                      },
                    ),
                    FutureBuilder<bool>(
                      future: getCurrentUserType()
                          .then((value) => value == 'admin'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all<Size>(
                                        const Size(170, 60))),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        EditPetProfileModal(pet: widget.pet),
                                  );
                                },
                                child: const Text('Edit Pet',
                                    style: TextStyle(color: Color(0xff990000))),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all<Size>(
                                        const Size(170, 60))),
                                onPressed: deletePet,
                                child: const Text('Delete Pet',
                                    style: TextStyle(color: Color(0xff990000))),
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
              ))
        ],
      ),
    );
  }
}
