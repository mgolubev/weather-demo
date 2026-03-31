import UIKit

final class WeatherScreenView: GradientBackgroundView {
    var onRetry: (() -> Void)? {
        get { errorOverlayView.onRetry }
        set { errorOverlayView.onRetry = newValue }
    }

    var onPullToRefresh: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let refreshControl = UIRefreshControl()

    private let heroSectionView = WeatherHeroSectionView()
    private let detailsSectionView = WeatherDetailsSectionView()
    private let hourlySectionView = HourlyForecastSectionView()
    private let dailySectionView = DailyForecastSectionView()

    private let loadingOverlayView = WeatherLoadingOverlayView()
    private let errorOverlayView = WeatherErrorOverlayView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        render(state: .loading)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func render(state: WeatherViewState) {
        switch state {
        case .loading:
            showLoading(preservingContent: false)
            refreshControl.endRefreshing()
        case let .content(viewData):
            apply(viewData: viewData)
            refreshControl.endRefreshing()
        case let .refreshing(viewData):
            apply(viewData: viewData, isRefreshing: true)
        case let .error(errorViewData):
            apply(errorViewData: errorViewData)
            refreshControl.endRefreshing()
        }
    }

    private func configureHierarchy() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.refreshControl = refreshControl

        refreshControl.tintColor = .white
        refreshControl.addAction(
            UIAction { [weak self] _ in
                self?.onPullToRefresh?()
            },
            for: .valueChanged
        )

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 40, right: 20)

        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        [heroSectionView, detailsSectionView, hourlySectionView, dailySectionView].forEach {
            contentStack.addArrangedSubview($0)
        }

        addSubview(loadingOverlayView)
        addSubview(errorOverlayView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            loadingOverlayView.topAnchor.constraint(equalTo: topAnchor),
            loadingOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            errorOverlayView.topAnchor.constraint(equalTo: topAnchor),
            errorOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func apply(viewData: WeatherScreenViewData, isRefreshing: Bool = false) {
        heroSectionView.configure(with: viewData.hero)
        detailsSectionView.configure(with: viewData.details)
        hourlySectionView.setItems(viewData.hourlyItems)
        dailySectionView.setItems(viewData.dailyItems)

        applyTheme(isDay: viewData.isDay)
        scrollView.isHidden = false
        errorOverlayView.setVisible(false)
        loadingOverlayView.setVisible(false)

        if !isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    private func apply(errorViewData: WeatherErrorViewData) {
        errorOverlayView.configure(with: errorViewData)
        loadingOverlayView.setVisible(false)
        errorOverlayView.setVisible(true)
        scrollView.isHidden = true
        refreshControl.endRefreshing()
    }

    private func showLoading(preservingContent: Bool) {
        errorOverlayView.setVisible(false)

        if preservingContent {
            scrollView.isHidden = false
            loadingOverlayView.setVisible(false)
            return
        }

        scrollView.isHidden = true
        loadingOverlayView.setVisible(true)
        refreshControl.endRefreshing()
    }
}
