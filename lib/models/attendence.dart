enum AttendanceType { checkIn, checkOut, leave, workFromHome }

class Attendance {
  final String id;
  final DateTime datetime;
 final AttendanceType type;

  Attendance({required this.id, required this.datetime, required this.type});
}
