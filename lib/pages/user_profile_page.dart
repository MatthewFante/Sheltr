import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/models/user_profile.dart';
import 'package:untitled/authentication/fire_auth.dart';
import 'package:untitled/widgets/menu_scaffold.dart';
import 'package:untitled/pages/login_page.dart';

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Verification: ',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          _currentUser.emailVerified
                              ? Text(
                                  'Email verified',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.green),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    await _currentUser.sendEmailVerification();
                                  },
                                  child: const Text('Verify email'),
                                ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              User? user =
                                  await FireAuth.refreshUser(_currentUser);
                              if (user != null) {
                                setState(() {
                                  _currentUser = user;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 200),
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
                ),
    );
  }
}
