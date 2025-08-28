enum ReportType {
  bug('bug'),
  featureRequest('featureRequest'),
  attendanceIssue('attendanceIssue'),
  deviceIssue('deviceIssue'),
  other('other');

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

  @override
  String toString() => value;
}

enum ReportPriority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

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
