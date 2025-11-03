enum UploadStatus { Pending, Uploaded }

extension UploadStatusExtension on UploadStatus {
  String toJson() {
    return toString().split('.').last;
  }

  static UploadStatus fromJson(String value) {
    return UploadStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => UploadStatus.Pending, // default value
    );
  }

  String get displayName {
    switch (this) {
      case UploadStatus.Pending:
        return 'Pending';
      case UploadStatus.Uploaded:
        return 'Uploaded';
    }
  }

  bool get isPending => this == UploadStatus.Pending;
  bool get isUploaded => this == UploadStatus.Uploaded;
}