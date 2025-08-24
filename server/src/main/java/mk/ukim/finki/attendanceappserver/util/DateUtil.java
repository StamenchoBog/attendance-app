package mk.ukim.finki.attendanceappserver.util;

import lombok.experimental.UtilityClass;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoField;
import java.time.temporal.TemporalAdjusters;
import java.time.temporal.WeekFields;

@UtilityClass
public class DateUtil {

    private static final WeekFields ISO_WEEK_FIELDS = WeekFields.ISO; // Pre-create for efficiency
    private static final DateTimeFormatter LOG_DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private static final String DATE_TIME_PATTERN = "yyyy-MM-dd HH:mm:ss.SSS";
    public static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern(DATE_TIME_PATTERN);

    /**
     * Gets the current ISO week number.
     *
     * @return The current ISO week number as an integer.
     */
    public static int getCurrentWeekNumber() {
        return LocalDate.now().get(ISO_WEEK_FIELDS.weekOfWeekBasedYear());
    }

    public static int getCurrentMonthNumber() {
        return LocalDate.now().getMonth().get(ChronoField.MONTH_OF_YEAR);
    }

    /**
     * Gets the current ISO week number along with the current date (optimized for logging).
     * This method handles getting the current date.
     *
     * @return A string representing the log message with date and week number (e.g., "2024-01-12 - Week: 2").
     */
    public static String getFormattedWeekLog() {
        return getFormattedWeekLog(LocalDate.now());
    }

    /**
     * Gets the start and end dates of the week for a given date.
     *
     * @param date The date within the week.
     * @return An array of LocalDate objects, where index 0 is the start date (Monday)
     *         and index 1 is the end date (Sunday) of the week.  Returns null if the input date is null.
     */
    public static LocalDate[] getWeekStartAndEndDates(LocalDate date) {
        if (date == null) {
            return new LocalDate[0];
        }
        return new LocalDate[]{date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)),
                                date.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY))};
    }

    /**
     * Gets the start and end dates of the month for a given date.
     *
     * @param date The date within the month.
     * @return An array of LocalDate objects, where index 0 is the start date (Monday)
     *         and index 1 is the end date (Sunday) of the week.  Returns null if the input date is null.
     */
    public static LocalDate[] getMonthStartAndEndDates(LocalDate date) {
        if (date == null) {
            return new LocalDate[0];
        }
        return new LocalDate[]{date.with(TemporalAdjusters.firstDayOfMonth()),
                                date.with(TemporalAdjusters.lastDayOfMonth())};
    }


    private static String getFormattedWeekLog(LocalDate currentDate) {
        int weekNumber = currentDate.get(ISO_WEEK_FIELDS.weekOfWeekBasedYear());
        String formattedDate = currentDate.format(LOG_DATE_FORMATTER);
        return String.format("%s - Week: %d", formattedDate, weekNumber); // Use String.format
    }
}
