import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/widgets/image_upload_modal.dart';

class EditProfileModal extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileModal({required this.userProfile});

  @override
  _EditProfileModalState createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController _displayNameController;
  String? _profilePictureUrl;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.userProfile.displayName);
    _profilePictureUrl = widget.userProfile.profilePictureUrl;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final userId = widget.userProfile.userId;

    // Check if userId is valid
    if (userId.isEmpty) {
      print("Error: userId is empty");
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedProfile = UserProfile(
        userId: userId, // Ensure this is valid
        email: widget.userProfile.email,
        userType: widget.userProfile.userType, // Cannot be changed
        displayName: _displayNameController.text,
        profilePictureUrl: _profilePictureUrl,
      );

      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(userId) // Ensure this is valid
          .update(updatedProfile.toMap());

      setState(() {
        _isUpdating = false;
      });

      Navigator.of(context).pop(); // Close the modal
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      print("Error updating profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Profile"),
      content: Column(
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
          if (_profilePictureUrl != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text("Profile Picture URL:"),
                SelectableText(_profilePictureUrl!), // Make it selectable
              ],
            ),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const ImageUploadModal(); // open the modal to upload
                },
              ).then((imageUrl) {
                if (imageUrl != null) {
                  setState(() {
                    _profilePictureUrl = imageUrl; // Update with new URL
                  });
                }
              });
            },
            child: const Text("Change Profile Picture"),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _isUpdating ? null : _updateProfile,
          child: _isUpdating
              ? const CircularProgressIndicator()
              : const Text("Update Profile"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close the modal
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
