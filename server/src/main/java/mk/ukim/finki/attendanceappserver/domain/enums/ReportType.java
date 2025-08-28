package mk.ukim.finki.attendanceappserver.domain.enums;

import lombok.Getter;

@Getter
public enum ReportType {
    BUG("bug"),
    FEATURE_REQUEST("featureRequest"),
    ATTENDANCE_ISSUE("attendanceIssue"),
    DEVICE_ISSUE("deviceIssue"),
    OTHER("other");

    private final String value;

    ReportType(String value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return value;
    }

    public static ReportType fromString(String type) {
        for (ReportType reportType : ReportType.values()) {
            if (reportType.value.equalsIgnoreCase(type)) {
                return reportType;
            }
        }
        throw new IllegalArgumentException("Unknown report type: " + type);
    }
}
