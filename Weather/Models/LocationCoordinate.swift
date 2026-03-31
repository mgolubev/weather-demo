import Foundation

struct LocationCoordinate: Hashable, Sendable {
    let latitude: Double
    let longitude: Double

    static let moscow = LocationCoordinate(latitude: 55.7558, longitude: 37.6176)
}

enum FallbackReason: Hashable, Sendable {
    case permissionDenied
    case permissionRestricted
}

enum LocationSource: Hashable, Sendable {
    case device
    case fallback(reason: FallbackReason)

    var noticeText: String? {
        switch self {
        case .device:
            return nil
        case .fallback(.permissionDenied):
            return "Показываем Москву, пока геопозиция отключена."
        case .fallback(.permissionRestricted):
            return "Показываем Москву, пока геопозиция недоступна."
        }
    }
}

struct ResolvedLocation: Hashable, Sendable {
    let coordinate: LocationCoordinate
    let source: LocationSource

    static func fallback(reason: FallbackReason) -> ResolvedLocation {
        ResolvedLocation(coordinate: .moscow, source: .fallback(reason: reason))
    }
}
