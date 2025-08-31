enum ReportType {
  bug('BUG'),
  featureRequest('FEATURE_REQUEST'),
  attendanceIssue('ATTENDANCE_ISSUE'),
  deviceIssue('DEVICE_ISSUE'),
  other('OTHER');

  const ReportType(this.value);

  final String value;

  static ReportType fromString(String value) {
    for (ReportType type in ReportType.values) {
      if (type.value == value) {
        return type;
      }
    }
    throw ArgumentError('Unknown report type: $value');
  }

  String get serverValue {
    // Return the UPPER_SNAKE_CASE values expected by the API
    return value;
  }

  @override
  String toString() => value;
}

enum ReportStatus {
  newReport('NEW'),
  inProgress('IN_PROGRESS'),
  resolved('RESOLVED'),
  closed('CLOSED');

  const ReportStatus(this.value);

  final String value;

  static ReportStatus fromString(String value) {
    for (ReportStatus status in ReportStatus.values) {
      if (status.value == value) {
        return status;
      }
    }
    throw ArgumentError('Unknown report status: $value');
  }

  @override
  String toString() => value;
}

enum ReportPriority {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  critical('CRITICAL');

  const ReportPriority(this.value);

  final String value;

  static ReportPriority fromString(String value) {
    for (ReportPriority priority in ReportPriority.values) {
      if (priority.value == value) {
        return priority;
      }
    }
    throw ArgumentError('Unknown report priority: $value');
  }

  String get serverValue {
    // Return the UPPERCASE values expected by the API
    return value;
  }

  @override
  String toString() => value;
}
