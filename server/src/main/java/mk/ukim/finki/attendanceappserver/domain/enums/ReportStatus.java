package mk.ukim.finki.attendanceappserver.domain.enums;

import lombok.Getter;

@Getter
public enum ReportStatus {
    NEW("NEW"),
    IN_PROGRESS("IN_PROGRESS"),
    RESOLVED("RESOLVED"),
    CLOSED("CLOSED");

    private final String value;

    ReportStatus(String value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return value;
    }

    public static ReportStatus fromString(String status) {
        for (ReportStatus reportStatus : ReportStatus.values()) {
            if (reportStatus.value.equalsIgnoreCase(status)) {
                return reportStatus;
            }
        }
        throw new IllegalArgumentException("Unknown report status: " + status);
    }
}
