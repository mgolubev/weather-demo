import Foundation

struct LocationCoordinate {
    let latitude: Double
    let longitude: Double

    static let moscow = LocationCoordinate(latitude: 55.7558, longitude: 37.6176)
}

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
        hourly = WeatherSnapshot.makeHourlyForecast(
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

struct CurrentWeather {
    let temperature: Double
    let feelsLike: Double
    let windKph: Double
    let humidity: Int
    let uv: Double
    let conditionText: String
    let conditionCode: Int
    let isDay: Bool
    let dayHigh: Double
    let dayLow: Double
}

struct HourlyForecast {
    let date: Date
    let temperature: Double
    let conditionCode: Int
    let isDay: Bool
}

struct DailyForecast {
    let date: Date
    let minTemperature: Double
    let maxTemperature: Double
    let rainChance: Int
    let conditionText: String
    let conditionCode: Int
}

enum WeatherFormatters {
    private static let russianLocale = Locale(identifier: "ru_RU")

    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = russianLocale
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let updateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = russianLocale
        formatter.dateFormat = "d MMMM, HH:mm"
        return formatter
    }()

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = russianLocale
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    static func temperature(_ value: Double) -> String {
        "\(Int(value.rounded()))°"
    }

    static func feelsLike(_ value: Double) -> String {
        "\(Int(value.rounded()))°"
    }

    static func wind(_ value: Double) -> String {
        "\(Int(value.rounded())) км/ч"
    }

    static func humidity(_ value: Int) -> String {
        "\(value)%"
    }

    static func uv(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    static func updatedAt(_ date: Date, timeZone: TimeZone) -> String {
        updateFormatter.timeZone = timeZone
        return "Обновлено \(updateFormatter.string(from: date))"
    }

    static func hourTitle(for date: Date, now: Date, timeZone: TimeZone) -> String {
        let calendar = Calendar.weatherCalendar(for: timeZone)
        if calendar.isDate(date, equalTo: now, toGranularity: .hour) {
            return "Сейчас"
        }

        hourFormatter.timeZone = timeZone
        return hourFormatter.string(from: date)
    }

    static func dayTitle(for date: Date, now: Date, timeZone: TimeZone) -> String {
        let calendar = Calendar.weatherCalendar(for: timeZone)

        if calendar.isDate(date, inSameDayAs: now) {
            return "Сегодня"
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Завтра"
        }

        weekdayFormatter.timeZone = timeZone
        return weekdayFormatter.string(from: date).capitalized
    }
}

enum WeatherSymbolProvider {
    static func symbolName(for conditionCode: Int, isDay: Bool) -> String {
        switch conditionCode {
        case 1000:
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1003:
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 1006, 1009:
            return "cloud.fill"
        case 1030, 1135, 1147:
            return "cloud.fog.fill"
        case 1063, 1150, 1153, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246:
            return "cloud.rain.fill"
        case 1087, 1273, 1276:
            return "cloud.bolt.rain.fill"
        case 1066, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258, 1279, 1282:
            return "cloud.snow.fill"
        case 1069, 1072, 1168, 1171, 1204, 1207, 1237, 1249, 1252, 1261, 1264:
            return "cloud.sleet.fill"
        default:
            return "cloud.fill"
        }
    }
}

extension Calendar {
    static func weatherCalendar(for timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "ru_RU")
        return calendar
    }
}

struct CurrentWeatherResponseDTO: Decodable {
    let location: LocationDTO
    let current: CurrentDTO
}

struct ForecastWeatherResponseDTO: Decodable {
    let location: LocationDTO
    let current: CurrentDTO
    let forecast: ForecastDTO
}

struct LocationDTO: Decodable {
    let name: String
    let country: String
    let localTimeEpoch: TimeInterval
    let timeZoneIdentifier: String

    enum CodingKeys: String, CodingKey {
        case name
        case country
        case localTimeEpoch = "localtime_epoch"
        case timeZoneIdentifier = "tz_id"
    }
}

struct CurrentDTO: Decodable {
    let temperatureCelsius: Double
    let feelsLikeCelsius: Double
    let windKph: Double
    let humidity: Int
    let uv: Double
    let isDay: Int
    let condition: ConditionDTO

    enum CodingKeys: String, CodingKey {
        case temperatureCelsius = "temp_c"
        case feelsLikeCelsius = "feelslike_c"
        case windKph = "wind_kph"
        case humidity
        case uv
        case isDay = "is_day"
        case condition
    }
}

struct ForecastDTO: Decodable {
    let forecastDays: [ForecastDayDTO]

    enum CodingKeys: String, CodingKey {
        case forecastDays = "forecastday"
    }
}

struct ForecastDayDTO: Decodable {
    let dateEpoch: TimeInterval
    let day: DayDTO
    let hours: [HourDTO]

    enum CodingKeys: String, CodingKey {
        case dateEpoch = "date_epoch"
        case day
        case hours = "hour"
    }
}

struct DayDTO: Decodable {
    let maxTempCelsius: Double
    let minTempCelsius: Double
    let dailyChanceOfRain: Int?
    let condition: ConditionDTO

    enum CodingKeys: String, CodingKey {
        case maxTempCelsius = "maxtemp_c"
        case minTempCelsius = "mintemp_c"
        case dailyChanceOfRain = "daily_chance_of_rain"
        case condition
    }
}

struct HourDTO: Decodable {
    let timeEpoch: TimeInterval
    let temperatureCelsius: Double
    let isDay: Int
    let condition: ConditionDTO

    enum CodingKeys: String, CodingKey {
        case timeEpoch = "time_epoch"
        case temperatureCelsius = "temp_c"
        case isDay = "is_day"
        case condition
    }
}

struct ConditionDTO: Decodable {
    let text: String
    let code: Int
}
