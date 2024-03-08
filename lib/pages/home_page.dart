import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Placeholder Grid'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Adjust to show desired number of columns
        children: List.generate(
            8, (index) => Placeholder()), // Adjust number of tiles
      ),
    );
  }
}
