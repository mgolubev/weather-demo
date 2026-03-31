import Foundation
@testable import Weather

enum WeatherTestFixtures {
    static let timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    static func date(
        year: Int = 2026,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        timeZone: TimeZone = timeZone
    ) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return components.date ?? Date(timeIntervalSince1970: 0)
    }

    static func condition(code: Int = 1003, text: String = "Cloudy") -> ConditionDTO {
        ConditionDTO(text: text, code: code)
    }

    static func locationDTO(
        city: String = "Moscow",
        country: String = "Russia",
        localTime: Date,
        timeZone: TimeZone = timeZone
    ) -> LocationDTO {
        LocationDTO(
            name: city,
            country: country,
            localTimeEpoch: localTime.timeIntervalSince1970,
            timeZoneIdentifier: timeZone.identifier
        )
    }

    static func currentDTO(
        temperature: Double = 10,
        feelsLike: Double = 8,
        windKph: Double = 12,
        humidity: Int = 74,
        uv: Double = 3.1,
        conditionCode: Int = 1003,
        conditionText: String = "Cloudy",
        isDay: Int = 1
    ) -> CurrentDTO {
        CurrentDTO(
            temperatureCelsius: temperature,
            feelsLikeCelsius: feelsLike,
            windKph: windKph,
            humidity: humidity,
            uv: uv,
            isDay: isDay,
            condition: condition(code: conditionCode, text: conditionText)
        )
    }

    static func hourDTO(
        at date: Date,
        temperature: Double = 10,
        conditionCode: Int = 1003,
        conditionText: String = "Cloudy",
        isDay: Int = 1
    ) -> HourDTO {
        HourDTO(
            timeEpoch: date.timeIntervalSince1970,
            temperatureCelsius: temperature,
            isDay: isDay,
            condition: condition(code: conditionCode, text: conditionText)
        )
    }

    static func forecastDayDTO(
        at date: Date,
        hours: [HourDTO],
        maxTemp: Double = 12,
        minTemp: Double = 6,
        rainChance: Int = 40,
        conditionCode: Int = 1003,
        conditionText: String = "Cloudy"
    ) -> ForecastDayDTO {
        ForecastDayDTO(
            dateEpoch: date.timeIntervalSince1970,
            day: DayDTO(
                maxTempCelsius: maxTemp,
                minTempCelsius: minTemp,
                dailyChanceOfRain: rainChance,
                condition: condition(code: conditionCode, text: conditionText)
            ),
            hours: hours
        )
    }

    static func currentResponse(
        now: Date = date(month: 3, day: 31, hour: 15, minute: 20),
        timeZone: TimeZone = timeZone,
        city: String = "Moscow",
        country: String = "Russia"
    ) -> CurrentWeatherResponseDTO {
        CurrentWeatherResponseDTO(
            location: locationDTO(city: city, country: country, localTime: now, timeZone: timeZone),
            current: currentDTO()
        )
    }

    static func forecastResponse(
        now: Date = date(month: 3, day: 31, hour: 15, minute: 20),
        timeZone: TimeZone = timeZone,
        city: String = "Moscow",
        country: String = "Russia",
        forecastDays: [ForecastDayDTO]? = nil
    ) -> ForecastWeatherResponseDTO {
        let calendar = Calendar.weatherCalendar(for: timeZone)
        let startOfToday = calendar.startOfDay(for: now)

        let resolvedDays = forecastDays ?? (0..<3).map { dayOffset in
            let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) ?? startOfToday
            let hours = (0..<24).map { hour in
                hourDTO(
                    at: calendar.date(byAdding: .hour, value: hour, to: dayStart) ?? dayStart,
                    temperature: Double(10 + dayOffset + hour)
                )
            }
            return forecastDayDTO(at: dayStart, hours: hours)
        }

        return ForecastWeatherResponseDTO(
            location: locationDTO(city: city, country: country, localTime: now, timeZone: timeZone),
            current: currentDTO(),
            forecast: ForecastDTO(forecastDays: resolvedDays)
        )
    }

    static func snapshot(
        now: Date = date(month: 3, day: 31, hour: 15, minute: 20),
        timeZone: TimeZone = timeZone,
        city: String = "Moscow",
        country: String = "Russia"
    ) -> WeatherSnapshot {
        WeatherSnapshot(
            currentResponse: currentResponse(now: now, timeZone: timeZone, city: city, country: country),
            forecastResponse: forecastResponse(now: now, timeZone: timeZone, city: city, country: country)
        )
    }

    static func cachedEntry(
        snapshot: WeatherSnapshot = snapshot(),
        coordinate: LocationCoordinate = .moscow,
        locationSource: LocationSource = .device,
        savedAt: Date = date(month: 3, day: 31, hour: 15, minute: 25)
    ) -> CachedWeatherEntry {
        CachedWeatherEntry(
            coordinate: coordinate,
            locationSource: locationSource,
            snapshot: snapshot,
            savedAt: savedAt
        )
    }
}
