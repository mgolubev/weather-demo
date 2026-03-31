import CoreLocation
import Foundation

protocol LocationProviding {
    func requestCoordinates() async -> LocationCoordinate
}

final class LocationService: NSObject, CLLocationManagerDelegate, LocationProviding {
    private let locationManager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<LocationCoordinate, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestCoordinates() async -> LocationCoordinate {
        switch await resolveAuthorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return await requestCurrentLocation()
        case .denied, .restricted:
            return .moscow
        case .notDetermined:
            return .moscow
        @unknown default:
            return .moscow
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

    private func requestCurrentLocation() async -> LocationCoordinate {
        await withCheckedContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if let authorizationContinuation {
            authorizationContinuation.resume(returning: manager.authorizationStatus)
            self.authorizationContinuation = nil
        }

        switch manager.authorizationStatus {
        case .denied, .restricted:
            finishLocation(with: .moscow)
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            break
        @unknown default:
            finishLocation(with: .moscow)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else {
            finishLocation(with: .moscow)
            return
        }

        finishLocation(with: LocationCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishLocation(with: .moscow)
    }

    private func finishLocation(with coordinate: LocationCoordinate) {
        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }
}
