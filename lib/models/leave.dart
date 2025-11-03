import 'dart:convert';
import 'enums/leave_status.dart';
import 'enums/upload_status.dart';
import 'leave_type.dart';

class Leave {
  final String? id;
  final LeaveType type;
  final String? remark;
  final String? approvedby;
  final DateTime? approvedon;
  final LeaveStatus? leavestatus;
  final DateTime appliedOn;
  final UploadStatus? status;
  final DateTime? uploadeddatetime;
  final String? deviceid;

  Leave({
    this.id,
    required this.type,
    this.remark,
    this.approvedby,
    this.approvedon,
    this.leavestatus,
    required this.appliedOn,
    this.status,
    this.uploadeddatetime,
    this.deviceid,
  });

  // Validation methods
  bool get isValid => type.isValid && appliedOn.isBefore(DateTime.now());

  bool get isPending => leavestatus == LeaveStatus.pending;
  bool get isApproved => leavestatus == LeaveStatus.approved;

  bool get isUploaded => status == UploadStatus.Uploaded;
  bool get isPendingUpload => status == UploadStatus.Pending;

  // Utility methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'remark': remark,
      'approvedby': approvedby,
      'approvedon': approvedon?.toIso8601String(),
      'leavestatus': leavestatus?.toJson(),
      'appliedOn': appliedOn.toIso8601String(),
      'status': status?.toJson(),
      'uploadeddatetime': uploadeddatetime?.toIso8601String(),
      'deviceid': deviceid,
    };
  }

  static Leave fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      type: LeaveType.fromJson(json['type']),
      remark: json['remark'],
      approvedby: json['approvedby'],
      approvedon: json['approvedon'] != null ? DateTime.parse(json['approvedon']) : null,
      leavestatus: json['leavestatus'] != null ? LeaveStatusExtension.fromJson(json['leavestatus']) : null,
      appliedOn: DateTime.parse(json['appliedOn']),
      status: json['status'] != null ? UploadStatusExtension.fromJson(json['status']) : null,
      uploadeddatetime: json['uploadeddatetime'] != null ? DateTime.parse(json['uploadeddatetime']) : null,
      deviceid: json['deviceid'],
    );
  }

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static Leave fromJsonString(String jsonString) => fromJson(jsonDecode(jsonString));

  // Copy with method for immutability
  Leave copyWith({
    String? id,
    LeaveType? type,
    String? remark,
    String? approvedby,
    DateTime? approvedon,
    LeaveStatus? leavestatus,
    DateTime? appliedOn,
    UploadStatus? status,
    DateTime? uploadeddatetime,
    String? deviceid,
  }) {
    return Leave(
      id: id ?? this.id,
      type: type ?? this.type,
      remark: remark ?? this.remark,
      approvedby: approvedby ?? this.approvedby,
      approvedon: approvedon ?? this.approvedon,
      leavestatus: leavestatus ?? this.leavestatus,
      appliedOn: appliedOn ?? this.appliedOn,
      status: status ?? this.status,
      uploadeddatetime: uploadeddatetime ?? this.uploadeddatetime,
      deviceid: deviceid ?? this.deviceid,
    );
  }

  @override
  String toString() {
    return 'Leave(id: $id, type: ${type.name}, leavestatus: $leavestatus, appliedOn: $appliedOn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Leave &&
        other.id == id &&
        other.type == type &&
        other.remark == remark &&
        other.approvedby == approvedby &&
        other.approvedon == approvedon &&
        other.leavestatus == leavestatus &&
        other.appliedOn == appliedOn &&
        other.status == status &&
        other.uploadeddatetime == uploadeddatetime &&
        other.deviceid == deviceid;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      remark,
      approvedby,
      approvedon,
      leavestatus,
      appliedOn,
      status,
      uploadeddatetime,
      deviceid,
    );
  }
}