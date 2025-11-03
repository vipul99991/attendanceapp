import 'dart:convert';
import 'enums/leave_criteria.dart';

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

  // Validation methods
  bool get isValid => name.isNotEmpty && maximumdays > 0;

  // Utility methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'maximumdays': maximumdays,
      'leavecriteria': leavecriteria.toJson(),
    };
  }

  static LeaveType fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'],
      name: json['name'],
      maximumdays: json['maximumdays'],
      leavecriteria: LeaveCriteriaExtension.fromJson(json['leavecriteria']),
    );
  }

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static LeaveType fromJsonString(String jsonString) => fromJson(jsonDecode(jsonString));

  // Copy with method for immutability
  LeaveType copyWith({
    String? id,
    String? name,
    int? maximumdays,
    Leavecriteria? leavecriteria,
  }) {
    return LeaveType(
      id: id ?? this.id,
      name: name ?? this.name,
      maximumdays: maximumdays ?? this.maximumdays,
      leavecriteria: leavecriteria ?? this.leavecriteria,
    );
  }

  @override
  String toString() {
    return 'LeaveType(id: $id, name: $name, maximumdays: $maximumdays, leavecriteria: $leavecriteria)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaveType &&
        other.id == id &&
        other.name == name &&
        other.maximumdays == maximumdays &&
        other.leavecriteria == leavecriteria;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, maximumdays, leavecriteria);
  }
}