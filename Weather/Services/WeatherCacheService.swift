import Foundation

protocol WeatherCaching {
    func loadLatest() async -> CachedWeatherEntry?
    func save(_ entry: CachedWeatherEntry) async
}

actor WeatherCacheService: WeatherCaching {
    private enum Storage {
        static let cacheKey = "weather.latest"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        encoder.dateEncodingStrategy = .millisecondsSince1970
        decoder.dateDecodingStrategy = .millisecondsSince1970
    }

    func loadLatest() async -> CachedWeatherEntry? {
        guard let data = userDefaults.data(forKey: Storage.cacheKey) else {
            return nil
        }

        do {
            return try decoder.decode(CachedWeatherEntry.self, from: data)
        } catch {
            userDefaults.removeObject(forKey: Storage.cacheKey)
            return nil
        }
    }

    func save(_ entry: CachedWeatherEntry) async {
        do {
            let data = try encoder.encode(entry)
            userDefaults.set(data, forKey: Storage.cacheKey)
        } catch {
            return
        }
    }
}
