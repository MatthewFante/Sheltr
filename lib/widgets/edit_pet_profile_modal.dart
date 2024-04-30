import 'package:flutter/material.dart';
import 'package:untitled/models/pet.dart';

class EditPetProfileModal extends StatefulWidget {
  final Pet pet;

  const EditPetProfileModal({Key? key, required this.pet}) : super(key: key);

  @override
  _EditPetProfileModalState createState() => _EditPetProfileModalState();
}

class _EditPetProfileModalState extends State<EditPetProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _descriptionController;

  late String _selectedSpecies;
  late String _selectedSize;
  late String _selectedSex;
  late int _selectedAgeYears;
  late int _selectedAgeMonths;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed);
    _descriptionController =
        TextEditingController(text: widget.pet.description);

    _selectedSpecies = widget.pet.species;
    _selectedSize = widget.pet.size;
    _selectedSex = widget.pet.sex;
    _selectedAgeYears = widget.pet.age["years"]!;
    _selectedAgeMonths = widget.pet.age["months"]!;
    _isAvailable = widget.pet.available;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updatePet() async {
    if (_formKey.currentState!.validate()) {
      final updatedPet = Pet(
        documentId: widget.pet.documentId,
        createdByUserId: widget.pet.createdByUserId,
        name: _nameController.text,
        species: _selectedSpecies,
        breed: _breedController.text,
        size: _selectedSize,
        sex: _selectedSex,
        age: {
          "years": _selectedAgeYears,
          "months": _selectedAgeMonths,
        },
        description: _descriptionController.text,
        imageUrls: widget.pet.imageUrls,
        available: _isAvailable,
      );

      try {
        await Pet.updatePet(widget.pet.documentId, updatedPet);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pet profile updated successfully!")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating pet profile: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Edit Pet Profile",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the pet's name.";
                  }
                  return null;
                },
              ),
              // Species Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: InputDecoration(labelText: "Species"),
                items: ["Dog", "Cat", "Bird", "Reptile", "Other"]
                    .map((species) =>
                        DropdownMenuItem(value: species, child: Text(species)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value!;
                  });
                },
              ),
              // Breed Field
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(labelText: "Breed"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the pet's breed.";
                  }
                  return null;
                },
              ),
              // Size Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSize,
                decoration: InputDecoration(labelText: "Size"),
                items: ["Small", "Medium", "Large"]
                    .map((size) =>
                        DropdownMenuItem(value: size, child: Text(size)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSize = value!;
                  });
                },
              ),
              // Sex Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSex,
                decoration: InputDecoration(labelText: "Sex"),
                items: ["Male", "Female"]
                    .map(
                        (sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSex = value!;
                  });
                },
              ),
              // Age Fields
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedAgeYears,
                      decoration: InputDecoration(labelText: "Age (years)"),
                      items: List.generate(30, (i) => i)
                          .map((year) => DropdownMenuItem(
                              value: year, child: Text(year.toString())))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAgeYears = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedAgeMonths,
                      decoration: InputDecoration(labelText: "Age (months)"),
                      items: List.generate(12, (i) => i)
                          .map((month) => DropdownMenuItem(
                              value: month, child: Text(month.toString())))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAgeMonths = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description.";
                  }
                  return null;
                },
                maxLines: 3,
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _updatePet,
                    child: Text("Save Changes"),
                  ),
                  Column(
                    children: [
                      Text("Available:"),
                      Switch(
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
