import 'package:flutter/material.dart';
import 'package:toba_bersih/auth/login_screen.dart';

class SettingScreen extends StatelessWidget {

  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Setting"),
        backgroundColor: Colors.orange,
      ),

      body: ListView(

        children: [

          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Profil"),
          ),

          const ListTile(
            leading: Icon(Icons.help),
            title: Text("Bantuan"),
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),

            onTap: () {

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LoginScreen(),
                ),
              );

            },

          ),

        ],

      ),

    );

  }

}