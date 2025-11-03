import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  /// Creates an instance of [AttendanceApp].
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttendanceApp',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      // Router configuration
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AttendanceApp Home')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text('Take Attendance'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('View Attendance'),
          ),
        ],
      ),
    );
  }
}
