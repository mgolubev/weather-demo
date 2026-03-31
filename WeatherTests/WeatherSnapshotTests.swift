import XCTest
@testable import Weather

final class WeatherSnapshotTests: XCTestCase {
    func testInitializerKeepsRemainingHoursOfTodayAndAllHoursOfTomorrow() {
        let timeZone = WeatherTestFixtures.timeZone
        let calendar = Calendar.weatherCalendar(for: timeZone)
        let now = WeatherTestFixtures.date(month: 3, day: 31, hour: 15, minute: 20, timeZone: timeZone)
        let todayStart = calendar.startOfDay(for: now)
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? todayStart
        let dayAfterTomorrowStart = calendar.date(byAdding: .day, value: 2, to: todayStart) ?? tomorrowStart

        let todayHours = [14, 15, 16, 23].map {
            WeatherTestFixtures.hourDTO(
                at: calendar.date(byAdding: .hour, value: $0, to: todayStart) ?? todayStart,
                temperature: Double($0)
            )
        }
        let tomorrowHours = [0, 12, 23].map {
            WeatherTestFixtures.hourDTO(
                at: calendar.date(byAdding: .hour, value: $0, to: tomorrowStart) ?? tomorrowStart,
                temperature: Double(100 + $0)
            )
        }
        let dayAfterTomorrowHours = [
            WeatherTestFixtures.hourDTO(at: dayAfterTomorrowStart, temperature: 200)
        ]

        let forecastDays = [
            WeatherTestFixtures.forecastDayDTO(at: todayStart, hours: todayHours),
            WeatherTestFixtures.forecastDayDTO(at: tomorrowStart, hours: tomorrowHours),
            WeatherTestFixtures.forecastDayDTO(at: dayAfterTomorrowStart, hours: dayAfterTomorrowHours)
        ]

        let snapshot = WeatherSnapshot(
            currentResponse: WeatherTestFixtures.currentResponse(now: now, timeZone: timeZone),
            forecastResponse: WeatherTestFixtures.forecastResponse(
                now: now,
                timeZone: timeZone,
                forecastDays: forecastDays
            )
        )

        XCTAssertEqual(snapshot.hourly.count, 6)
        XCTAssertEqual(
            snapshot.hourly.map { calendar.component(.hour, from: $0.date) },
            [15, 16, 23, 0, 12, 23]
        )
        XCTAssertTrue(snapshot.hourly.allSatisfy { hour in
            let isRemainingToday = hour.date >= calendar.dateInterval(of: .hour, for: now)?.start ?? now
                && hour.date < tomorrowStart
            let isTomorrow = hour.date >= tomorrowStart && hour.date < dayAfterTomorrowStart
            return isRemainingToday || isTomorrow
        })
    }
}
