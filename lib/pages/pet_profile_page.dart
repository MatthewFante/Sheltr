import 'package:flutter/material.dart';
import 'package:untitled/models/pet.dart';

class PetProfilePage extends StatelessWidget {
  final Pet pet;

  const PetProfilePage({Key? key, required this.pet}) : super(key: key);

  void toggleAvailability(BuildContext context) async {
    try {
      await Pet.updatePetAvailability(pet.documentId, !pet.available);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Availability set to ${pet.available ? "No" : "Yes"}',
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

  void deletePet(BuildContext context) async {
    // Show a confirmation dialog before deleting
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${pet.name}?'),
          content: Text('Are you sure you want to delete this pet?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Cancel
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirm
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await Pet.deletePet(pet.documentId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pet.name} has been deleted.'),
          ),
        );
        Navigator.pop(context); // Close the current screen after deletion
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
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display pet images if available
            if (pet.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pet.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        pet.imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              'Breed: ${pet.breed}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Size: ${pet.size}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Sex: ${pet.sex}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Age: ${pet.age['years']} years ${pet.age['months']} months',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description: ${pet.description}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Available: ${pet.available ? "Yes" : "No"}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement logic for adoption or other actions
                  },
                  child: Text('Request a Meet & Greet'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    toggleAvailability(context);
                  },
                  child: Text('Toggle Availability'),
                ),
                ElevatedButton(
                  onPressed: () {
                    deletePet(context);
                  },
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
