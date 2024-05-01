// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// This file contains the EditUserProfileModal widget, which allows users to edit their profile information.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/widgets/image_upload_modal.dart';

class EditUserProfileModal extends StatefulWidget {
  final UserProfile userProfile;

  const EditUserProfileModal({required this.userProfile});

  @override
  _EditUserProfileModalState createState() => _EditUserProfileModalState();
}

class _EditUserProfileModalState extends State<EditUserProfileModal> {
  late TextEditingController _displayNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  late TextEditingController _zipCodeController;
  late TextEditingController _hoursOfOperationController;
  late TextEditingController _websiteController;
  String? _profilePictureUrl;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _profilePictureUrl = widget.userProfile.profilePictureUrl;

    // Initialize controllers with existing profile data
    _displayNameController = TextEditingController(
      text: widget.userProfile.displayName ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: widget.userProfile.phoneNumber ?? '',
    );
    _cityController = TextEditingController(
      text: widget.userProfile.city ?? '',
    );
    _stateController = TextEditingController(
      text: widget.userProfile.state ?? '',
    );
    _bioController = TextEditingController(
      text: widget.userProfile.bio ?? '',
    );
    _addressController = TextEditingController(
      text: widget.userProfile.address ?? '',
    );
    _zipCodeController = TextEditingController(
      text: widget.userProfile.zipCode ?? '',
    );
    _hoursOfOperationController = TextEditingController(
      text: widget.userProfile.hoursOfOperation ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.userProfile.website ?? '',
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _hoursOfOperationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final userId = widget.userProfile.userId;

    if (userId.isEmpty) {
      print("Error: userId is empty");
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Updated user profile with all optional fields
      final updatedProfile = UserProfile(
        userId: userId,
        email: widget.userProfile.email,
        userType: widget.userProfile.userType,
        displayName: _displayNameController.text,
        profilePictureUrl: _profilePictureUrl,
        favoritePets: widget.userProfile.favoritePets, // Retain favorite pets
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        hoursOfOperation: _hoursOfOperationController.text,
        website: _websiteController.text,
        bio: _bioController.text,
      );

      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(userId)
          .update(updatedProfile.toMap());

      setState(() {
        _isUpdating = false;
      });

      Navigator.of(context).pop(); // Close modal after successful update
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isShelter = widget.userProfile.userType == "shelter";

    return AlertDialog(
      title: const Text("Edit Profile"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_profilePictureUrl != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(_profilePictureUrl!),
              )
            else
              const Icon(Icons.account_circle, size: 80),
            const SizedBox(height: 16),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: "Display Name"),
            ),
            if (isShelter)
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: "City"),
            ),
            TextField(
              controller: _stateController,
              decoration: const InputDecoration(labelText: "State"),
            ),
            TextField(
              controller: _zipCodeController,
              decoration: const InputDecoration(labelText: "Zip Code"),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: "Bio"),
              maxLines: 3, // Allow multiline for bio
            ),
            if (isShelter) ...[
              TextField(
                controller: _hoursOfOperationController,
                decoration:
                    const InputDecoration(labelText: "Hours of Operation"),
              ),
              TextField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: "Website"),
                keyboardType: TextInputType.url,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return const ImageUploadModal(); // to upload a profile picture
                  },
                ).then((imageUrl) {
                  if (imageUrl != null) {
                    setState(() {
                      _profilePictureUrl = imageUrl;
                    });
                  }
                });
              },
              child: const Text("Change Profile Picture"),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isUpdating ? null : _updateProfile,
          child: _isUpdating
              ? const CircularProgressIndicator()
              : const Text("Update Profile"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close modal
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
