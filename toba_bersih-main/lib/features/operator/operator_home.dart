import 'package:flutter/material.dart';

import 'daily_task_screen.dart';
import 'report_task_screen.dart';
import 'maps_screen.dart';
import 'setting_screen.dart';

class OperatorHomeScreen extends StatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  State<OperatorHomeScreen> createState() =>
      _OperatorHomeScreenState();
}

class _OperatorHomeScreenState
    extends State<OperatorHomeScreen> {

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DailyTaskScreen(),
    const ReportTaskScreen(),
    const MapsScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _currentIndex,

        onTap: (index) {

          setState(() {
            _currentIndex = index;
          });

        },

        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Tugas Harian",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Laporan",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Maps",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Setting",
          ),

        ],

      ),

    );

  }

}