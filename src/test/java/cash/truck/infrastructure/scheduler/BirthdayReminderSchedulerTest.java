package cash.truck.infrastructure.scheduler;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class BirthdayReminderSchedulerTest {

    @Test
    void unDiaCualquieraBuscaSoloEseDia() {
        assertEquals(List.of("09-16"), BirthdayReminderScheduler.birthdayMonthDays(LocalDate.of(2026, 9, 16)));
    }

    @Test
    void elVeintiochoDeFebreroDeUnAnoNoBisiestoIncluyeAlVeintinueve() {
        assertEquals(List.of("02-28", "02-29"),
                BirthdayReminderScheduler.birthdayMonthDays(LocalDate.of(2027, 2, 28)));
    }

    @Test
    void enAnoBisiestoElVeintinueveSeSaludaEseDia() {
        assertEquals(List.of("02-28"), BirthdayReminderScheduler.birthdayMonthDays(LocalDate.of(2028, 2, 28)));
        assertEquals(List.of("02-29"), BirthdayReminderScheduler.birthdayMonthDays(LocalDate.of(2028, 2, 29)));
    }
}
