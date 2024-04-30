import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/models/upgrade_request.dart';
import 'package:untitled/widgets/edit_user_profile_modal.dart';
import 'package:untitled/widgets/menu_scaffold.dart';

class UserProfilePage extends StatefulWidget {
  final String userId; // The ID of the profile to be viewed

  const UserProfilePage({super.key, required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserProfile? _userProfile; // Holds the fetched user profile
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
      } else {
        _error = 'User profile not found';
      }
    } catch (e) {
      _error = 'Error fetching user profile: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> sendUpgradeRequest() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('upgrade_requests')
          .where('uid', isEqualTo: widget.userId) // Use the correct userId
          .where('status', isEqualTo: 'pending')
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You have already requested an upgrade.')),
        );
        return;
      }

      final upgradeRequest = UpgradeRequest(
        uid: widget.userId, // Use the correct userId
        status: 'pending',
        requestTime: Timestamp.now(),
        requestId: '',
      );

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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Text(
            'Error: $_error',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final isShelter = _userProfile?.userType == 'shelter';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _userProfile?.profilePictureUrl != null
                  ? CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          NetworkImage(_userProfile!.profilePictureUrl!),
                    )
                  : const Icon(Icons.account_circle, size: 120),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _userProfile?.displayName ?? "Unknown",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.email),
                ),
                Text(
                  _userProfile?.email ?? "Unknown",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            if (_userProfile?.phoneNumber != null &&
                _userProfile!.phoneNumber!.isNotEmpty)
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Icon(Icons.phone),
                  ),
                  Text(
                    '${_userProfile!.phoneNumber}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            if (_userProfile?.bio != null && _userProfile!.bio!.isNotEmpty)
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.account_circle),
                  ),
                  SizedBox(
                    width: 300, // Use width to fit longer text
                    child: Text(
                      '${_userProfile!.bio}',
                      overflow:
                          TextOverflow.visible, // Allow overflow to wrap text
                    ),
                  ),
                ],
              ),
            if (isShelter) ...[
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.location_on),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_userProfile?.address != null &&
                          _userProfile!.address!.isNotEmpty)
                        Text(
                          '${_userProfile!.address}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      Row(
                        children: [
                          if (_userProfile!.city != null)
                            Text(
                              '${_userProfile!.city}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          if (_userProfile!.state != null &&
                              _userProfile!.city != null)
                            const Text(", "),
                          if (_userProfile!.state != null)
                            Text(
                              '${_userProfile!.state}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          Text(
                            ' ${_userProfile!.zipCode}', // Zip code should be shown if available
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (_userProfile?.hoursOfOperation != null &&
                  _userProfile!.hoursOfOperation!.isNotEmpty)
                Row(children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.access_time),
                  ),
                  Text(
                    '${_userProfile!.hoursOfOperation}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ]),
              if (_userProfile?.website != null &&
                  _userProfile!.website!.isNotEmpty)
                Row(children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.web),
                  ),
                  Text(
                    '${_userProfile!.website}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ]),
            ],
            // Check if there's a logged-in user before showing these options
            if (FirebaseAuth.instance.currentUser != null) ...[
              if (_userProfile?.userId ==
                  FirebaseAuth.instance.currentUser!.uid)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_userProfile != null) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EditUserProfileModal(
                                userProfile: _userProfile!,
                              );
                            },
                          ).then((_) {
                            _fetchUserProfile(); // Refresh after editing
                          });
                        }
                      },
                      child: const Text("Edit Profile"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MenuScaffold(),
                          ),
                        );
                      },
                      child: const Text("Sign Out"),
                    ),
                  ],
                ),
              if (FirebaseAuth.instance.currentUser!.uid ==
                  _userProfile?.userId)
                Center(
                  child: ElevatedButton(
                    onPressed: sendUpgradeRequest,
                    child: const Text("Upgrade Account"),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
