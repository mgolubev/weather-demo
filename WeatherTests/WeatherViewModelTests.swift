import XCTest
@testable import Weather

@MainActor
final class WeatherViewModelTests: XCTestCase {
    func testViewDidLoadShowsCachedContentBeforeRefreshingFromNetwork() async {
        let suiteName = "WeatherViewModelTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let cacheService = WeatherCacheService(userDefaults: userDefaults)
        let cachedEntry = WeatherTestFixtures.cachedEntry()
        await cacheService.save(cachedEntry)

        let viewModel = WeatherViewModel(
            locationProvider: DelayedLocationProvider(delayNanoseconds: 500_000_000),
            weatherService: SuccessfulWeatherService(snapshot: WeatherTestFixtures.snapshot(city: "Live City")),
            cacheService: cacheService,
            mapper: StubWeatherViewDataMapper()
        )

        let refreshingExpectation = expectation(description: "refreshing state with cached content")

        viewModel.onStateChange = { state in
            guard case let .refreshing(viewData) = state else {
                return
            }

            XCTAssertEqual(viewData.hero.locationText, "cached")
            refreshingExpectation.fulfill()
        }

        viewModel.viewDidLoad()

        await fulfillment(of: [refreshingExpectation], timeout: 0.2)
    }

    func testViewDidLoadShowsErrorWhenNoCacheAndRequestFails() async {
        let suiteName = "WeatherViewModelTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let viewModel = WeatherViewModel(
            locationProvider: FailingLocationProvider(error: TestError()),
            weatherService: SuccessfulWeatherService(snapshot: WeatherTestFixtures.snapshot()),
            cacheService: WeatherCacheService(userDefaults: userDefaults),
            mapper: StubWeatherViewDataMapper()
        )

        let errorExpectation = expectation(description: "error state")
        var observedLoading = false

        viewModel.onStateChange = { state in
            switch state {
            case .loading:
                observedLoading = true
            case let .error(viewData):
                XCTAssertTrue(observedLoading)
                XCTAssertEqual(viewData.title, "Не удалось загрузить погоду")
                XCTAssertEqual(viewData.message, "Test failure")
                errorExpectation.fulfill()
            case .content, .refreshing:
                break
            }
        }

        viewModel.viewDidLoad()

        await fulfillment(of: [errorExpectation], timeout: 1.0)
    }
}

private struct DelayedLocationProvider: LocationProviding {
    let delayNanoseconds: UInt64

    func requestCoordinates() async throws -> ResolvedLocation {
        try await Task.sleep(nanoseconds: delayNanoseconds)
        return ResolvedLocation(coordinate: .moscow, source: .device)
    }
}

private struct FailingLocationProvider: LocationProviding {
    let error: Error

    func requestCoordinates() async throws -> ResolvedLocation {
        throw error
    }
}

private struct SuccessfulWeatherService: WeatherFetching {
    let snapshot: WeatherSnapshot

    func fetchWeather(for coordinate: LocationCoordinate) async throws -> WeatherSnapshot {
        snapshot
    }
}

private struct StubWeatherViewDataMapper: WeatherViewDataMapping {
    func map(
        snapshot: WeatherSnapshot,
        locationSource: LocationSource,
        dataOrigin: WeatherDataOrigin
    ) -> WeatherScreenViewData {
        let locationText: String
        switch dataOrigin {
        case .live:
            locationText = "live"
        case .cached:
            locationText = "cached"
        }

        return WeatherScreenViewData(
            hero: WeatherHeroViewData(
                locationText: locationText,
                metaText: locationSource.noticeText ?? "",
                currentSymbolName: "cloud.fill",
                temperatureText: "10°",
                conditionText: "Cloudy",
                rangeText: "12° / 6°"
            ),
            details: WeatherDetailsViewData(
                feelsLikeText: "8°",
                windText: "12 км/ч",
                humidityText: "74%",
                uvText: "3.1"
            ),
            hourlyItems: [],
            dailyItems: [],
            isDay: true
        )
    }
}

private struct TestError: LocalizedError {
    var errorDescription: String? {
        "Test failure"
    }
}
