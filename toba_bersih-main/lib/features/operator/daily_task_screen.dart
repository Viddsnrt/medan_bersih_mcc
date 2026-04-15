import 'package:flutter/material.dart';

class DailyTaskScreen extends StatelessWidget {

  const DailyTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Tugas Harian"),
        backgroundColor: Colors.orange,
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: 5,

        itemBuilder: (context, index) {

          return Card(

            margin: const EdgeInsets.only(bottom: 12),

            child: ListTile(

              leading: const Icon(
                Icons.local_shipping,
                color: Colors.orange,
              ),

              title: Text(
                "Tugas Hari ${index + 1}",
              ),

              subtitle: const Text(
                "Pengangkutan sampah wilayah A",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

            ),

          );

        },

      ),

    );

  }

}