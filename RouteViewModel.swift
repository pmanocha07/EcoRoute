import Foundation
import SwiftUI
@preconcurrency import MapKit
import CoreLocation
import Observation

enum GeocodingError: LocalizedError {
    case notFound(address: String)

    var errorDescription: String? {
        switch self {
        case .notFound(let address):
            return "Could not find location for \"\(address)\"."
        }
    }
}

// MARK: - Route View Model

@MainActor
@Observable
final class RouteViewModel {
    var fromText = ""
    var toText = ""

    var startLocation: CLLocationCoordinate2D
    var endLocation: CLLocationCoordinate2D
    var mapRegion: MKCoordinateRegion
    var routePolylineCoordinates: [CLLocationCoordinate2D] = []

    var isLoading = false
    var errorMessage: String?
    var isOfflineRoute = false

    var availableRoutes: [CommuteRoute] = []
    var selectedRoute: CommuteRoute?
    var selectedModes: Set<TransportMode> = Set(TransportMode.allCases)
    var lastSearchedDestination: String?

    private var lastDistanceKm: Double = 0

    init() {
        let center = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
        startLocation = center
        endLocation = CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0307)
        mapRegion = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    // MARK: - Public

    func geocodeAndRoute(isOnline: Bool = true, currentLocation: CLLocation? = nil) {
        guard !fromText.trimmingCharacters(in: .whitespaces).isEmpty,
              !toText.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter both a start and destination address."
            return
        }
        isLoading = true
        errorMessage = nil
        lastSearchedDestination = toText
        routePolylineCoordinates = []
        availableRoutes = []
        selectedRoute = nil
        isOfflineRoute = false

        if isOnline {
            geocodeOnline()
        } else {
            geocodeOffline(currentLocation: currentLocation)
        }
    }

    func routeFromDemo(_ demo: DemoRoute) {
        fromText = demo.from
        toText = demo.to
        startLocation = demo.fromCoordinate
        endLocation = demo.toCoordinate
        errorMessage = nil
        isOfflineRoute = true
        routePolylineCoordinates = demo.cachedPolyline
        fitMapToPoints(demo.fromCoordinate, demo.toCoordinate)
        calculateRoutes(distanceKm: demo.distanceKm)
    }

    func toggleMode(_ mode: TransportMode) {
        if selectedModes.contains(mode) {
            guard selectedModes.count > 1 else { return }
            selectedModes.remove(mode)
        } else {
            selectedModes.insert(mode)
        }
        if lastDistanceKm > 0 {
            calculateRoutes(distanceKm: lastDistanceKm)
        }
    }

    // MARK: - Online Geocoding

    private func geocodeOnline() {
        Task {
            do {
                guard let fromRequest = MKGeocodingRequest(addressString: fromText) else {
                    throw GeocodingError.notFound(address: fromText)
                }
                let fromResults = try await fromRequest.mapItems
                guard let fromItem = fromResults.first else {
                    throw GeocodingError.notFound(address: fromText)
                }
                let fromCoord = fromItem.location.coordinate

                guard let toRequest = MKGeocodingRequest(addressString: toText) else {
                    throw GeocodingError.notFound(address: toText)
                }
                let toResults = try await toRequest.mapItems
                guard let toItem = toResults.first else {
                    throw GeocodingError.notFound(address: toText)
                }
                let toCoord = toItem.location.coordinate

                startLocation = fromCoord
                endLocation = toCoord

                let distanceKm = CLLocation(latitude: fromCoord.latitude, longitude: fromCoord.longitude)
                    .distance(from: CLLocation(latitude: toCoord.latitude, longitude: toCoord.longitude)) / 1000.0

                await fetchDirectionsPolyline(from: fromCoord, to: toCoord)
                calculateRoutes(distanceKm: distanceKm)
                isLoading = false
            } catch let error as GeocodingError {
                errorMessage = error.localizedDescription
                isLoading = false
            } catch {
                errorMessage = "Could not find route. Please check addresses."
                isLoading = false
            }
        }
    }

    // MARK: - Offline Fallback

    private func geocodeOffline(currentLocation: CLLocation?) {
        isOfflineRoute = true
        guard let currentLoc = currentLocation else {
            errorMessage = "Offline: GPS location unavailable. Please enable location services."
            isLoading = false
            return
        }
        let fromCoord = currentLoc.coordinate
        startLocation = fromCoord
        let toCoord = endLocation
        let distanceKm = max(
            CLLocation(latitude: fromCoord.latitude, longitude: fromCoord.longitude)
                .distance(from: CLLocation(latitude: toCoord.latitude, longitude: toCoord.longitude)) / 1000.0,
            1.0
        )
        routePolylineCoordinates = [fromCoord, toCoord]
        fitMapToPoints(fromCoord, toCoord)
        calculateRoutes(distanceKm: distanceKm)
        isLoading = false
    }

    // MARK: - Directions Polyline

    private func fetchDirectionsPolyline(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async {
        do {
            let request = MKDirections.Request()
            request.source = MKMapItem(
                location: CLLocation(latitude: from.latitude, longitude: from.longitude),
                address: nil
            )
            request.destination = MKMapItem(
                location: CLLocation(latitude: to.latitude, longitude: to.longitude),
                address: nil
            )
            request.transportType = .automobile

            let response = try await MKDirections(request: request).calculate()

            if let route = response.routes.first {
                let polyline = route.polyline
                var coords = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: polyline.pointCount)
                polyline.getCoordinates(&coords, range: NSRange(location: 0, length: polyline.pointCount))
                routePolylineCoordinates = coords
                let rect = polyline.boundingMapRect
                mapRegion = MKCoordinateRegion(rect.insetBy(dx: -rect.size.width * 0.2, dy: -rect.size.height * 0.2))
            } else {
                routePolylineCoordinates = [from, to]
                fitMapToPoints(from, to)
            }
        } catch {
            routePolylineCoordinates = [from, to]
            fitMapToPoints(from, to)
        }
    }

    // MARK: - Route Calculation

    func calculateRoutes(distanceKm: Double) {
        lastDistanceKm = distanceKm
        let mapped: [CommuteRoute] = selectedModes.map { mode in
            let d = distanceKm * mode.distanceFactor
            let t = Int((d / mode.averageSpeedKmh) * 60) + mode.overheadMinutes
            return CommuteRoute(mode: mode, distanceInKm: d, estimatedTimeMinutes: max(1, t))
        }
        let routes = mapped.sorted { a, b in
            if a.carbonEmission == b.carbonEmission {
                return a.estimatedTimeMinutes < b.estimatedTimeMinutes
            }
            return a.carbonEmission < b.carbonEmission
        }
        availableRoutes = routes
        if let sel = selectedRoute, routes.contains(where: { $0.id == sel.id }) {
            // keep current selection
        } else {
            selectedRoute = routes.first
        }
    }

    // MARK: - Helpers

    private func fitMapToPoints(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) {
        let midLat = (a.latitude + b.latitude) / 2
        let midLon = (a.longitude + b.longitude) / 2
        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
            span: MKCoordinateSpan(
                latitudeDelta: max(abs(a.latitude - b.latitude) * 1.5, 0.01),
                longitudeDelta: max(abs(a.longitude - b.longitude) * 1.5, 0.01)
            )
        )
    }
}
