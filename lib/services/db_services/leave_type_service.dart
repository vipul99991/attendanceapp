import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:attendanceapp/models/models.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';
import 'database_initializer.dart';

class LeaveTypeService {
  static LeaveTypeService? _instance;
  static final _lock = Object();

  static LeaveTypeService get instance {
    _instance ??= LeaveTypeService._internal();
    return _instance!;
  }

  LeaveTypeService._internal();
  StreamController<List<LeaveType>>? _leaveTypeStreamController;

  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    print('LeaveTypeService Error: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('stack trace: $stackTrace');
  }

  void initialize() {
    _leaveTypeStreamController = StreamController<List<LeaveType>>.broadcast();

    _broadcastLeaveTypeList();
  }

  Map<String, dynamic> _leaveTypeToMap(LeaveType leaveType) {
    return leaveType.toJson();
  }

  LeaveType? _mapToLeaveType(Map<dynamic, dynamic>? map) {
    if (map == null) return null;

    try {
      return LeaveType.fromJson(Map<String, dynamic>.from(map));
    } catch (e, stackTrace) {
      _logError('Failed to convert map to LeaveType object', e, stackTrace);
      return null;
    }
  }


  bool _validateLeaveType(LeaveType leaveType) {
    if (leaveType.id == null) {
      _logError('LeaveType ID cannot be null');
      return false;
    }

    if (leaveType.id?.isEmpty ?? true) {
      _logError('LeaveType ID cannot be empty');
      return false;
    }

    if (leaveType.name.isEmpty) {
      _logError('LeaveType name cannot be empty');
      return false;
    }

    return true;
  }

  /// Create a new leaveType record
  Future<bool> createLeaveType(LeaveType leaveType) async {
    try {
      // Validate the leaveType object
      if (!_validateLeaveType(leaveType)) {
        return false;
      }

      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;

      // Check if leaveType with same ID already exists
      if (leaveTypeBox.containsKey(leaveType.id)) {
        _logError('LeaveType with ID ${leaveType.id} already exists');
        return false;
      }

      // Convert to map and add to box
      final leaveTypeMap = _leaveTypeToMap(leaveType);
      await leaveTypeBox.put(leaveType.id, leaveTypeMap);

      // Broadcast updated list
      _broadcastLeaveTypeList();

      print('LeaveType created successfully: ${leaveType.id}');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to create leaveType', e, stackTrace);
      return false;
    }
  }

  /// Read leaveType by ID
  LeaveType? readLeaveType(String id) {
    try {
      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;

      if (!leaveTypeBox.containsKey(id)) {
        _logError('LeaveType with ID $id not found');
        return null;
      }

      final leaveTypeMap = leaveTypeBox.get(id);
      return _mapToLeaveType(leaveTypeMap);
    } catch (e, stackTrace) {
      _logError('Failed to read leaveType with ID $id', e, stackTrace);
      return null;
    }
  }

  /// Get all leaveType records
  List<LeaveType> getAllLeaveType() {
    try {
      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;
      final leaveTypeList = <LeaveType>[];
      for (final key in leaveTypeBox.keys) {
        final leaveTypeMap = leaveTypeBox.get(key);
        final leaveType = _mapToLeaveType(leaveTypeMap);
        if (leaveType != null) {
          leaveTypeList.add(leaveType);
        }
      }

      // Sort by datetime (newest first)
     return leaveTypeList;
    } catch (e, stackTrace) {
      _logError('Failed to get all leaveType records', e, stackTrace);
      return [];
    }
  }

  /// Update leaveType record
  Future<bool> updateLeaveType(String id, LeaveType updatedLeaveType) async {
    try {
      // Validate the updated leaveType object
      if (!_validateLeaveType(updatedLeaveType)) {
        return false;
      }

      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;

      // Check if leaveType exists
      if (!leaveTypeBox.containsKey(id)) {
        _logError('LeaveType with ID $id does not exist');
        return false;
      }

      // Verify the ID matches
      if (updatedLeaveType.id != id) {
        _logError('ID in updated leaveType does not match the provided ID');
        return false;
      }

      // Convert to map and update the record
      final leaveTypeMap = _leaveTypeToMap(updatedLeaveType);
      await leaveTypeBox.put(id, leaveTypeMap);

      // Broadcast updated list
      _broadcastLeaveTypeList();

      print('LeaveType updated successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to update leaveType with ID $id', e, stackTrace);
      return false;
    }
  }

  /// Delete leaveType record
  Future<bool> deleteLeaveType(String id) async {
    try {
      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;

      // Check if leaveType exists
      if (!leaveTypeBox.containsKey(id)) {
        _logError('LeaveType with ID $id does not exist');
        return false;
      }

      // Delete the record
      await leaveTypeBox.delete(id);

      // Broadcast updated list
      _broadcastLeaveTypeList();

      print('LeaveType deleted successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to delete leaveType with ID $id', e, stackTrace);
      return false;
    }
  }

  /// Create a new leaveType record with auto-generated ID
  Future<String?> createLeaveTypeWithAutoId(LeaveType leaveType) async {
    try {
      // Generate a new ID if not provided
      String newId = leaveType.id?.isEmpty ?? true
          ? const Uuid().v4()
          : leaveType.id!;

      // Create a new leaveType object with the new ID
      final newLeaveType = LeaveType(
        id: newId,
        appliedOn: leaveType.appliedOn,
        type: leaveType.type,
      );

      // Validate the leaveType object
      if (!_validateLeaveType(newLeaveType)) {
        return null;
      }

      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;

      // Convert to map and add to box
      final leaveTypeMap = _leaveTypeToMap(newLeaveType);
      await leaveTypeBox.put(newLeaveType.id, leaveTypeMap);

      // Broadcast updated list
      _broadcastLeaveTypeList();

      print('LeaveType created with auto-generated ID: $newId');
      return newId;
    } catch (e, stackTrace) {
      _logError(
        'Failed to create leaveType with auto-generated ID',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Stream of all leaveType records
  Stream<List<LeaveType>> get leaveTypeStream {
    if (_leaveTypeStreamController == null) {
      throw StateError('LeaveTypeService not initialized');
    }
    return _leaveTypeStreamController!.stream;
  }

  /// Broadcast updated leaveType list to stream
  void _broadcastLeaveTypeList() {
    if (_leaveTypeStreamController != null &&
        !_leaveTypeStreamController!.isClosed) {
      _leaveTypeStreamController!.add(getAllLeaveType());
    }
  }

  /// Get leaveType records by type
  List<LeaveType> getLeaveTypeByType(LeaveTypeType type) {
    try {
      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;
      final leaveTypeList = <LeaveType>[];
      for (final key in leaveTypeBox.keys) {
        final leaveTypeMap = leaveTypeBox.get(key);
        final leaveType = _mapToLeaveType(leaveTypeMap);
        if (leaveType != null && leaveType.type == type) {
          leaveTypeList.add(leaveType);
        }
      }

      // Sort by appliedOn (newest first)
      leaveTypeList.sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
      return leaveTypeList;
    } catch (e, stackTrace) {
      _logError('Failed to get leaveType records by type', e, stackTrace);
      return [];
    }
  }

  /// Get leaveType records within a date range
  List<LeaveType> getLeaveTypeByDateRange(DateTime start, DateTime end) {
    try {
      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;
      final leaveTypeList = <LeaveType>[];
      for (final key in leaveTypeBox.keys) {
        final leaveTypeMap = leaveTypeBox.get(key);
        final leaveType = _mapToLeaveType(leaveTypeMap);
        if (leaveType != null &&
            leaveType.appliedOn.isAfter(start) &&
            leaveType.appliedOn.isBefore(end)) {
          leaveTypeList.add(leaveType);
        }
      }

      // Sort by appliedOn (newest first)
      leaveTypeList.sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
      return leaveTypeList;
    } catch (e, stackTrace) {
      _logError('Failed to get leaveType records by date range', e, stackTrace);
      return [];
    }
  }

  /// Clear all leaveType records
  Future<bool> clearLeaveType() async {
    try {
      final leaveTypeBox = DatabaseInitializer.instance.leaveTypeBox;
      await leaveTypeBox.clear();

      // Broadcast updated list
      _broadcastLeaveTypeList();

      print('All leaveType records cleared successfully');
      return true;
    } catch (e, stackTrace) {
      _logError('Failed to clear leaveType records', e, stackTrace);
      return false;
    }
  }

  /// Close resources and dispose of the service
  Future<void> dispose() async {
    try {
      // Close stream controllers
      if (_leaveTypeStreamController != null &&
          !_leaveTypeStreamController!.isClosed) {
        await _leaveTypeStreamController!.close();
      }

      print('LeaveTypeService disposed successfully');
    } catch (e, stackTrace) {
      _logError('Failed to dispose LeaveTypeService', e, stackTrace);
    }
  }
}
