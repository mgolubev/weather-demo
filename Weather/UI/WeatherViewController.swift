import UIKit

final class WeatherViewController: UIViewController {
    private let viewModel: WeatherViewModel
    private var currentViewData: WeatherScreenViewData?
    private var hourlyItems: [HourlyForecastItemViewData] = []

    private lazy var refreshButton = UIBarButtonItem(
        systemItem: .refresh,
        primaryAction: UIAction { [weak self] _ in
            self?.viewModel.refreshTapped()
        }
    )

    private let refreshIndicator = UIActivityIndicatorView(style: .medium)

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let heroCard = UIView()
    private let detailsCard = UIView()
    private let hourlyCard = UIView()
    private let dailyCard = UIView()

    private let locationLabel = UILabel()
    private let metaLabel = UILabel()
    private let currentIconView = UIImageView()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let rangeLabel = UILabel()

    private let feelsLikeTile = StatTileView(title: "Ощущается как")
    private let windTile = StatTileView(title: "Ветер")
    private let humidityTile = StatTileView(title: "Влажность")
    private let uvTile = StatTileView(title: "UV")

    private let hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.itemSize = CGSize(width: 92, height: 132)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let dailyStack = UIStackView()

    private let loadingOverlay = UIView()
    private let errorOverlay = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private let errorTitleLabel = UILabel()
    private let errorMessageLabel = UILabel()
    private lazy var retryButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = UIColor(red: 0.07, green: 0.22, blue: 0.48, alpha: 1)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 22, bottom: 12, trailing: 22)
        configuration.title = "Повторить"

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.retryTapped()
            },
            for: .touchUpInside
        )
        return button
    }()

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        view = GradientBackgroundView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureScrollView()
        configureHeroCard()
        configureDetailsCard()
        configureHourlyCard()
        configureDailyCard()
        configureStateOverlays()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state: state)
        }

        viewModel.onEvent = { [weak self] event in
            self?.handle(event: event)
        }
    }

    private func render(state: WeatherViewState) {
        switch state {
        case .loading:
            showLoading(preservingContent: false)
        case let .content(viewData):
            apply(viewData: viewData, isRefreshing: false)
        case let .refreshing(viewData):
            apply(viewData: viewData, isRefreshing: true)
        case let .error(errorViewData):
            apply(errorViewData: errorViewData)
        }
    }

    private func handle(event: WeatherViewEvent) {
        switch event {
        case let .showRefreshError(title, message):
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .cancel))
            alert.addAction(
                UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                    self?.viewModel.refreshTapped()
                }
            )
            present(alert, animated: true)
        }
    }

    private func configureNavigationBar() {
        title = "Погода"
        navigationItem.rightBarButtonItem = refreshButton
        navigationController?.navigationBar.tintColor = .white

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .always

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 40, right: 20)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        [heroCard, detailsCard, hourlyCard, dailyCard].forEach { card in
            applyCardStyle(to: card)
            contentStack.addArrangedSubview(card)
        }
    }

    private func configureHeroCard() {
        let stack = UIStackView(arrangedSubviews: [
            locationLabel,
            metaLabel,
            currentIconView,
            temperatureLabel,
            conditionLabel,
            rangeLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center

        locationLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        locationLabel.textColor = .white
        locationLabel.textAlignment = .center

        metaLabel.font = .systemFont(ofSize: 15, weight: .medium)
        metaLabel.textColor = UIColor.white.withAlphaComponent(0.80)
        metaLabel.textAlignment = .center

        currentIconView.tintColor = .white
        currentIconView.contentMode = .scaleAspectFit
        currentIconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 68, weight: .regular)
        currentIconView.translatesAutoresizingMaskIntoConstraints = false

        temperatureLabel.font = .monospacedDigitSystemFont(ofSize: 78, weight: .light)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center

        conditionLabel.font = .systemFont(ofSize: 22, weight: .medium)
        conditionLabel.textColor = .white
        conditionLabel.textAlignment = .center

        rangeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        rangeLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        rangeLabel.textAlignment = .center

        heroCard.addSubview(stack)

        NSLayoutConstraint.activate([
            currentIconView.widthAnchor.constraint(equalToConstant: 82),
            currentIconView.heightAnchor.constraint(equalToConstant: 82),

            stack.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -28)
        ])
    }

    private func configureDetailsCard() {
        let titleLabel = makeSectionTitleLabel(text: "Подробности")

        let firstRow = UIStackView(arrangedSubviews: [feelsLikeTile, windTile])
        firstRow.axis = .horizontal
        firstRow.spacing = 12
        firstRow.distribution = .fillEqually

        let secondRow = UIStackView(arrangedSubviews: [humidityTile, uvTile])
        secondRow.axis = .horizontal
        secondRow.spacing = 12
        secondRow.distribution = .fillEqually

        let gridStack = UIStackView(arrangedSubviews: [firstRow, secondRow])
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.axis = .vertical
        gridStack.spacing = 12

        detailsCard.addSubview(titleLabel)
        detailsCard.addSubview(gridStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -20),

            gridStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            gridStack.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 20),
            gridStack.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -20),
            gridStack.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -20)
        ])
    }

    private func configureHourlyCard() {
        let titleLabel = makeSectionTitleLabel(text: "По часам")

        hourlyCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.reuseIdentifier)
        hourlyCollectionView.dataSource = self

        hourlyCard.addSubview(titleLabel)
        hourlyCard.addSubview(hourlyCollectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: hourlyCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: hourlyCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: hourlyCard.trailingAnchor, constant: -20),

            hourlyCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: hourlyCard.leadingAnchor, constant: 20),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: hourlyCard.trailingAnchor),
            hourlyCollectionView.bottomAnchor.constraint(equalTo: hourlyCard.bottomAnchor, constant: -20),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 132)
        ])
    }

    private func configureDailyCard() {
        let titleLabel = makeSectionTitleLabel(text: "Прогноз на 3 дня")

        dailyStack.translatesAutoresizingMaskIntoConstraints = false
        dailyStack.axis = .vertical
        dailyStack.spacing = 12

        dailyCard.addSubview(titleLabel)
        dailyCard.addSubview(dailyStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: dailyCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: dailyCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: dailyCard.trailingAnchor, constant: -20),

            dailyStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            dailyStack.leadingAnchor.constraint(equalTo: dailyCard.leadingAnchor, constant: 20),
            dailyStack.trailingAnchor.constraint(equalTo: dailyCard.trailingAnchor, constant: -20),
            dailyStack.bottomAnchor.constraint(equalTo: dailyCard.bottomAnchor, constant: -20)
        ])
    }

    private func configureStateOverlays() {
        configureLoadingOverlay()
        configureErrorOverlay()
        showLoading(preservingContent: false)
    }

    private func configureLoadingOverlay() {
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.16)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        card.layer.cornerRadius = 28
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white

        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.font = .systemFont(ofSize: 17, weight: .medium)
        loadingLabel.textColor = .white
        loadingLabel.text = "Получаем погоду"

        card.addSubview(loadingIndicator)
        card.addSubview(loadingLabel)
        loadingOverlay.addSubview(card)
        view.addSubview(loadingOverlay)

        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: loadingOverlay.leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(lessThanOrEqualTo: loadingOverlay.trailingAnchor, constant: -32),

            loadingIndicator.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            loadingIndicator.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16),
            loadingLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            loadingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            loadingLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
    }

    private func configureErrorOverlay() {
        errorOverlay.translatesAutoresizingMaskIntoConstraints = false
        errorOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.20)
        errorOverlay.isHidden = true

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        card.layer.cornerRadius = 28
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        errorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        errorTitleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        errorTitleLabel.textColor = .white
        errorTitleLabel.textAlignment = .center
        errorTitleLabel.numberOfLines = 0

        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        errorMessageLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.numberOfLines = 0

        card.addSubview(errorTitleLabel)
        card.addSubview(errorMessageLabel)
        card.addSubview(retryButton)
        errorOverlay.addSubview(card)
        view.addSubview(errorOverlay)

        NSLayoutConstraint.activate([
            errorOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            errorOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.centerYAnchor.constraint(equalTo: errorOverlay.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: errorOverlay.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: errorOverlay.trailingAnchor, constant: -24),

            errorTitleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            errorTitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            errorTitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            errorMessageLabel.topAnchor.constraint(equalTo: errorTitleLabel.bottomAnchor, constant: 12),
            errorMessageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            errorMessageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 22),
            retryButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28)
        ])
    }

    private func apply(viewData: WeatherScreenViewData, isRefreshing: Bool) {
        currentViewData = viewData
        hourlyItems = viewData.hourlyItems

        locationLabel.text = viewData.locationText
        metaLabel.text = viewData.metaText
        currentIconView.image = UIImage(systemName: viewData.currentSymbolName)
        temperatureLabel.text = viewData.temperatureText
        conditionLabel.text = viewData.conditionText
        rangeLabel.text = viewData.rangeText

        feelsLikeTile.configure(value: viewData.details.feelsLikeText)
        windTile.configure(value: viewData.details.windText)
        humidityTile.configure(value: viewData.details.humidityText)
        uvTile.configure(value: viewData.details.uvText)

        rebuildDailyForecast(with: viewData.dailyItems)
        hourlyCollectionView.reloadData()

        (view as? GradientBackgroundView)?.applyTheme(isDay: viewData.isDay)
        errorOverlay.isHidden = true
        scrollView.isHidden = false

        if isRefreshing {
            loadingOverlay.isHidden = true
            loadingIndicator.stopAnimating()
            setRefreshing(true)
        } else {
            loadingOverlay.isHidden = true
            loadingIndicator.stopAnimating()
            setRefreshing(false)
        }
    }

    private func apply(errorViewData: WeatherErrorViewData) {
        errorTitleLabel.text = errorViewData.title
        errorMessageLabel.text = errorViewData.message
        updateRetryButtonTitle(errorViewData.buttonTitle)

        currentViewData = nil
        hourlyItems = []

        loadingIndicator.stopAnimating()
        loadingOverlay.isHidden = true
        errorOverlay.isHidden = false
        scrollView.isHidden = true
        setRefreshing(false)
    }

    private func showLoading(preservingContent: Bool) {
        errorOverlay.isHidden = true

        if preservingContent {
            scrollView.isHidden = false
            loadingOverlay.isHidden = true
            setRefreshing(true)
            return
        }

        scrollView.isHidden = true
        loadingOverlay.isHidden = false
        loadingIndicator.startAnimating()
        setRefreshing(false)
    }

    private func setRefreshing(_ isRefreshing: Bool) {
        if isRefreshing {
            refreshIndicator.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshIndicator)
        } else {
            refreshIndicator.stopAnimating()
            navigationItem.rightBarButtonItem = refreshButton
        }
    }

    private func rebuildDailyForecast(with items: [DailyForecastItemViewData]) {
        dailyStack.arrangedSubviews.forEach {
            dailyStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.forEach { item in
            let row = DailyForecastRowView()
            row.configure(with: item)
            dailyStack.addArrangedSubview(row)
        }
    }

    private func makeSectionTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.text = text
        return label
    }

    private func applyCardStyle(to view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        view.layer.cornerRadius = 30
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
    }

    private func updateRetryButtonTitle(_ title: String) {
        var configuration = retryButton.configuration
        configuration?.title = title
        retryButton.configuration = configuration
    }
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hourlyItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyForecastCell.reuseIdentifier,
            for: indexPath
        ) as? HourlyForecastCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: hourlyItems[indexPath.item])
        return cell
    }
}
