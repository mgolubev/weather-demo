import Foundation

struct WeatherSnapshot {
    let city: String
    let country: String
    let localTime: Date
    let timeZone: TimeZone
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    let daily: [DailyForecast]

    init(currentResponse: CurrentWeatherResponseDTO, forecastResponse: ForecastWeatherResponseDTO) {
        let timeZone = TimeZone(identifier: currentResponse.location.timeZoneIdentifier) ?? .current
        let localTime = Date(timeIntervalSince1970: currentResponse.location.localTimeEpoch)
        let firstForecastDay = forecastResponse.forecast.forecastDays.first

        city = currentResponse.location.name
        country = currentResponse.location.country
        self.localTime = localTime
        self.timeZone = timeZone
        current = CurrentWeather(
            temperature: currentResponse.current.temperatureCelsius,
            feelsLike: currentResponse.current.feelsLikeCelsius,
            windKph: currentResponse.current.windKph,
            humidity: currentResponse.current.humidity,
            uv: currentResponse.current.uv,
            conditionText: currentResponse.current.condition.text,
            conditionCode: currentResponse.current.condition.code,
            isDay: currentResponse.current.isDay == 1,
            dayHigh: firstForecastDay?.day.maxTempCelsius ?? currentResponse.current.temperatureCelsius,
            dayLow: firstForecastDay?.day.minTempCelsius ?? currentResponse.current.temperatureCelsius
        )
        hourly = Self.makeHourlyForecast(
            from: forecastResponse.forecast.forecastDays,
            localTime: localTime,
            timeZone: timeZone
        )
        daily = forecastResponse.forecast.forecastDays.prefix(3).map {
            DailyForecast(
                date: Date(timeIntervalSince1970: $0.dateEpoch),
                minTemperature: $0.day.minTempCelsius,
                maxTemperature: $0.day.maxTempCelsius,
                rainChance: $0.day.dailyChanceOfRain ?? 0,
                conditionText: $0.day.condition.text,
                conditionCode: $0.day.condition.code
            )
        }
    }

    private static func makeHourlyForecast(
        from forecastDays: [ForecastDayDTO],
        localTime: Date,
        timeZone: TimeZone
    ) -> [HourlyForecast] {
        let calendar = Calendar.weatherCalendar(for: timeZone)
        let startOfCurrentHour = calendar.dateInterval(of: .hour, for: localTime)?.start ?? localTime
        let todayStart = calendar.startOfDay(for: localTime)
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? todayStart
        let dayAfterTomorrowStart = calendar.date(byAdding: .day, value: 2, to: todayStart) ?? tomorrowStart

        return forecastDays
            .flatMap(\.hours)
            .map {
                HourlyForecast(
                    date: Date(timeIntervalSince1970: $0.timeEpoch),
                    temperature: $0.temperatureCelsius,
                    conditionCode: $0.condition.code,
                    isDay: $0.isDay == 1
                )
            }
            .filter { hour in
                let isRemainingToday = hour.date >= startOfCurrentHour && hour.date < tomorrowStart
                let isNextDay = hour.date >= tomorrowStart && hour.date < dayAfterTomorrowStart
                return isRemainingToday || isNextDay
            }
            .sorted { $0.date < $1.date }
    }
}
