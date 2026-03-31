import Foundation

@MainActor
final class WeatherViewModel {
    var onStateChange: ((WeatherViewState) -> Void)?

    private let locationProvider: LocationProviding
    private let weatherService: WeatherFetching
    private let cacheService: WeatherCaching
    private let mapper: WeatherViewDataMapping

    private var loadTask: Task<Void, Never>?
    private var lastSuccessfulContent: WeatherScreenViewData?
    private var state: WeatherViewState = .loading {
        didSet {
            onStateChange?(state)
        }
    }

    init(
        locationProvider: LocationProviding,
        weatherService: WeatherFetching,
        cacheService: WeatherCaching,
        mapper: WeatherViewDataMapping
    ) {
        self.locationProvider = locationProvider
        self.weatherService = weatherService
        self.cacheService = cacheService
        self.mapper = mapper
    }

    deinit {
        loadTask?.cancel()
    }

    func viewDidLoad() {
        loadWeather()
    }

    func refreshTapped() {
        loadWeather()
    }

    func retryTapped() {
        loadWeather()
    }

    private func loadWeather() {
        loadTask?.cancel()

        loadTask = Task { [weak self] in
            guard let self else {
                return
            }

            let initialContent = await makeInitialContent()

            guard !Task.isCancelled else {
                return
            }

            state = initialContent.map(WeatherViewState.refreshing) ?? .loading

            do {
                let resolvedLocation = try await locationProvider.requestCoordinates()

                try Task.checkCancellation()
                let snapshot = try await weatherService.fetchWeather(for: resolvedLocation.coordinate)
                try Task.checkCancellation()

                await cacheService.save(
                    CachedWeatherEntry(
                        coordinate: resolvedLocation.coordinate,
                        locationSource: resolvedLocation.source,
                        snapshot: snapshot,
                        savedAt: Date()
                    )
                )

                let viewData = mapper.map(
                    snapshot: snapshot,
                    locationSource: resolvedLocation.source,
                    dataOrigin: .live
                )
                lastSuccessfulContent = viewData
                state = .content(viewData)
            } catch is CancellationError {
                return
            } catch {
                let title = initialContent == nil
                    ? "Не удалось загрузить погоду"
                    : "Не удалось обновить данные"

                state = .error(
                    WeatherErrorViewData(
                        title: title,
                        message: error.localizedDescription,
                        buttonTitle: "Повторить"
                    )
                )
            }
        }
    }

    private func makeInitialContent() async -> WeatherScreenViewData? {
        if let lastSuccessfulContent {
            return lastSuccessfulContent
        }

        guard let cachedEntry = await cacheService.loadLatest() else {
            return nil
        }

        let cachedViewData = mapper.map(
            snapshot: cachedEntry.snapshot,
            locationSource: cachedEntry.locationSource,
            dataOrigin: .cached(savedAt: cachedEntry.savedAt)
        )
        lastSuccessfulContent = cachedViewData
        return cachedViewData
    }
}
