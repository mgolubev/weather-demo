import Foundation

@MainActor
final class WeatherViewModel {
    var onStateChange: ((WeatherViewState) -> Void)?

    private let locationProvider: LocationProviding
    private let weatherService: WeatherFetching
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
        mapper: WeatherViewDataMapping
    ) {
        self.locationProvider = locationProvider
        self.weatherService = weatherService
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
        let previousContent = lastSuccessfulContent
        loadTask?.cancel()

        state = previousContent.map(WeatherViewState.refreshing) ?? .loading

        loadTask = Task { [weak self] in
            guard let self else {
                return
            }

            do {
                let resolvedLocation = try await locationProvider.requestCoordinates()

                try Task.checkCancellation()
                let snapshot = try await weatherService.fetchWeather(for: resolvedLocation.coordinate)
                try Task.checkCancellation()

                let viewData = mapper.map(snapshot: snapshot, locationSource: resolvedLocation.source)
                lastSuccessfulContent = viewData
                state = .content(viewData)
            } catch is CancellationError {
                return
            } catch {
                let title = previousContent == nil
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
}
