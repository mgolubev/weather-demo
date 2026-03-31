import UIKit

@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let viewModel = WeatherViewModel(
            locationProvider: LocationService(),
            weatherService: WeatherAPIClient(),
            cacheService: WeatherCacheService(),
            mapper: WeatherViewDataMapper()
        )

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = WeatherNavigationController(
            rootViewController: WeatherViewController(viewModel: viewModel)
        )
        window.makeKeyAndVisible()
        self.window = window
    }
}
