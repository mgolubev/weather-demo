import UIKit

private enum WeatherScreenSection: Int, CaseIterable, Sendable {
    case hero
    case details
    case hourly
    case daily

    var title: String? {
        switch self {
        case .hero, .details:
            return nil
        case .hourly:
            return "По часам"
        case .daily:
            return "Прогноз на 3 дня"
        }
    }
}

private enum WeatherScreenLayout {
    static let horizontalInset: CGFloat = 20
    static let sectionBottomSpacing: CGFloat = 18
    static let screenBottomInset: CGFloat = 40
    static let headerEstimatedHeight: CGFloat = 48
}

final class WeatherScreenView: GradientBackgroundView {
    private enum RenderedItem: Hashable {
        case hero(WeatherHeroViewData)
        case details(WeatherDetailsViewData)
        case hourly(HourlyForecastItemViewData)
        case daily(DailyForecastItemViewData)
    }

    var onRetry: (() -> Void)? {
        get { errorOverlayView.onRetry }
        set { errorOverlayView.onRetry = newValue }
    }

    var onPullToRefresh: (() -> Void)?

    private let refreshControl = UIRefreshControl()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.refreshControl = refreshControl
        collectionView.register(
            WeatherHeroCollectionViewCell.self,
            forCellWithReuseIdentifier: WeatherHeroCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            WeatherDetailsCollectionViewCell.self,
            forCellWithReuseIdentifier: WeatherDetailsCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            HourlyForecastCell.self,
            forCellWithReuseIdentifier: HourlyForecastCell.reuseIdentifier
        )
        collectionView.register(
            DailyForecastCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyForecastCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            WeatherSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: WeatherSectionHeaderView.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var dataSource = makeDataSource()
    private var renderedItems: [String: RenderedItem] = [:]
    private var lastViewData: WeatherScreenViewData?

    private let loadingOverlayView = WeatherLoadingOverlayView()
    private let errorOverlayView = WeatherErrorOverlayView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureRefreshControl()
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
        addSubview(collectionView)
        addSubview(loadingOverlayView)
        addSubview(errorOverlayView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

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

    private func configureRefreshControl() {
        refreshControl.tintColor = .white
        refreshControl.addAction(
            UIAction { [weak self] _ in
                self?.onPullToRefresh?()
            },
            for: .valueChanged
        )
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self, let section = WeatherScreenSection(rawValue: sectionIndex) else {
                return nil
            }

            return self.layoutSection(for: section)
        }
    }

    private func layoutSection(for section: WeatherScreenSection) -> NSCollectionLayoutSection {
        switch section {
        case .hero:
            return makeFullWidthSection(
                estimatedHeight: 340,
                contentInsets: NSDirectionalEdgeInsets(
                    top: 24,
                    leading: WeatherScreenLayout.horizontalInset,
                    bottom: WeatherScreenLayout.sectionBottomSpacing,
                    trailing: WeatherScreenLayout.horizontalInset
                )
            )
        case .details:
            return makeFullWidthSection(
                estimatedHeight: 240,
                contentInsets: NSDirectionalEdgeInsets(
                    top: 0,
                    leading: WeatherScreenLayout.horizontalInset,
                    bottom: WeatherScreenLayout.sectionBottomSpacing,
                    trailing: WeatherScreenLayout.horizontalInset
                )
            )
        case .hourly:
            return makeHourlySection()
        case .daily:
            return makeDailySection()
        }
    }

    private func makeFullWidthSection(
        estimatedHeight: CGFloat,
        contentInsets: NSDirectionalEdgeInsets
    ) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = contentInsets
        return section
    }

    private func makeHourlySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(92),
            heightDimension: .absolute(132)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: WeatherScreenLayout.horizontalInset,
            bottom: WeatherScreenLayout.sectionBottomSpacing,
            trailing: WeatherScreenLayout.horizontalInset
        )
        section.boundarySupplementaryItems = [makeSectionHeader()]
        return section
    }

    private func makeDailySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(88)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: WeatherScreenLayout.horizontalInset,
            bottom: WeatherScreenLayout.screenBottomInset,
            trailing: WeatherScreenLayout.horizontalInset
        )
        section.boundarySupplementaryItems = [makeSectionHeader()]
        return section
    }

    private func makeSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(WeatherScreenLayout.headerEstimatedHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: WeatherScreenLayout.horizontalInset,
            bottom: 0,
            trailing: WeatherScreenLayout.horizontalInset
        )
        return header
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, String> {
        let dataSource = UICollectionViewDiffableDataSource<Int, String>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, identifier in
            guard let self, let item = renderedItems[identifier] else {
                return UICollectionViewCell()
            }

            switch item {
                case let .hero(viewData):
                    guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: WeatherHeroCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? WeatherHeroCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: viewData)
                return cell

            case let .details(viewData):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: WeatherDetailsCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? WeatherDetailsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: viewData)
                return cell

            case let .hourly(viewData):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HourlyForecastCell.reuseIdentifier,
                    for: indexPath
                ) as? HourlyForecastCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: viewData)
                return cell

            case let .daily(viewData):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DailyForecastCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? DailyForecastCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: viewData)
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let section = WeatherScreenSection(rawValue: indexPath.section),
                  let title = section.title,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: WeatherSectionHeaderView.reuseIdentifier,
                    for: indexPath
                  ) as? WeatherSectionHeaderView else {
                return nil
            }

            header.configure(title: title)
            return header
        }

        return dataSource
    }

    private func apply(viewData: WeatherScreenViewData, isRefreshing: Bool = false) {
        if lastViewData == viewData {
            finishRendering(viewData: viewData, isRefreshing: isRefreshing)
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        var newRenderedItems: [String: RenderedItem] = [:]

        let sectionIdentifiers = WeatherScreenSection.allCases.map(\.rawValue)
        snapshot.appendSections(sectionIdentifiers)

        let heroIdentifier = "hero"
        newRenderedItems[heroIdentifier] = .hero(viewData.hero)
        snapshot.appendItems([heroIdentifier], toSection: WeatherScreenSection.hero.rawValue)

        let detailsIdentifier = "details"
        newRenderedItems[detailsIdentifier] = .details(viewData.details)
        snapshot.appendItems([detailsIdentifier], toSection: WeatherScreenSection.details.rawValue)

        let hourlyIdentifiers = viewData.hourlyItems.enumerated().map { index, item -> String in
            let identifier = "hourly-\(index)"
            newRenderedItems[identifier] = .hourly(item)
            return identifier
        }
        snapshot.appendItems(hourlyIdentifiers, toSection: WeatherScreenSection.hourly.rawValue)

        let dailyIdentifiers = viewData.dailyItems.enumerated().map { index, item -> String in
            let identifier = "daily-\(index)"
            newRenderedItems[identifier] = .daily(item)
            return identifier
        }
        snapshot.appendItems(dailyIdentifiers, toSection: WeatherScreenSection.daily.rawValue)

        let previousRenderedItems = renderedItems
        let changedIdentifiers = newRenderedItems.compactMap { identifier, item in
            previousRenderedItems[identifier] == item ? nil : identifier
        }
        let persistedIdentifiers = Set(previousRenderedItems.keys)
        let identifiersToReload = changedIdentifiers.filter { persistedIdentifiers.contains($0) }

        if !identifiersToReload.isEmpty {
            snapshot.reloadItems(identifiersToReload)
        }

        self.renderedItems = newRenderedItems
        dataSource.apply(snapshot, animatingDifferences: false)
        lastViewData = viewData

        finishRendering(viewData: viewData, isRefreshing: isRefreshing)
    }

    private func apply(errorViewData: WeatherErrorViewData) {
        errorOverlayView.configure(with: errorViewData)
        loadingOverlayView.setVisible(false)
        errorOverlayView.setVisible(true)
        collectionView.isHidden = lastViewData == nil
        refreshControl.endRefreshing()
    }

    private func showLoading(preservingContent: Bool) {
        errorOverlayView.setVisible(false)

        if preservingContent {
            collectionView.isHidden = false
            loadingOverlayView.setVisible(false)
            return
        }

        collectionView.isHidden = true
        loadingOverlayView.setVisible(true)
        refreshControl.endRefreshing()
    }

    private func finishRendering(viewData: WeatherScreenViewData, isRefreshing: Bool) {
        applyTheme(isDay: viewData.isDay)
        collectionView.isHidden = false
        errorOverlayView.setVisible(false)
        loadingOverlayView.setVisible(false)

        if !isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}
