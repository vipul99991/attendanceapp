import 'dart:async';
import 'package:attendanceapp/models/models.dart';
import 'package:uuid/uuid.dart';
import 'database_initializer.dart';

/// Service for managing attendance-specific database operations
class AttendanceService {
  static AttendanceService? _instance;
  static final _lock = Object();

  /// Singleton instance accessor
  static AttendanceService get instance {
    _instance ??= AttendanceService._internal();
    return _instance!;
  }

  /// Private constructor for singleton pattern
  AttendanceService._internal();

  /// Stream controllers for reactive state management
  StreamController<List<Attendance>>? _attendanceStreamController;

  /// Logger for error logging
  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    print('AttendanceService Error: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
  }

  /// Initialize attendance service and stream controllers
  void initialize() {
    // Initialize stream controllers
    _attendanceStreamController =
        StreamController<List<Attendance>>.broadcast();

    // Load initial data to stream
    _broadcastAttendanceList();
  }

  /// Convert Attendance object to Map for storage
  Map<String, dynamic> _attendanceToMap(Attendance attendance) {
    return {
      'id': attendance.id,
      'datetime': attendance.datetime.toIso8601String(),
      'type': attendance.type.toString().split('.').last, // Store as string
    };
  }

  /// Convert Map to Attendance object
  Attendance? _mapToAttendance(Map<dynamic, dynamic>? map) {
    if (map == null) return null;

    try {
      final typeString = map['type'] as String?;
      final type = _stringToAttendanceType(typeString);

      if (type == null) {
        _logError('Invalid attendance type: $typeString');
        return null;
      }

      return Attendance(
        id: map['id'] as String? ?? '',
        datetime: DateTime.parse(
          map['datetime'] as String? ?? DateTime.now().toIso8601String(),
        ),
        type: type,
      );
    } catch (e, stackTrace) {
      _logError('Failed to convert map to Attendance object', e, stackTrace);
      return null;
    }
  }

  /// Convert string to AttendanceType
  AttendanceType? _stringToAttendanceType(String? typeString) {
    switch (typeString) {
      case 'checkIn':
        return AttendanceType.checkIn;
      case 'checkOut':
        return AttendanceType.checkOut;
      case 'leave':
        return AttendanceType.leave;
      case 'workFromHome':
        return AttendanceType.workFromHome;
      default:
        return null;
    }
  }

  /// Validate attendance object before storing
  bool _validateAttendance(Attendance attendance) {
    if (attendance.id == null) {
      _logError('Attendance ID cannot be null');
      return false;
    }

    if (attendance.id?.isEmpty ?? true) {
      _logError('Attendance ID cannot be empty');
      return false;
    }

    // Check if datetime is not in the future
    if (attendance.datetime.isAfter(DateTime.now())) {
      _logError('Attendance datetime cannot be in the future');
      return false;
    }

    return true;
  }

  /// Create a new attendance record
  Future<bool> createAttendance(Attendance attendance) async {
    try {
      // Validate the attendance object
      if (!_validateAttendance(attendance)) {
        return false;
      }

      final attendanceBox = DatabaseInitializer.instance.attendanceBox;

      // Check if attendance with same ID already exists
      if (attendanceBox.containsKey(attendance.id)) {
        _logError('Attendance with ID ${attendance.id} already exists');
        return false;
      }

      // Convert to map and add to box
      final attendanceMap = _attendanceToMap(attendance);
      await attendanceBox.put(attendance.id, attendanceMap);

      // Broadcast updated list
      _broadcastAttendanceList();

      print('Attendance created successfully: ${attendance.id}');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to create attendance', e, stackTrace);
      return false;
    }
  }

  /// Read attendance by ID
  Attendance? readAttendance(String id) {
    try {
      final attendanceBox = DatabaseInitializer.instance.attendanceBox;

      if (!attendanceBox.containsKey(id)) {
        _logError('Attendance with ID $id not found');
        return null;
      }

      final attendanceMap = attendanceBox.get(id);
      return _mapToAttendance(attendanceMap);
    } catch (e, stackTrace) {
      _logError('Failed to read attendance with ID $id', e, stackTrace);
      return null;
    }
  }

  /// Get all attendance records
  List<Attendance> getAllAttendance() {
    try {
      final attendanceBox = DatabaseInitializer.instance.attendanceBox;
      final attendanceList = <Attendance>[];
      for (final key in attendanceBox.keys) {
        final attendanceMap = attendanceBox.get(key);
        final attendance = _mapToAttendance(attendanceMap);
        if (attendance != null) {
          attendanceList.add(attendance);
        }
      }

      // Sort by datetime (newest first)
      attendanceList.sort((a, b) => b.datetime.compareTo(a.datetime));
      return attendanceList;
    } catch (e, stackTrace) {
      _logError('Failed to get all attendance records', e, stackTrace);
      return [];
    }
  }

  /// Update attendance record
  Future<bool> updateAttendance(String id, Attendance updatedAttendance) async {
    try {
      // Validate the updated attendance object
      if (!_validateAttendance(updatedAttendance)) {
        return false;
      }

      final attendanceBox = DatabaseInitializer.instance.attendanceBox;

      // Check if attendance exists
      if (!attendanceBox.containsKey(id)) {
        _logError('Attendance with ID $id does not exist');
        return false;
      }

      // Verify the ID matches
      if (updatedAttendance.id != id) {
        _logError('ID in updated attendance does not match the provided ID');
        return false;
      }

      // Convert to map and update the record
      final attendanceMap = _attendanceToMap(updatedAttendance);
      await attendanceBox.put(id, attendanceMap);

      // Broadcast updated list
      _broadcastAttendanceList();

      print('Attendance updated successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to update attendance with ID $id', e, stackTrace);
      return false;
    }
  }

  /// Delete attendance record
  Future<bool> deleteAttendance(String id) async {
    try {
      final attendanceBox = DatabaseInitializer.instance.attendanceBox;

      // Check if attendance exists
      if (!attendanceBox.containsKey(id)) {
        _logError('Attendance with ID $id does not exist');
        return false;
      }

      // Delete the record
      await attendanceBox.delete(id);

      // Broadcast updated list
      _broadcastAttendanceList();

      print('Attendance deleted successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to delete attendance with ID $id', e, stackTrace);
      return false;
    }
  }

  /// Create a new attendance record with auto-generated ID
  Future<String?> createAttendanceWithAutoId(Attendance attendance) async {
    try {
      // Generate a new ID if not provided
      String newId = attendance.id?.isEmpty ?? true
          ? const Uuid().v4()
          : attendance.id!;

      // Create a new attendance object with the new ID
      final newAttendance = Attendance(
        id: newId,
        datetime: attendance.datetime,
        type: attendance.type,
      );

      // Validate the attendance object
      if (!_validateAttendance(newAttendance)) {
        return null;
      }

      final attendanceBox = DatabaseInitializer.instance.attendanceBox;

      // Convert to map and add to box
      final attendanceMap = _attendanceToMap(newAttendance);
      await attendanceBox.put(newAttendance.id, attendanceMap);

      // Broadcast updated list
      _broadcastAttendanceList();

      print('Attendance created with auto-generated ID: $newId');
      return newId;
    } catch (e, stackTrace) {
      _logError(
        'Failed to create attendance with auto-generated ID',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Stream of all attendance records
  Stream<List<Attendance>> get attendanceStream {
    if (_attendanceStreamController == null) {
      throw StateError('AttendanceService not initialized');
    }
    return _attendanceStreamController!.stream;
  }

  /// Broadcast updated attendance list to stream
  void _broadcastAttendanceList() {
    if (_attendanceStreamController != null &&
        !_attendanceStreamController!.isClosed) {
      _attendanceStreamController!.add(getAllAttendance());
    }
  }

  /// Get attendance records by type
  List<Attendance> getAttendanceByType(AttendanceType type) {
    try {
      final attendanceBox = DatabaseInitializer.instance.attendanceBox;
      final attendanceList = <Attendance>[];
      for (final key in attendanceBox.keys) {
        final attendanceMap = attendanceBox.get(key);
        final attendance = _mapToAttendance(attendanceMap);
        if (attendance != null && attendance.type == type) {
          attendanceList.add(attendance);
        }
      }

      // Sort by datetime (newest first)
      attendanceList.sort((a, b) => b.datetime.compareTo(a.datetime));
      return attendanceList;
    } catch (e, stackTrace) {
      _logError('Failed to get attendance records by type', e, stackTrace);
      return [];
    }
  }

  /// Get attendance records within a date range
  List<Attendance> getAttendanceByDateRange(DateTime start, DateTime end) {
    try {
      final attendanceBox = DatabaseInitializer.instance.attendanceBox;
      final attendanceList = <Attendance>[];
      for (final key in attendanceBox.keys) {
        final attendanceMap = attendanceBox.get(key);
        final attendance = _mapToAttendance(attendanceMap);
        if (attendance != null &&
            attendance.datetime.isAfter(start) &&
            attendance.datetime.isBefore(end)) {
          attendanceList.add(attendance);
        }
      }

      // Sort by datetime (newest first)
      attendanceList.sort((a, b) => b.datetime.compareTo(a.datetime));
      return attendanceList;
    } catch (e, stackTrace) {
      _logError(
        'Failed to get attendance records by date range',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Clear all attendance records
  Future<bool> clearAttendance() async {
    try {
      final attendanceBox = DatabaseInitializer.instance.attendanceBox;
      await attendanceBox.clear();

      // Broadcast updated list
      _broadcastAttendanceList();

      print('All attendance records cleared successfully');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to clear attendance records', e, stackTrace);
      return false;
    }
  }

  /// Close resources and dispose of the service
  Future<void> dispose() async {
    try {
      // Close stream controllers
      if (_attendanceStreamController != null &&
          !_attendanceStreamController!.isClosed) {
        await _attendanceStreamController!.close();
      }

      print('AttendanceService disposed successfully');
    } catch (e, stackTrace) {
      _logError('Failed to dispose AttendanceService', e, stackTrace);
    }
  }
}
