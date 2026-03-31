import Foundation

protocol WeatherFetching {
    func fetchWeather(for coordinate: LocationCoordinate) async throws -> WeatherSnapshot
}

final class WeatherAPIClient: WeatherFetching {
    private enum Endpoint {
        case current
        case forecast(days: Int)

        var path: String {
            switch self {
            case .current:
                return "/v1/current.json"
            case .forecast:
                return "/v1/forecast.json"
            }
        }

        var extraQueryItems: [URLQueryItem] {
            switch self {
            case .current:
                return []
            case let .forecast(days):
                return [URLQueryItem(name: "days", value: "\(days)")]
            }
        }
    }

    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchWeather(for coordinate: LocationCoordinate) async throws -> WeatherSnapshot {
        async let currentRequest: CurrentWeatherResponseDTO = request(.current, coordinate: coordinate)
        async let forecastRequest: ForecastWeatherResponseDTO = request(.forecast(days: 3), coordinate: coordinate)

        let (current, forecast) = try await (currentRequest, forecastRequest)
        return WeatherSnapshot(currentResponse: current, forecastResponse: forecast)
    }

    private func request<Response: Decodable>(
        _ endpoint: Endpoint,
        coordinate: LocationCoordinate
    ) async throws -> Response {
        guard let url = makeURL(for: endpoint, coordinate: coordinate) else {
            throw WeatherServiceError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherServiceError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                if let apiError = try? decoder.decode(WeatherAPIErrorResponse.self, from: data) {
                    throw WeatherServiceError.api(apiError.error.message)
                }
                throw WeatherServiceError.httpStatus(httpResponse.statusCode)
            }

            return try decoder.decode(Response.self, from: data)
        } catch let error as WeatherServiceError {
            throw error
        } catch let error as DecodingError {
            throw WeatherServiceError.decoding(error)
        } catch let error as URLError {
            throw WeatherServiceError.network(error)
        } catch {
            throw WeatherServiceError.unknown(error)
        }
    }

    private func makeURL(for endpoint: Endpoint, coordinate: LocationCoordinate) -> URL? {
        let coordinates = String(
            format: "%.4f,%.4f",
            locale: Locale(identifier: "en_US_POSIX"),
            coordinate.latitude,
            coordinate.longitude
        )

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.weatherapi.com"
        components.path = endpoint.path
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: coordinates),
            URLQueryItem(name: "lang", value: "ru")
        ] + endpoint.extraQueryItems
        return components.url
    }
}

enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case api(String)
    case decoding(Error)
    case network(URLError)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось сформировать запрос к погодному сервису."
        case .invalidResponse:
            return "Сервис погоды вернул неожиданный ответ."
        case let .httpStatus(code):
            return "Сервис погоды ответил ошибкой \(code)."
        case let .api(message):
            return message
        case .decoding:
            return "Не удалось разобрать ответ сервера. Попробуйте обновить данные ещё раз."
        case .network:
            return "Похоже, есть проблема с интернет-соединением. Попробуйте ещё раз."
        case .unknown:
            return "Что-то пошло не так при загрузке погоды. Попробуйте ещё раз."
        }
    }
}

private struct WeatherAPIErrorResponse: Decodable, Sendable {
    let error: WeatherAPIErrorDetails
}

private struct WeatherAPIErrorDetails: Decodable, Sendable {
    let message: String
}
