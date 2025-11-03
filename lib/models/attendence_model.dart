enum AttendanceType { checkIn, checkOut, leave, workFromHome }

enum MarkType { GEOLOCATION, FACE, QR, FINGERPRINT }

enum UploadStatus { Pending, Uploaded }

enum Leavecriteria {
  weekly,
  fortnightly,
  monthly,
  quarterly,
  halfyearly,
  yearly,
}

enum LeaveStatus { pending, approved }

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
    required this.id,
    required this.datetime,
    required this.type,
    this.lat,
    this.lng,
    this.deviceid,
    this.marktype,
    this.status,
    this.uploadeddatetime,
  });
}

class LeaveType {
  final String? id;
  final String name;
  final int maximumdays;
  final Leavecriteria leavecriteria;
  LeaveType({
    this.id,
    required this.name,
    required this.maximumdays,
    required this.leavecriteria,
  });
}

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
}
