import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

/// Singleton service for initializing Hive database
class DatabaseInitializer {
  static DatabaseInitializer? _instance;
  static final _lock = Object();

  /// Singleton instance accessor
  static DatabaseInitializer get instance {
    _instance ??= DatabaseInitializer._internal();
    return _instance!;
  }

  /// Private constructor for singleton pattern
  DatabaseInitializer._internal();

  /// Hive box names
  static const String attendanceBoxName = 'attendance_box';
  static const String settingsBoxName = 'settings_box';

  /// Hive boxes
  Box<Map>? _attendanceBox;
  Box? _settingsBox;

 /// Stream controllers for reactive state management
  StreamController<Map<String, dynamic>>? _settingsStreamController;

  /// Check if database is initialized
  bool get isInitialized =>
      _attendanceBox != null &&
      _attendanceBox!.isOpen &&
      _settingsBox != null &&
      _settingsBox!.isOpen;

  /// Logger for error logging
  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    print('DatabaseInitializer Error: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
  }

  /// Initialize Hive database
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
      
      // Initialize stream controllers
      _settingsStreamController = StreamController<Map<String, dynamic>>.broadcast();
      
      // Load initial data to stream
      _broadcastSettings();
      
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

  /// Close all resources and dispose of the initializer
  Future<void> dispose() async {
    try {
      // Close all boxes
      await closeBoxes();
      
      // Close stream controllers
      if (_settingsStreamController != null &&
          !_settingsStreamController!.isClosed) {
        await _settingsStreamController!.close();
      }
      
      print('DatabaseInitializer disposed successfully');
    } catch (e, stackTrace) {
      _logError('Failed to dispose DatabaseInitializer', e, stackTrace);
    }
  }

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
      _logError('Failed to setting with key $key', e, stackTrace);
      return false;
    }
  }

  /// Stream of settings
  Stream<Map<String, dynamic>> get settingsStream {
    if (_settingsStreamController == null) {
      throw StateError('DatabaseInitializer not initialized');
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
}