import 'dart:async';
import 'package:flutter/material.dart';
import 'package:attendanceapp/models/attendence_model.dart';
import 'package:attendanceapp/services/db_services/database_initializer.dart';
import 'package:attendanceapp/services/db_services/attendance_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database service
  await DatabaseInitializer.instance.initializeHive();
  // Initialize the attendance service
  AttendanceService.instance.initialize();

  runApp(const AttendanceAppWrapper());
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

// If you need to handle app lifecycle events for database disposal,
// you can create a wrapper widget like this:
class AttendanceAppWrapper extends StatefulWidget {
  const AttendanceAppWrapper({super.key});

  @override
  State<AttendanceAppWrapper> createState() => _AttendanceAppWrapperState();
}

class _AttendanceAppWrapperState extends State<AttendanceAppWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize DB service here if needed
  }

  @override
  void dispose() {
    // Properly dispose of the database services when the app closes
    DatabaseInitializer.instance.dispose();
    AttendanceService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AttendanceApp();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Attendance> _attendanceList = [];
  StreamSubscription? _attendanceSubscription;

  @override
  void initState() {
    super.initState();
    // Subscribe to attendance stream for real-time updates
    _attendanceSubscription = AttendanceService.instance.attendanceStream
        .listen((attendanceList) {
          setState(() {
            _attendanceList = attendanceList;
          });
        });
  }

  @override
  void dispose() {
    _attendanceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _takeAttendance(AttendanceType type) async {
    final attendance = Attendance(
      id: '', // Will be auto-generated
      datetime: DateTime.now(),
      type: type,
    );

    final id = await AttendanceService.instance.createAttendanceWithAutoId(
      attendance,
    );
    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type.name} recorded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to record ${type.name}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AttendanceApp Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Check-in/Check-out buttons
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Attendance Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _takeAttendance(AttendanceType.checkIn),
                            icon: const Icon(Icons.login),
                            label: const Text('Check In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _takeAttendance(AttendanceType.checkOut),
                            icon: const Icon(Icons.logout),
                            label: const Text('Check Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _takeAttendance(AttendanceType.leave),
                            icon: const Icon(Icons.beach_access),
                            label: const Text('Leave'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _takeAttendance(AttendanceType.workFromHome),
                            icon: const Icon(Icons.home),
                            label: const Text('WFH'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Recent attendance records
            const Text(
              'Recent Attendance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _attendanceList.isEmpty
                  ? const Center(
                      child: Text(
                        'No attendance records yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _attendanceList.length,
                      itemBuilder: (context, index) {
                        final attendance = _attendanceList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: _getTypeIcon(attendance.type),
                            title: Text(_getTypeString(attendance.type)),
                            subtitle: Text(
                              '${attendance.datetime.toLocal()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '#${attendance.id?.substring(0, 8)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getTypeIcon(AttendanceType type) {
    switch (type) {
      case AttendanceType.checkIn:
        return const Icon(Icons.login, color: Colors.green);
      case AttendanceType.checkOut:
        return const Icon(Icons.logout, color: Colors.blue);
      case AttendanceType.leave:
        return const Icon(Icons.beach_access, color: Colors.orange);
      case AttendanceType.workFromHome:
        return const Icon(Icons.home, color: Colors.purple);
    }
  }

  String _getTypeString(AttendanceType type) {
    switch (type) {
      case AttendanceType.checkIn:
        return 'Check In';
      case AttendanceType.checkOut:
        return 'Check Out';
      case AttendanceType.leave:
        return 'Leave';
      case AttendanceType.workFromHome:
        return 'Work From Home';
    }
  }
}
