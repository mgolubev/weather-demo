import Foundation

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
