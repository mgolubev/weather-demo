import CoreLocation
import Foundation

protocol LocationProviding {
    func requestCoordinates() async throws -> ResolvedLocation
}

enum LocationServiceError: LocalizedError {
    case authorizationUnresolved
    case failedToDetermineLocation

    var errorDescription: String? {
        switch self {
        case .authorizationUnresolved:
            return "Не удалось получить актуальный статус доступа к геопозиции."
        case .failedToDetermineLocation:
            return "Не удалось определить текущее местоположение. Попробуйте ещё раз."
        }
    }
}

final class LocationService: NSObject, CLLocationManagerDelegate, LocationProviding {
    private let locationManager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<LocationCoordinate, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestCoordinates() async throws -> ResolvedLocation {
        switch await resolveAuthorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            let coordinate = try await requestCurrentLocation()
            return ResolvedLocation(coordinate: coordinate, source: .device)
        case .denied:
            return .fallback(reason: .permissionDenied)
        case .restricted:
            return .fallback(reason: .permissionRestricted)
        case .notDetermined:
            throw LocationServiceError.authorizationUnresolved
        @unknown default:
            throw LocationServiceError.authorizationUnresolved
        }
    }

    private func resolveAuthorizationStatus() async -> CLAuthorizationStatus {
        let status = locationManager.authorizationStatus
        guard status == .notDetermined else {
            return status
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func requestCurrentLocation() async throws -> LocationCoordinate {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if let authorizationContinuation, manager.authorizationStatus != .notDetermined {
            authorizationContinuation.resume(returning: manager.authorizationStatus)
            self.authorizationContinuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = freshestCoordinate(in: locations) else {
            finishLocation(with: LocationServiceError.failedToDetermineLocation)
            return
        }

        finishLocation(with: coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishLocation(with: LocationServiceError.failedToDetermineLocation)
    }

    private func finishLocation(with coordinate: LocationCoordinate) {
        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }

    private func finishLocation(with error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }

    private func freshestCoordinate(in locations: [CLLocation]) -> LocationCoordinate? {
        let latestLocation = locations
            .filter { $0.horizontalAccuracy >= 0 }
            .max { lhs, rhs in
                lhs.timestamp < rhs.timestamp
            }

        guard let latestLocation else {
            return nil
        }

        return LocationCoordinate(
            latitude: latestLocation.coordinate.latitude,
            longitude: latestLocation.coordinate.longitude
        )
    }
}
