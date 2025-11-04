import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:attendanceapp/models/models.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';
import 'database_initializer.dart';

class LeaveService {
  static LeaveService? _instance;
  static final _lock = Object();
  static LeaveService get instance {
    _instance ??= LeaveService._internal();
    return _instance!;
  }

  LeaveService._internal();
  StreamController<List<Leave>>? _leaveStreamController;

  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    print('LeaveService Error: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('stack trace: $stackTrace');
  }

  void initialize() {
    _leaveStreamController = StreamController<List<Leave>>.broadcast();

    _broadcastLeaveList();
  }

  Map<String, dynamic> _leaveToMap(Leave leave) {
    return leave.toJson();
  }

  Leave? _mapToLeave(Map<dynamic, dynamic>? map) {
    if (map == null) return null;

    try {
      return Leave.fromJson(map.cast<String, dynamic>());
    } catch (e, stackTrace) {
      _logError('Failed to convert map to Leave object', e, stackTrace);
      return null;
    }
  }

  LeaveType? _stringToLeaveType(String? typeString) {
    return LeaveType.fromJsonString(typeString ?? '');
  }

  bool _validateLeave(Leave leave) {
    if (leave.id == null) {
      _logError('Leave ID cannot be null');
      return false;
    }

    if (leave.id?.isEmpty ?? true) {
      _logError('Leave ID cannot be empty');
      return false;
    }

    if (leave.appliedOn.isAfter(DateTime.now())) {
      _logError('leave appliedOn cannot be in the future');
      return false;
    }

    return true;
  }

  /// Create a new leave record
  Future<bool> createLeave(Leave leave) async {
    try {
      // Validate the leave object
      if (!_validateLeave(leave)) {
        return false;
      }

      final leaveBox = DatabaseInitializer.instance.leaveBox;

      // Check if leave with same ID already exists
      if (leaveBox.containsKey(leave.id)) {
        _logError('Leave with ID ${leave.id} already exists');
        return false;
      }

      // Convert to map and add to box
      final leaveMap = _leaveToMap(leave);
      await leaveBox.put(leave.id, leaveMap);

      // Broadcast updated list
      _broadcastLeaveList();

      print('Leave created successfully: ${leave.id}');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to create leave', e, stackTrace);
      return false;
    }
  }

  /// Read leave by ID
  Leave? readLeave(String id) {
    try {
      final leaveBox = DatabaseInitializer.instance.leaveBox;

      if (!leaveBox.containsKey(id)) {
        _logError('Leave with ID $id not found');
        return null;
      }

      final leaveMap = leaveBox.get(id);
      return _mapToLeave(leaveMap);
    } catch (e, stackTrace) {
      _logError('Failed to read leave with ID $id', e, stackTrace);
      return null;
    }
  }

  /// Get all leave records
  List<Leave> getAllLeave() {
    try {
      final leaveBox = DatabaseInitializer.instance.leaveBox;
      final leaveList = <Leave>[];
      for (final key in leaveBox.keys) {
        final leaveMap = leaveBox.get(key);
        final leave = _mapToLeave(leaveMap);
        if (leave != null) {
          leaveList.add(leave);
        }
      }

      // Sort by datetime (newest first)
      leaveList.sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
      return leaveList;
    } catch (e, stackTrace) {
      _logError('Failed to get all leave records', e, stackTrace);
      return [];
    }
  }

  /// Update leave record
  Future<bool> updateLeave(String id, Leave updatedLeave) async {
    try {
      // Validate the updated leave object
      if (!_validateLeave(updatedLeave)) {
        return false;
      }

      final leaveBox = DatabaseInitializer.instance.leaveBox;

      // Check if leave exists
      if (!leaveBox.containsKey(id)) {
        _logError('Leave with ID $id does not exist');
        return false;
      }

      // Verify the ID matches
      if (updatedLeave.id != id) {
        _logError('ID in updated leave does not match the provided ID');
        return false;
      }
      // Convert to map and update the record
      final leaveMap = _leaveToMap(updatedLeave);
      await leaveBox.put(id, leaveMap);
      // Broadcast updated list
      _broadcastLeaveList();
      print('Leave updated successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to update leave with ID $id', e, stackTrace);
      return false;
    }
  }

  /// Delete leave record
  Future<bool> deleteLeave(String id) async {
    try {
      final leaveBox = DatabaseInitializer.instance.leaveBox;
      // Check if leave exists
      if (!leaveBox.containsKey(id)) {
        _logError('Leave with ID $id does not exist');
        return false;
      }
      // Delete the record
      await leaveBox.delete(id);

      // Broadcast updated list
      _broadcastLeaveList();
      print('Leave deleted successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to delete leave with ID $id', e, stackTrace);
      return false;
    }
  }

  /// Create a new leave record with auto-generated ID
  Future<String?> createLeaveWithAutoId(Leave leave) async {
    try {
      // Generate a new ID if not provided
      String newId = leave.id?.isEmpty ?? true ? const Uuid().v4() : leave.id!;

      // Create a new leave object with the new ID
      final newLeave = leave.copyWith(id: newId);

      // Validate the leave object
      if (!_validateLeave(newLeave)) {
        return null;
      }
      final leaveBox = DatabaseInitializer.instance.leaveBox;
      // Convert to map and add to box
      final leaveMap = _leaveToMap(newLeave);
      await leaveBox.put(newLeave.id, leaveMap);
      // Broadcast updated list
      _broadcastLeaveList();
      print('Leave created with auto-generated ID: $newId');
      return newId;
    } catch (e, stackTrace) {
      _logError('Failed to create leave with auto-generated ID', e, stackTrace);
      return null;
    }
  }

  /// Stream of all leave records
  Stream<List<Leave>> get stream => _leaveStreamController!.stream;

  /// Broadcast updated leave list to stream
  void _broadcastLeaveList() {
    if (_leaveStreamController != null && !_leaveStreamController!.isClosed) {
      _leaveStreamController!.add(getAllLeave());
    }
  }

  /// Get leave records by type
  List<Leave> getLeaveByType(LeaveType type) {
    try {
      final leaveBox = DatabaseInitializer.instance.leaveBox;
      final leaveList = <Leave>[];
      for (final key in leaveBox.keys) {
        final leaveMap = leaveBox.get(key);
        final leave = _mapToLeave(leaveMap);
        if (leave != null && leave.type == type) {
          leaveList.add(leave);
        }
      }
      // Sort by appliedOn (newest first)
      leaveList.sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
      return leaveList;
    } catch (e, stackTrace) {
      _logError('Failed to get leave records by type', e, stackTrace);
      return [];
    }
  }

  /// Get leave records within a date range
  List<Leave> getLeaveByDateRange(DateTime start, DateTime end) {
    try {
      final leaveBox = DatabaseInitializer.instance.leaveBox;
      final leaveList = <Leave>[];
      for (final key in leaveBox.keys) {
        final leaveMap = leaveBox.get(key);
        final leave = _mapToLeave(leaveMap);
        if (leave != null &&
            leave.appliedOn.isAfter(start) &&
            leave.appliedOn.isBefore(end)) {
          leaveList.add(leave);
        }
      }
      // Sort by appliedOn (newest first)
      leaveList.sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
      return leaveList;
    } catch (e, stackTrace) {
      _logError('Failed to get leave records by date range', e, stackTrace);
      return [];
    }
  }

  /// Clear all leave records
  Future<bool> clearLeave() async {
    try {
      final leaveBox = DatabaseInitializer.instance.leaveBox;
      await leaveBox.clear();

      // Broadcast updated list
      _broadcastLeaveList();
      print('All leave records cleared successfully');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to clear leave records', e, stackTrace);
      return false;
    }
  }

  /// Close resources and dispose of the service
  Future<void> dispose() async {
    try {
      // Close stream controllers
      if (_leaveStreamController != null && !_leaveStreamController!.isClosed) {
        await _leaveStreamController!.close();
      }

      print('LeaveService disposed successfully');
    } catch (e, stackTrace) {
      _logError('Failed to dispose LeaveService', e, stackTrace);
    }
  }
}
