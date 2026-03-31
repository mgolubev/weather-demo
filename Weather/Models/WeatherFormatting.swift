import Foundation

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
