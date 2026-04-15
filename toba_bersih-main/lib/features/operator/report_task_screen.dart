import 'package:flutter/material.dart';

class ReportTaskScreen extends StatelessWidget {

  const ReportTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Laporan Masuk"),
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
                Icons.report_problem,
                color: Colors.red,
              ),

              title: Text(
                "Laporan ${index + 1}",
              ),

              subtitle: const Text(
                "Sampah menumpuk di lokasi...",
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