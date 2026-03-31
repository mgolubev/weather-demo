import Foundation

struct WeatherScreenViewData: Hashable, Sendable {
    let hero: WeatherHeroViewData
    let details: WeatherDetailsViewData
    let hourlyItems: [HourlyForecastItemViewData]
    let dailyItems: [DailyForecastItemViewData]
    let isDay: Bool
}

struct WeatherHeroViewData: Hashable, Sendable {
    let locationText: String
    let metaText: String
    let currentSymbolName: String
    let temperatureText: String
    let conditionText: String
    let rangeText: String
}

struct WeatherDetailsViewData: Hashable, Sendable {
    let feelsLikeText: String
    let windText: String
    let humidityText: String
    let uvText: String
}

struct HourlyForecastItemViewData: Hashable, Sendable {
    let timeText: String
    let symbolName: String
    let temperatureText: String
}

struct DailyForecastItemViewData: Hashable, Sendable {
    let dayText: String
    let descriptionText: String
    let symbolName: String
    let temperaturesText: String
    let rainChanceText: String
}

struct WeatherErrorViewData {
    let title: String
    let message: String
    let buttonTitle: String
}

enum WeatherViewState {
    case loading
    case content(WeatherScreenViewData)
    case refreshing(WeatherScreenViewData)
    case error(WeatherErrorViewData)
}
