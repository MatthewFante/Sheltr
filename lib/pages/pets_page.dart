import 'package:flutter/material.dart';
import 'package:untitled/models/pet.dart'; // Replace 'your_project_name' with your actual project name
import 'package:untitled/pages/pet_profile_page.dart'; // Replace 'your_project_name' with your actual project name
import 'package:untitled/widgets/new_pet_dialog.dart'; // Replace 'your_project_name' with your actual project name

class PetsPage extends StatefulWidget {
  const PetsPage({Key? key}) : super(key: key);

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  bool showAddPetButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Pet>>(
        stream: Pet.readPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                return NewPetDialog();
              },
            );
          },
        ),
      ),
    );
  }
}
