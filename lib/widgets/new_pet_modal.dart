import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/models/pet.dart';
import 'package:untitled/widgets/image_upload_modal.dart';

class NewPetModal extends StatefulWidget {
  const NewPetModal({Key? key}) : super(key: key);

  @override
  _NewPetModalState createState() => _NewPetModalState();
}

class _NewPetModalState extends State<NewPetModal> {
  final nameController = TextEditingController();
  String? selectedSpecies;
  final breedController = TextEditingController();
  String? selectedSize;
  String? selectedSex;
  int? selectedYears;
  int? selectedMonths;
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> imageUrls = [];
  List<String> breedOptions = [];

  Future<String?> _showImageUploadModal(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => const ImageUploadModal(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    final createdByUserId = getCurrentUser()?.uid ?? '';

    return AlertDialog(
      title: const Text('New Pet'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Pet Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pet name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedSpecies,
                decoration: const InputDecoration(
                  hintText: 'Species',
                ),
                items:
                    ['Dog', 'Cat', 'Reptile', 'Bird', 'Other'].map((species) {
                  return DropdownMenuItem<String>(
                    value: species,
                    child: Text(species),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSpecies = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select pet species';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: breedController,
                decoration: const InputDecoration(
                  hintText: 'Pet Breed',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pet breed';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedSize,
                decoration: const InputDecoration(
                  hintText: 'Size',
                ),
                items: ['Small', 'Medium', 'Large'].map((size) {
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSize = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select pet size';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedSex,
                decoration: const InputDecoration(
                  hintText: 'Sex',
                ),
                items: ['Male', 'Female'].map((sex) {
                  return DropdownMenuItem<String>(
                    value: sex,
                    child: Text(sex),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSex = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select pet sex';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedYears,
                      decoration: const InputDecoration(
                        hintText: 'Age (years)',
                      ),
                      items:
                          List.generate(30, (index) => index + 1).map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYears = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select pet age';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMonths,
                      decoration: const InputDecoration(
                        hintText: 'Age (months)',
                      ),
                      items:
                          List.generate(12, (index) => index + 1).map((month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(month.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMonths = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pet description';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(imageUrls.isEmpty
                        ? 'No image selected'
                        : imageUrls.length == 1
                            ? '1 image selected'
                            : '${imageUrls.length} images selected'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: () {
                      _showImageUploadModal(context).then((imageUrl) {
                        if (imageUrl != null) {
                          setState(() {
                            imageUrls.add(imageUrl);
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final name = nameController.text;
              final species = selectedSpecies!;
              final breed = breedController.text;
              final size = selectedSize!;
              final sex = selectedSex!;
              final ageYears = selectedYears!;
              final ageMonths = selectedMonths ?? 0;
              final description = descriptionController.text;

              final age = {'years': ageYears, 'months': ageMonths};

              final newPet = Pet(
                documentId:
                    '', // Temporary placeholder; to be replaced after creation
                createdByUserId: createdByUserId,
                name: name,
                species: species,
                breed: breed,
                size: size,
                sex: sex,
                age: age,
                description: description,
                imageUrls: imageUrls,
                available: true,
              );

              // Create the new pet and receive the updated Pet instance
              final createdPet = await Pet.createPet(newPet);

              // Display a success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pet added successfully!'),
                  duration: Duration(seconds: 1),
                ),
              );

              // Close the dialog
              Navigator.pop(context,
                  createdPet); // Return the createdPet to the previous screen
            }
          },
          child: const Text('Add Pet'),
        ),
      ],
    );
  }
}
