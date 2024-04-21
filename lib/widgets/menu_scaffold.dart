import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/pages/appointments_page.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:untitled/pages/pets_feed_page.dart';
import 'package:untitled/pages/approvals_page.dart';
import 'package:untitled/pages/requests_page.dart';
import 'package:untitled/pages/user_profile_page.dart'; // Adjust import if needed
import 'package:untitled/models/user_profile.dart';

class MenuScaffold extends StatefulWidget {
  const MenuScaffold({super.key});

  @override
  State<MenuScaffold> createState() => _MenuScaffoldState();
}

class _MenuScaffoldState extends State<MenuScaffold> {
  int _currentIndex = 0;

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<UserProfile?> getUserProfile(User? user) async {
    if (user == null) {
      return null; // No user is signed in
    }

    final userProfileDoc = await FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(user.uid)
        .get();

    if (userProfileDoc.exists) {
      return UserProfile.fromDocumentSnapshot(userProfileDoc);
    } else {
      return null; // No profile found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff990000),
        title: const Text(
          'Sheltr 🐾',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<User?>(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          final pages = <Widget>[
            const PetsFeedPage(),
          ];

          if (user != null) {
            return FutureBuilder<UserProfile?>(
              future: getUserProfile(user),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userProfile = profileSnapshot.data;
                final userRole = userProfile?.userType;

                if (userRole == 'user') {
                  pages.add(const AppointmentsPage());
                } else if (userRole == 'shelter') {
                  pages.add(RequestsPage());
                } else if (userRole == 'admin') {
                  pages.add(ApprovalsPage());
                }

                return buildContent(pages);
              },
            );
          }

          return buildContent(pages); // For non-logged-in users
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
      drawer: buildDrawer(),
    );
  }

  Widget buildContent(List<Widget> pages) {
    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  Widget buildBottomNavigationBar() {
    final bottomNavItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.pets),
        label: 'Pets',
      ),
    ];

    if (FirebaseAuth.instance.currentUser == null) {
      bottomNavItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.login),
          label: 'Login',
        ),
      );
    } else {
      bottomNavItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.question_answer),
          label: 'Requests',
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (int index) {
        if (index == 1 && FirebaseAuth.instance.currentUser == null) {
          // Navigate to LoginPage if user is not logged in
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      items: bottomNavItems,
    );
  }

  Widget buildDrawer() {
    return FutureBuilder<User?>(
      future: getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final user = userSnapshot.data;

        return Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  'Sheltr 🐾',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.pets),
                title: Text('Pets'),
                onTap: () {
                  setState(() {
                    _currentIndex = 0;
                    Navigator.pop(context); // Close the drawer
                  });
                },
              ),
              if (user == null) ...[
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
              if (user != null) ...[
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(user.displayName ?? 'User Profile'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                          user: user,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MenuScaffold(),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
