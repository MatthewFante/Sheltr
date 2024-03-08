import 'package:flutter/material.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 3, // Adjust to show desired number of columns
        children: List.generate(
            15, (index) => Placeholder()), // Adjust number of tiles
      ),
      floatingActionButton: Visibility(
        visible: false, // Set to false to hide the button
        child: FloatingActionButton.extended(
          label: const Text('Pet', style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xff990000),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const Placeholder();
              },
            );
          },
        ),
      ),
    );
  }
}
