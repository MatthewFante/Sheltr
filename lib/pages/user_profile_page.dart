import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/upgrade_request.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/pages/pets_feed_page.dart';
import 'package:untitled/widgets/edit_user_profile_modal.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:untitled/widgets/menu_scaffold.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({super.key, required this.user});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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

  Future<void> sendUpgradeRequest() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('upgrade_requests')
          .where('uid', isEqualTo: _currentUser.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (query.docs.isNotEmpty) {
        // If there's already a pending request, inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You have already requested an upgrade.')),
        );
        return;
      }

      // Create a new upgrade request
      final upgradeRequest = UpgradeRequest(
        uid: _currentUser.uid,
        status: 'pending',
        requestTime: Timestamp.now(),
        requestId: '',
      );

      // Add the request and update its ID
      final docRef = await FirebaseFirestore.instance
          .collection('upgrade_requests')
          .add(upgradeRequest.toMap());

      await docRef.update({'requestId': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upgrade request sent successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send upgrade request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                      const SizedBox(height: 32.0),
                      Text(
                        'Name: ${_userProfile?.displayName ?? "Unknown"}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Email: ${_userProfile?.email ?? "Unknown"}',
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
                                    return EditUserProfileModal(
                                      userProfile: _userProfile!,
                                    );
                                  },
                                ).then((_) {
                                  _fetchUserProfile(); // Refresh data after closing the modal
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('User profile not found')),
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
                                  builder: (context) => const MenuScaffold(),
                                ),
                              );
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                      if (_userProfile?.userType == 'user')
                        ElevatedButton(
                          onPressed: sendUpgradeRequest,
                          child: const Text('Upgrade account'),
                        ),
                    ],
                  ),
                ),
    );
  }
}
