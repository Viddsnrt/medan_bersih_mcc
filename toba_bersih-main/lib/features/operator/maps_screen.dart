import 'package:flutter/material.dart';

class MapsScreen extends StatelessWidget {

  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Maps"),
        backgroundColor: Colors.orange,
      ),

      body: const Center(

        child: Icon(
          Icons.map,
          size: 120,
          color: Colors.orange,
        ),

      ),

    );

  }

}