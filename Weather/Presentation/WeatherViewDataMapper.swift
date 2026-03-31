import Foundation

protocol WeatherViewDataMapping {
    func map(snapshot: WeatherSnapshot) -> WeatherScreenViewData
}

struct WeatherViewDataMapper: WeatherViewDataMapping {
    func map(snapshot: WeatherSnapshot) -> WeatherScreenViewData {
        WeatherScreenViewData(
            hero: WeatherHeroViewData(
                locationText: snapshot.city,
                metaText: "\(snapshot.country) • \(WeatherFormatters.updatedAt(snapshot.localTime, timeZone: snapshot.timeZone))",
                currentSymbolName: WeatherSymbolProvider.symbolName(
                    for: snapshot.current.conditionCode,
                    isDay: snapshot.current.isDay
                ),
                temperatureText: WeatherFormatters.temperature(snapshot.current.temperature),
                conditionText: snapshot.current.conditionText.capitalized,
                rangeText: "Макс. \(WeatherFormatters.temperature(snapshot.current.dayHigh)) • Мин. \(WeatherFormatters.temperature(snapshot.current.dayLow))"
            ),
            details: WeatherDetailsViewData(
                feelsLikeText: WeatherFormatters.feelsLike(snapshot.current.feelsLike),
                windText: WeatherFormatters.wind(snapshot.current.windKph),
                humidityText: WeatherFormatters.humidity(snapshot.current.humidity),
                uvText: WeatherFormatters.uv(snapshot.current.uv)
            ),
            hourlyItems: snapshot.hourly.map { hourly in
                HourlyForecastItemViewData(
                    timeText: WeatherFormatters.hourTitle(
                        for: hourly.date,
                        now: snapshot.localTime,
                        timeZone: snapshot.timeZone
                    ),
                    symbolName: WeatherSymbolProvider.symbolName(
                        for: hourly.conditionCode,
                        isDay: hourly.isDay
                    ),
                    temperatureText: WeatherFormatters.temperature(hourly.temperature)
                )
            },
            dailyItems: snapshot.daily.map { daily in
                DailyForecastItemViewData(
                    dayText: WeatherFormatters.dayTitle(
                        for: daily.date,
                        now: snapshot.localTime,
                        timeZone: snapshot.timeZone
                    ),
                    descriptionText: daily.conditionText.capitalized,
                    symbolName: WeatherSymbolProvider.symbolName(for: daily.conditionCode, isDay: true),
                    temperaturesText: "\(WeatherFormatters.temperature(daily.maxTemperature)) / \(WeatherFormatters.temperature(daily.minTemperature))",
                    rainChanceText: "Осадки \(daily.rainChance)%"
                )
            },
            isDay: snapshot.current.isDay
        )
    }
}
