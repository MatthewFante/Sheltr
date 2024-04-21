import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/widgets/edit_profile_modal.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:untitled/widgets/menu_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(_currentUser.uid)
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
      } else {
        _error = 'User profile not found';
      }
    } catch (e) {
      _error = 'Error fetching user profile';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _userProfile?.profilePictureUrl != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                  _userProfile!.profilePictureUrl!),
                            )
                          : const Icon(Icons.account_circle, size: 100),
                      Text(
                        'Name: ${_userProfile?.displayName ?? "Unknown"}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Email: ${_userProfile?.email ?? "Unknown"}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'User Type: ${_userProfile?.userType ?? "Unknown"}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_userProfile != null) {
                                // Open the Edit Profile Modal
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return EditProfileModal(
                                      userProfile: _userProfile!,
                                    );
                                  },
                                ).then((_) {
                                  // Refresh user profile after closing the modal
                                  _fetchUserProfile(); // This will fetch the updated data
                                });
                              } else {
                                // Show an error message if user profile is null
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Error: User profile not found")),
                                );
                              }
                            },
                            child: const Text('Edit Profile'),
                          ),
                          const SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
