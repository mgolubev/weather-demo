import Foundation

struct CurrentWeather: Codable, Hashable, Sendable {
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

struct HourlyForecast: Codable, Hashable, Sendable {
    let date: Date
    let temperature: Double
    let conditionCode: Int
    let isDay: Bool
}

struct DailyForecast: Codable, Hashable, Sendable {
    let date: Date
    let minTemperature: Double
    let maxTemperature: Double
    let rainChance: Int
    let conditionText: String
    let conditionCode: Int
}
