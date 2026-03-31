import Foundation

struct WeatherScreenViewData {
    let locationText: String
    let metaText: String
    let currentSymbolName: String
    let temperatureText: String
    let conditionText: String
    let rangeText: String
    let details: WeatherDetailsViewData
    let hourlyItems: [HourlyForecastItemViewData]
    let dailyItems: [DailyForecastItemViewData]
    let isDay: Bool
}

struct WeatherDetailsViewData {
    let feelsLikeText: String
    let windText: String
    let humidityText: String
    let uvText: String
}

struct HourlyForecastItemViewData {
    let timeText: String
    let symbolName: String
    let temperatureText: String
}

struct DailyForecastItemViewData {
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

enum WeatherViewEvent {
    case showRefreshError(title: String, message: String)
}
