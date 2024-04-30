import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/upgrade_request.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/widgets/edit_user_profile_modal.dart';
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
          .where('uid', isEqualTo: _currentUser.uid)
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
        uid: _currentUser.uid,
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
        title: const Text('User Profile'),
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
                  child: Icon(
                    Icons.email,
                  ),
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
                    child: Icon(
                      Icons.phone,
                    ),
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
                    padding: EdgeInsets.all(20.0),
                    child: Icon(Icons.account_circle),
                  ),
                  Text(
                    '${_userProfile!.bio}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            if (isShelter) ...[
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Icon(Icons.location_on),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_userProfile?.address != null)
                        Text(
                          '${_userProfile!.address}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      Row(
                        children: [
                          if (_userProfile?.city != null)
                            Text(
                              '${_userProfile!.city}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          if (_userProfile?.city != null &&
                              _userProfile!.state != null)
                            const Text(", "),
                          if (_userProfile?.state != null)
                            Text(
                              '${_userProfile!.state}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          if (_userProfile?.zipCode != null)
                            Text(
                              ' ${_userProfile!.zipCode}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.access_time),
                ),
                if (_userProfile?.hoursOfOperation != null)
                  Text(
                    '${_userProfile!.hoursOfOperation}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ]),
              Row(children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.web),
                ),
                if (_userProfile?.website != null)
                  Text(
                    '${_userProfile!.website}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ])
            ],
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
            const SizedBox(height: 16),
            Center(
              child: _userProfile?.userType == 'user'
                  ? ElevatedButton(
                      onPressed: sendUpgradeRequest,
                      child: const Text("Upgrade Account"),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
