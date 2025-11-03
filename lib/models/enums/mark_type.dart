enum MarkType { GEOLOCATION, FACE, QR, FINGERPRINT }

extension MarkTypeExtension on MarkType {
  String toJson() {
    return toString().split('.').last;
  }

  static MarkType fromJson(String value) {
    return MarkType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => MarkType.GEOLOCATION, // default value
    );
  }

  String get displayName {
    switch (this) {
      case MarkType.GEOLOCATION:
        return 'Geolocation';
      case MarkType.FACE:
        return 'Face Recognition';
      case MarkType.QR:
        return 'QR Code';
      case MarkType.FINGERPRINT:
        return 'Fingerprint';
    }
  }
}