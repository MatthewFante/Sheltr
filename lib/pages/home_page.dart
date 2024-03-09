import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/appointments_page.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:untitled/pages/profile_page.dart';
import 'package:untitled/pages/pets_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // create a list of the pages that are navigated to when the user clicks on a navigation item
  final List<Widget> _pages = [
    const PetsPage(),
    const AppointmentsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    // get the current user
    User? getCurrentUser() {
      final User? user = FirebaseAuth.instance.currentUser;
      return user;
    }

    // get the name and uid of the current user
    final currentUserName = getCurrentUser()?.displayName ?? 'Unknown';
    final currentUserId = getCurrentUser()?.uid ?? 'Unknown';

    bool adminView = true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff990000),
        title: const Text('Sheltr',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(
              height: 70,
              child: DrawerHeader(
                  child: Text('Sheltr',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ))),
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
                child: Text(currentUserName)),
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
  }
}
