import Foundation

@MainActor
final class WeatherViewModel {
    var onStateChange: ((WeatherViewState) -> Void)?
    var onEvent: ((WeatherViewEvent) -> Void)?

    private let locationProvider: LocationProviding
    private let weatherService: WeatherFetching
    private let mapper: WeatherViewDataMapping

    private var loadTask: Task<Void, Never>?
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
        let previousContent = currentContent
        loadTask?.cancel()

        state = previousContent.map(WeatherViewState.refreshing) ?? .loading

        loadTask = Task { [weak self] in
            guard let self else {
                return
            }

            let coordinates = await locationProvider.requestCoordinates()

            do {
                try Task.checkCancellation()
                let snapshot = try await weatherService.fetchWeather(for: coordinates)
                try Task.checkCancellation()

                let viewData = mapper.map(snapshot: snapshot)
                state = .content(viewData)
            } catch is CancellationError {
                return
            } catch {
                if let previousContent {
                    state = .content(previousContent)
                    onEvent?(
                        .showRefreshError(
                            title: "Не удалось обновить данные",
                            message: error.localizedDescription
                        )
                    )
                } else {
                    state = .error(
                        WeatherErrorViewData(
                            title: "Не удалось загрузить погоду",
                            message: error.localizedDescription,
                            buttonTitle: "Повторить"
                        )
                    )
                }
            }
        }
    }

    private var currentContent: WeatherScreenViewData? {
        switch state {
        case let .content(viewData), let .refreshing(viewData):
            return viewData
        case .loading, .error:
            return nil
        }
    }
}
