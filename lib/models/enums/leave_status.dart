enum LeaveStatus { pending, approved }

extension LeaveStatusExtension on LeaveStatus {
  String toJson() {
    return toString().split('.').last;
  }

  static LeaveStatus fromJson(String value) {
    return LeaveStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => LeaveStatus.pending, // default value
    );
  }

  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
    }
  }

  bool get isPending => this == LeaveStatus.pending;
  bool get isApproved => this == LeaveStatus.approved;
}