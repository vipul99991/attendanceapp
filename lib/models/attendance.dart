import 'dart:convert';
import 'enums/attendance_type.dart';
import 'enums/mark_type.dart';
import 'enums/upload_status.dart';

class Attendance {
  final String? id;
  final DateTime datetime;
  final AttendanceType type;
  final double? lat;
  final double? lng;
  final String? deviceid;
  final MarkType? marktype;
  final UploadStatus? status;
  final DateTime? uploadeddatetime;

  Attendance({
    this.id,
    required this.datetime,
    required this.type,
    this.lat,
    this.lng,
    this.deviceid,
    this.marktype,
    this.status,
    this.uploadeddatetime,
  });

  // Validation methods
  bool get hasValidLocation => lat != null && lng != null && _isValidCoordinate(lat!) && _isValidCoordinate(lng!);
  
  bool get isCheckIn => type == AttendanceType.checkIn;
  bool get isCheckOut => type == AttendanceType.checkOut;
  bool get isLeave => type == AttendanceType.leave;
  bool get isWorkFromHome => type == AttendanceType.workFromHome;

  bool get isUploaded => status == UploadStatus.Uploaded;
  bool get isPendingUpload => status == UploadStatus.Pending;

  // Utility methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datetime': datetime.toIso8601String(),
      'type': type.toJson(),
      'lat': lat,
      'lng': lng,
      'deviceid': deviceid,
      'marktype': marktype?.toJson(),
      'status': status?.toJson(),
      'uploadeddatetime': uploadeddatetime?.toIso8601String(),
    };
  }

  static Attendance fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      datetime: DateTime.parse(json['datetime']),
      type: AttendanceTypeExtension.fromJson(json['type']),
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      deviceid: json['deviceid'],
      marktype: json['marktype'] != null ? MarkTypeExtension.fromJson(json['marktype']) : null,
      status: json['status'] != null ? UploadStatusExtension.fromJson(json['status']) : null,
      uploadeddatetime: json['uploadeddatetime'] != null ? DateTime.parse(json['uploadeddatetime']) : null,
    );
  }

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static Attendance fromJsonString(String jsonString) => fromJson(jsonDecode(jsonString));

  // Copy with method for immutability
  Attendance copyWith({
    String? id,
    DateTime? datetime,
    AttendanceType? type,
    double? lat,
    double? lng,
    String? deviceid,
    MarkType? marktype,
    UploadStatus? status,
    DateTime? uploadeddatetime,
  }) {
    return Attendance(
      id: id ?? this.id,
      datetime: datetime ?? this.datetime,
      type: type ?? this.type,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      deviceid: deviceid ?? this.deviceid,
      marktype: marktype ?? this.marktype,
      status: status ?? this.status,
      uploadeddatetime: uploadeddatetime ?? this.uploadeddatetime,
    );
  }

  @override
  String toString() {
    return 'Attendance(id: $id, datetime: $datetime, type: $type, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendance &&
        other.id == id &&
        other.datetime == datetime &&
        other.type == type &&
        other.lat == lat &&
        other.lng == lng &&
        other.deviceid == deviceid &&
        other.marktype == marktype &&
        other.status == status &&
        other.uploadeddatetime == uploadeddatetime;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      datetime,
      type,
      lat,
      lng,
      deviceid,
      marktype,
      status,
      uploadeddatetime,
    );
  }

  // Private helper method to validate coordinates
  bool _isValidCoordinate(double coordinate) {
    return coordinate >= -90.0 && coordinate <= 90.0; // For latitude
    // For longitude, it would be: coordinate >= -180.0 && coordinate <= 180.0
  }
}