import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/pages/appointments_page.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:untitled/pages/user_profile_page.dart';
import 'package:untitled/pages/pets_feed_page.dart';
import 'package:untitled/pages/approvals_page.dart';
import 'package:untitled/pages/requests_page.dart'; // Placeholder for your Requests page
import 'package:untitled/models/user_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Future<String?> getUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return null; // No user is signed in
    }

    try {
      final userProfileDoc = await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(currentUser.uid)
          .get();

      if (userProfileDoc.exists) {
        final userProfile = UserProfile.fromDocumentSnapshot(userProfileDoc);
        return userProfile.userType;
      } else {
        return null; // If no profile is found
      }
    } catch (e) {
      print("Error checking user role: $e");
      return null; // If there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff990000),
              title: const Text('Sheltr',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            body: const Center(
                child: CircularProgressIndicator()), // While loading
          );
        }

        final userRole = snapshot.data;

        // Define the bottom navigation items based on the user role
        final bottomNavItems = <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pets',
          ),
        ];

        final pages = <Widget>[
          const PetsPage(),
        ];

        // Add the second item based on user role
        if (userRole == 'user') {
          bottomNavItems.add(
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Appointments',
            ),
          );
          pages.add(const AppointmentsPage());
        } else if (userRole == 'shelter') {
          bottomNavItems.add(
            const BottomNavigationBarItem(
              icon: Icon(Icons.request_quote),
              label: 'Requests',
            ),
          );
          pages.add(RequestsPage());
        } else if (userRole == 'admin') {
          bottomNavItems.add(
            const BottomNavigationBarItem(
              icon: Icon(Icons.approval),
              label: 'Approvals',
            ),
          );
          pages.add(ApprovalsPage());
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff990000),
            title: const Text('Sheltr',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          body: pages[_currentIndex], // Set the body based on the current index
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index; // Update the current index
              });
            },
            items:
                bottomNavItems, // Use the correct items based on the user role
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                const SizedBox(
                  height: 70,
                  child: DrawerHeader(
                    child: Text(
                      'Sheltr',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.pets),
                  title: const Text('Pets'),
                  onTap: () {
                    setState(() {
                      _currentIndex = 0;
                      Navigator.pop(context); // Close the drawer
                    });
                  },
                ),
                if (userRole == 'user') ...[
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Appointments'),
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                        Navigator.pop(context); // Close the drawer
                      });
                    },
                  ),
                ] else if (userRole == 'shelter') ...[
                  ListTile(
                    leading: const Icon(Icons.request_quote),
                    title: const Text('Requests'),
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                        Navigator.pop(context); // Close the drawer
                      });
                    },
                  ),
                ] else if (userRole == 'admin') ...[
                  ListTile(
                    leading: const Icon(Icons.approval),
                    title: const Text('Approvals'),
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                        Navigator.pop(context); // Close the drawer
                      });
                    },
                  ),
                ],
                const SizedBox(
                  height: 450,
                ),
                TextButton(
                    onPressed: () async {
                      if (getCurrentUser() != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage(user: getCurrentUser()!)),
                        );
                      } else {
                        null;
                      }
                    },
                    child: Text(getCurrentUser()?.displayName ?? 'Unknown')),
                TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Sign out')),
              ],
            ),
          ),
        );
      },
    );
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
