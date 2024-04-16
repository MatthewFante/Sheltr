import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:untitled/models/pet.dart';
import 'package:untitled/widgets/image_upload_modal.dart';

class NewPetDialog extends StatefulWidget {
  const NewPetDialog({Key? key}) : super(key: key);

  @override
  _NewPetDialogState createState() => _NewPetDialogState();
}

class _NewPetDialogState extends State<NewPetDialog> {
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

  Future<void> loadBreedOptions(String species) async {
    String csvFileName = '';
    if (species == 'Dog') {
      csvFileName = 'dog_breeds.csv';
    } else if (species == 'Cat') {
      csvFileName = 'cat_breeds.csv';
    } else {
      csvFileName = 'other_breeds.csv';
    }

    // Load CSV file from assets
    String data = await rootBundle.loadString('lib/assets/$csvFileName');

    // Parse CSV data
    List<List<dynamic>> csvTable = CsvToListConverter().convert(data);

    List<String> breeds = [];
    for (var row in csvTable) {
      breeds.add(row[0]);
    }

    setState(() {
      breedOptions = breeds;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadBreedOptions(selectedSpecies ?? ''); // Load breeds initially
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
                items: ['Dog', 'Cat', 'Other'].map((species) {
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
              DropdownButtonFormField<String>(
                value: breedController.text,
                decoration: const InputDecoration(
                  hintText: 'Breed',
                ),
                items: breedOptions.map((breed) {
                  return DropdownMenuItem<String>(
                    value: breed,
                    child: Text(breed),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    breedController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select pet breed';
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

              final pet = Pet(
                createdByUserId: createdByUserId,
                name: name,
                species: species,
                breed: breed,
                size: size,
                sex: sex,
                age: age,
                description: description,
                imageUrls: imageUrls,
                available: true, // Assuming pet is available by default
              );

              await Pet.createPet(pet);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pet added successfully!'),
                  duration: Duration(seconds: 1),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add Pet'),
        ),
      ],
    );
  }
}
