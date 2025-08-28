package mk.ukim.finki.attendanceappserver.domain.enums;

public enum ReportPriority {
    LOW("low"),
    MEDIUM("medium"),
    HIGH("high"),
    CRITICAL("critical");

    private final String value;

    ReportPriority(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    @Override
    public String toString() {
        return value;
    }

    public static ReportPriority fromString(String priority) {
        for (ReportPriority reportPriority : ReportPriority.values()) {
            if (reportPriority.value.equalsIgnoreCase(priority)) {
                return reportPriority;
            }
        }
        throw new IllegalArgumentException("Unknown report priority: " + priority);
    }
}
