enum AttendanceType { checkIn, checkOut, leave, workFromHome }

extension AttendanceTypeExtension on AttendanceType {
  String toJson() {
    return toString().split('.').last;
  }

  static AttendanceType fromJson(String value) {
    return AttendanceType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => AttendanceType.checkIn, // default value
    );
  }

  String get displayName {
    switch (this) {
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