import Foundation
import CoreLocation
@preconcurrency import MapKit
import Observation

@MainActor
@Observable
final class LocationManager {
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationName: String?
    var isResolving = false
    var permissionDenied = false
    var errorMessage: String?

    private var delegate: LocationDelegate?

    init() {
        let del = LocationDelegate()
        self.delegate = del
        del.owner = self
        Task { @MainActor [weak self] in
            self?.requestLocationOnLaunch()
        }
    }

    // MARK: - Public

    func requestLocation() {
        guard let delegate else { return }
        errorMessage = nil
        isResolving = true
        switch delegate.manager.authorizationStatus {
        case .notDetermined:
            delegate.manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            delegate.manager.requestLocation()
        case .denied, .restricted:
            isResolving = false
            permissionDenied = true
            errorMessage = "Location permission denied. Go to Settings → Privacy → Location Services to enable."
        @unknown default:
            isResolving = false
        }
    }

    // MARK: - Private

    private func requestLocationOnLaunch() {
        guard let delegate else { return }
        authorizationStatus = delegate.manager.authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
            delegate.manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isResolving = true
            delegate.manager.requestLocation()
        case .denied, .restricted:
            permissionDenied = true
            errorMessage = "Location access denied. Tap to enter manually."
        @unknown default:
            break
        }
    }

    fileprivate func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        authorizationStatus = status
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionDenied = false
            errorMessage = nil
            isResolving = true
            delegate?.manager.requestLocation()
        case .denied, .restricted:
            isResolving = false
            permissionDenied = true
            errorMessage = "Location permission denied. Go to Settings → Privacy → Location Services to enable."
        default:
            break
        }
    }

    fileprivate func handleLocation(_ location: CLLocation) {
        currentLocation = location
        reverseGeocode(location)
    }

    fileprivate func handleError(_ error: Error) {
        isResolving = false
        if let clError = error as? CLError, clError.code == .denied {
            permissionDenied = true
            errorMessage = "Location permission denied. Go to Settings → Privacy → Location Services to enable."
        } else {
            errorMessage = "Could not determine your location. Please try again."
        }
    }

    private func reverseGeocode(_ location: CLLocation) {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            locationName = formatCoordinate(location.coordinate)
            isResolving = false
            return
        }
        Task {
            do {
                let items = try await request.mapItems
                if let item = items.first {
                    let parts = [item.name, item.addressRepresentations?.cityName].compactMap { $0 }
                    locationName = parts.isEmpty ? formatCoordinate(location.coordinate) : parts.joined(separator: ", ")
                } else {
                    locationName = formatCoordinate(location.coordinate)
                }
            } catch {
                locationName = formatCoordinate(location.coordinate)
            }
            isResolving = false
        }
    }

    private func formatCoordinate(_ c: CLLocationCoordinate2D) -> String {
        String(format: "%.4f, %.4f", c.latitude, c.longitude)
    }
}

// MARK: - Core Location Delegate

private class LocationDelegate: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    weak var owner: LocationManager?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        let owner = owner
        Task { @MainActor in owner?.handleAuthorizationChange(status) }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let owner = owner
        Task { @MainActor in owner?.handleLocation(location) }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let owner = owner
        Task { @MainActor in owner?.handleError(error) }
    }
}
