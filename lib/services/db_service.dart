import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:attendanceapp/models/attendence_model.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';
import 'db_services/database_initializer.dart';
import 'db_services/attendance_service.dart';

/// Singleton service for managing Hive database operations
/// This is a facade that delegates to specialized services for backward compatibility
class DBService {
  static DBService? _instance;
  static final _lock = Object();

 /// Singleton instance accessor
  static DBService get instance {
    _instance ??= DBService._internal();
    return _instance!;
  }

  /// Private constructor for singleton pattern
  DBService._internal();

  /// Initialize Hive database and register type adapters
  Future<void> initializeHive({String? path}) async {
    await DatabaseInitializer.instance.initializeHive(path: path);
    AttendanceService.instance.initialize();
  }

  /// Logger for error logging
 void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    print('DBService Error: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
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

  /// Create a new attendance record
  Future<bool> createAttendance(Attendance attendance) async {
    return await AttendanceService.instance.createAttendance(attendance);
  }

  /// Read attendance by ID
  Attendance? readAttendance(String id) {
    return AttendanceService.instance.readAttendance(id);
  }

  /// Get all attendance records
  List<Attendance> getAllAttendance() {
    return AttendanceService.instance.getAllAttendance();
  }

  /// Update attendance record
  Future<bool> updateAttendance(String id, Attendance updatedAttendance) async {
    return await AttendanceService.instance.updateAttendance(id, updatedAttendance);
  }

  /// Delete attendance record
  Future<bool> deleteAttendance(String id) async {
    return await AttendanceService.instance.deleteAttendance(id);
  }

  /// Create a new attendance record with auto-generated ID
  Future<String?> createAttendanceWithAutoId(Attendance attendance) async {
    return await AttendanceService.instance.createAttendanceWithAutoId(attendance);
  }

  /// Stream of all attendance records
  Stream<List<Attendance>> get attendanceStream {
    return AttendanceService.instance.attendanceStream;
  }

  /// Get settings value by key
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return DatabaseInitializer.instance.getSetting(key, defaultValue: defaultValue);
  }

  /// Set setting value by key
  Future<bool> setSetting(String key, dynamic value) async {
    return await DatabaseInitializer.instance.setSetting(key, value);
  }

  /// Stream of settings
  Stream<Map<String, dynamic>> get settingsStream {
    return DatabaseInitializer.instance.settingsStream;
  }

  /// Clear all attendance records
  Future<bool> clearAttendance() async {
    return await AttendanceService.instance.clearAttendance();
  }

  /// Get attendance records by type
  List<Attendance> getAttendanceByType(AttendanceType type) {
    return AttendanceService.instance.getAttendanceByType(type);
 }

  /// Get attendance records within a date range
  List<Attendance> getAttendanceByDateRange(DateTime start, DateTime end) {
    return AttendanceService.instance.getAttendanceByDateRange(start, end);
  }

  /// Close all Hive boxes
  Future<void> closeBoxes() async {
    await DatabaseInitializer.instance.closeBoxes();
  }

  /// Close all resources and dispose of the service
  Future<void> dispose() async {
    await DatabaseInitializer.instance.dispose();
    await AttendanceService.instance.dispose();
  }

  /// Check if database is initialized
  bool get isInitialized => DatabaseInitializer.instance.isInitialized;

  /// Perform database migration if needed
  Future<void> performMigration() async {
    await DatabaseInitializer.instance.performMigration();
  }

  /// Backup database to a file - This is a placeholder implementation
  /// since Hive doesn't have a built-in backup mechanism
  Future<bool> backupDatabase(String backupPath) async {
    _logError('Backup functionality is not implemented in the refactored version');
    return false; // Placeholder implementation
  }
}