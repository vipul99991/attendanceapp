import 'dart:async';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:attendanceapp/models/attendence.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';

/// Singleton service for managing Hive database operations
class DBService {
  static DBService? _instance;

  /// Singleton instance accessor
  static DBService get instance {
    _instance ??= DBService._internal();
    return _instance!;
  }

  /// Private constructor for singleton pattern
  DBService._internal();

  /// Hive box names
  static const String attendanceBoxName = 'attendance_box';
  static const String settingsBoxName = 'settings_box';

  /// Hive boxes
  Box<Map>? _attendanceBox;
  Box? _settingsBox;

  /// Stream controllers for reactive state management
  StreamController<List<Attendance>>? _attendanceStreamController;
  StreamController<Map<String, dynamic>>? _settingsStreamController;

  /// Logger for error logging
  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    print('DBService Error: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
  }

  /// Initialize Hive database and register type adapters
  Future<void> initializeHive({String? path}) async {
    try {
      // Initialize Hive with custom path if provided, otherwise use default
      if (path != null) {
        Hive.init(path);
      } else {
        await Hive.initFlutter();
      }

      // Open boxes
      await _openBoxes();

      // Initialize stream controllers
      _attendanceStreamController =
          StreamController<List<Attendance>>.broadcast();
      _settingsStreamController =
          StreamController<Map<String, dynamic>>.broadcast();

      // Load initial data to stream
      _broadcastAttendanceList();
      _broadcastSettings();

      print('Hive database initialized successfully');
    } catch (e, stackTrace) {
      _logError('Failed to initialize Hive database', e, stackTrace);
      rethrow;
    }
  }

 /// Open Hive boxes
  Future<void> _openBoxes() async {
    try {
      _attendanceBox = await Hive.openBox<Map>(attendanceBoxName);
      _settingsBox = await Hive.openBox<Map>(settingsBoxName);
      print('Hive boxes opened successfully');
    } catch (e, stackTrace) {
      _logError('Failed to open Hive boxes', e, stackTrace);
      rethrow;
    }
  }

  /// Get attendance box
  Box<Map> get attendanceBox {
    if (_attendanceBox == null || _attendanceBox!.isOpen == false) {
      throw StateError('Attendance box is not initialized or closed');
    }
    return _attendanceBox!;
  }

  /// Get settings box
  Box get settingsBox {
    if (_settingsBox == null || _settingsBox!.isOpen == false) {
      throw StateError('Settings box is not initialized or closed');
    }
    return _settingsBox!;
  }

  /// Validate attendance object before storing
  bool _validateAttendance(Attendance attendance) {
    if (attendance.id.isEmpty) {
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
        datetime: DateTime.parse(map['datetime'] as String? ?? DateTime.now().toIso8601String()),
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

  /// Create a new attendance record
  Future<bool> createAttendance(Attendance attendance) async {
    try {
      // Validate the attendance object
      if (!_validateAttendance(attendance)) {
        return false;
      }

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
      String newId = attendance.id.isEmpty ? const Uuid().v4() : attendance.id;

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
      throw StateError('DBService not initialized');
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

  /// Get settings value by key
  dynamic getSetting(String key, {dynamic defaultValue}) {
    try {
      final settings = settingsBox.get(key, defaultValue: defaultValue);
      return settings;
    } catch (e, stackTrace) {
      _logError('Failed to get setting with key $key', e, stackTrace);
      return defaultValue;
    }
  }

  /// Set setting value by key
  Future<bool> setSetting(String key, dynamic value) async {
    try {
      await settingsBox.put(key, value);

      // Broadcast updated settings
      _broadcastSettings();

      print('Setting $key updated successfully');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to set setting with key $key', e, stackTrace);
      return false;
    }
  }

  /// Stream of settings
  Stream<Map<String, dynamic>> get settingsStream {
    if (_settingsStreamController == null) {
      throw StateError('DBService not initialized');
    }
    return _settingsStreamController!.stream;
  }

  /// Broadcast updated settings to stream
  void _broadcastSettings() {
    if (_settingsStreamController != null &&
        !_settingsStreamController!.isClosed) {
      final settings = <String, dynamic>{};
      for (final key in settingsBox.keys) {
        settings[key] = settingsBox.get(key);
      }
      _settingsStreamController!.add(settings);
    }
  }

  /// Clear all attendance records
  Future<bool> clearAttendance() async {
    try {
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

  /// Get attendance records by type
 List<Attendance> getAttendanceByType(AttendanceType type) {
    try {
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

  /// Close all Hive boxes
  Future<void> closeBoxes() async {
    try {
      if (_attendanceBox != null && _attendanceBox!.isOpen) {
        await _attendanceBox!.close();
      }
      if (_settingsBox != null && _settingsBox!.isOpen) {
        await _settingsBox!.close();
      }
      print('Hive boxes closed successfully');
    } catch (e, stackTrace) {
      _logError('Failed to close Hive boxes', e, stackTrace);
    }
  }

  /// Close all resources and dispose of the service
  Future<void> dispose() async {
    try {
      // Close all boxes
      await closeBoxes();

      // Close stream controllers
      if (_attendanceStreamController != null &&
          !_attendanceStreamController!.isClosed) {
        await _attendanceStreamController!.close();
      }
      if (_settingsStreamController != null &&
          !_settingsStreamController!.isClosed) {
        await _settingsStreamController!.close();
      }

      print('DBService disposed successfully');
    } catch (e, stackTrace) {
      _logError('Failed to dispose DBService', e, stackTrace);
    }
  }

  /// Check if database is initialized
  bool get isInitialized =>
      _attendanceBox != null &&
      _attendanceBox!.isOpen &&
      _settingsBox != null &&
      _settingsBox!.isOpen;

  /// Perform database migration if needed
  Future<void> performMigration() async {
    try {
      // Migration logic would go here
      // For example, checking the current schema version and applying updates
      final currentVersion = getSetting('db_version', defaultValue: 1);

      if (currentVersion < 2) {
        // Perform migration from version 1 to 2
        // This is just an example - adjust according to your needs
        await setSetting('db_version', 2);
        print('Database migrated to version 2');
      }

      // Add more migration steps as needed
    } catch (e, stackTrace) {
      _logError('Failed to perform database migration', e, stackTrace);
    }
  }

  /// Backup database to a file - This is a placeholder implementation
  /// since Hive doesn't have a built-in backup mechanism
  Future<bool> backupDatabase(String backupPath) async {
    try {
      // Hive doesn't have built-in backup functionality, so we'd need to
      // implement custom logic for copying the Hive files
      // This would typically involve copying the Hive directory
      print(
        'Backup functionality needs to be implemented based on your specific needs',
      );
      return false; // Placeholder implementation
    } catch (e, stackTrace) {
      _logError('Failed to backup database', e, stackTrace);
      return false;
    }
  }
}
