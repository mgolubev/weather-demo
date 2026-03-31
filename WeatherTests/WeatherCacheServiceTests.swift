import XCTest
@testable import Weather

final class WeatherCacheServiceTests: XCTestCase {
    func testSaveAndLoadRoundTripsCachedEntry() async {
        let suiteName = "WeatherCacheServiceTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let service = WeatherCacheService(userDefaults: userDefaults)
        let entry = WeatherTestFixtures.cachedEntry()

        await service.save(entry)
        let loadedEntry = await service.loadLatest()

        XCTAssertEqual(loadedEntry, entry)
    }

    func testLoadLatestReturnsNilAndClearsCorruptedPayload() async {
        let suiteName = "WeatherCacheServiceTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        userDefaults.set(Data("corrupted".utf8), forKey: "weather.latest")
        let service = WeatherCacheService(userDefaults: userDefaults)

        let loadedEntry = await service.loadLatest()

        XCTAssertNil(loadedEntry)
        XCTAssertNil(userDefaults.object(forKey: "weather.latest"))
    }
}
