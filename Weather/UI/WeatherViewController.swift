import UIKit

@MainActor
final class WeatherViewController: UIViewController {
    private let viewModel: WeatherViewModel
    private lazy var screenView = WeatherScreenView()

    private lazy var refreshButton = UIBarButtonItem(
        systemItem: .refresh,
        primaryAction: UIAction { [weak self] _ in
            self?.viewModel.refreshTapped()
        }
    )

    private let refreshIndicator = UIActivityIndicatorView(style: .medium)

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        bindViewModel()
        screenView.onRetry = { [weak self] in
            self?.viewModel.retryTapped()
        }
        screenView.onPullToRefresh = { [weak self] in
            self?.viewModel.refreshTapped()
        }
        viewModel.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state: state)
        }
    }

    private func render(state: WeatherViewState) {
        screenView.render(state: state)

        switch state {
        case .refreshing:
            setRefreshing(true)
        case .loading, .content, .error:
            setRefreshing(false)
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

    private func setRefreshing(_ isRefreshing: Bool) {
        if isRefreshing {
            refreshIndicator.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshIndicator)
        } else {
            refreshIndicator.stopAnimating()
            navigationItem.rightBarButtonItem = refreshButton
        }
    }
}
