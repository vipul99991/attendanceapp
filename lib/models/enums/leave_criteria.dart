enum Leavecriteria {
  weekly,
  fortnightly,
  monthly,
  quarterly,
  halfyearly,
  yearly,
}

extension LeaveCriteriaExtension on Leavecriteria {
  String toJson() {
    return toString().split('.').last;
  }

  static Leavecriteria fromJson(String value) {
    return Leavecriteria.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => Leavecriteria.monthly, // default value
    );
  }

  String get displayName {
    switch (this) {
      case Leavecriteria.weekly:
        return 'Weekly';
      case Leavecriteria.fortnightly:
        return 'Fortnightly';
      case Leavecriteria.monthly:
        return 'Monthly';
      case Leavecriteria.quarterly:
        return 'Quarterly';
      case Leavecriteria.halfyearly:
        return 'Half Yearly';
      case Leavecriteria.yearly:
        return 'Yearly';
    }
  }

  int get daysInPeriod {
    switch (this) {
      case Leavecriteria.weekly:
        return 7;
      case Leavecriteria.fortnightly:
        return 14;
      case Leavecriteria.monthly:
        return 30;
      case Leavecriteria.quarterly:
        return 90;
      case Leavecriteria.halfyearly:
        return 180;
      case Leavecriteria.yearly:
        return 365;
    }
  }
}