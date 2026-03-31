import Foundation

enum WeatherDataOrigin: Hashable, Sendable {
    case live
    case cached(savedAt: Date)

    var noticeText: String? {
        switch self {
        case .live:
            return nil
        case .cached:
            return "Показываем последние сохранённые данные."
        }
    }
}

struct CachedWeatherEntry: Codable, Hashable, Sendable {
    let coordinate: LocationCoordinate
    let locationSource: LocationSource
    let snapshot: WeatherSnapshot
    let savedAt: Date
}
