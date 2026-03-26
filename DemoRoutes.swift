import Foundation
import CoreLocation

struct DemoRoute: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let from: String
    let to: String
    let fromCoordinate: CLLocationCoordinate2D
    let toCoordinate: CLLocationCoordinate2D
    let distanceKm: Double
    let cachedPolyline: [CLLocationCoordinate2D]
}

private func coord(_ lat: Double, _ lon: Double) -> CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: lat, longitude: lon)
}

// MARK: - Preset Demo Routes

let demoRoutes: [DemoRoute] = [
    DemoRoute(
        name: "London Commute",
        emoji: "🇬🇧",
        from: "Victoria Station",
        to: "Shoreditch High St",
        fromCoordinate: coord(51.4952, -0.1441),
        toCoordinate: coord(51.5233, -0.0755),
        distanceKm: 8.2,
        cachedPolyline: [
            coord(51.4952, -0.1441),
            coord(51.4990, -0.1385),
            coord(51.5010, -0.1340),
            coord(51.5035, -0.1280),
            coord(51.5055, -0.1220),
            coord(51.5075, -0.1165),
            coord(51.5098, -0.1110),
            coord(51.5120, -0.1050),
            coord(51.5145, -0.0990),
            coord(51.5165, -0.0930),
            coord(51.5185, -0.0870),
            coord(51.5200, -0.0820),
            coord(51.5218, -0.0785),
            coord(51.5233, -0.0755)
        ]
    ),
    DemoRoute(
        name: "NYC Crosstown",
        emoji: "🗽",
        from: "Penn Station",
        to: "Grand Central",
        fromCoordinate: coord(40.7506, -73.9935),
        toCoordinate: coord(40.7527, -73.9772),
        distanceKm: 2.4,
        cachedPolyline: [
            coord(40.7506, -73.9935),
            coord(40.7510, -73.9910),
            coord(40.7513, -73.9885),
            coord(40.7516, -73.9860),
            coord(40.7518, -73.9840),
            coord(40.7520, -73.9820),
            coord(40.7523, -73.9800),
            coord(40.7527, -73.9772)
        ]
    ),
    DemoRoute(
        name: "Paris Ride",
        emoji: "🇫🇷",
        from: "Eiffel Tower",
        to: "Louvre Museum",
        fromCoordinate: coord(48.8584, 2.2945),
        toCoordinate: coord(48.8606, 2.3376),
        distanceKm: 4.1,
        cachedPolyline: [
            coord(48.8584, 2.2945),
            coord(48.8590, 2.2990),
            coord(48.8600, 2.3030),
            coord(48.8610, 2.3080),
            coord(48.8618, 2.3120),
            coord(48.8620, 2.3160),
            coord(48.8615, 2.3210),
            coord(48.8610, 2.3260),
            coord(48.8607, 2.3310),
            coord(48.8606, 2.3376)
        ]
    ),
    DemoRoute(
        name: "Tokyo Sprint",
        emoji: "🇯🇵",
        from: "Shibuya Station",
        to: "Tokyo Station",
        fromCoordinate: coord(35.6580, 139.7016),
        toCoordinate: coord(35.6812, 139.7671),
        distanceKm: 7.5,
        cachedPolyline: [
            coord(35.6580, 139.7016),
            coord(35.6600, 139.7080),
            coord(35.6625, 139.7140),
            coord(35.6650, 139.7200),
            coord(35.6680, 139.7260),
            coord(35.6700, 139.7320),
            coord(35.6720, 139.7390),
            coord(35.6745, 139.7450),
            coord(35.6770, 139.7520),
            coord(35.6790, 139.7580),
            coord(35.6800, 139.7630),
            coord(35.6812, 139.7671)
        ]
    ),
    DemoRoute(
        name: "Delhi Metro",
        emoji: "🇮🇳",
        from: "Connaught Place",
        to: "India Gate",
        fromCoordinate: coord(28.6315, 77.2167),
        toCoordinate: coord(28.6129, 77.2295),
        distanceKm: 3.0,
        cachedPolyline: [
            coord(28.6315, 77.2167),
            coord(28.6290, 77.2180),
            coord(28.6265, 77.2200),
            coord(28.6240, 77.2220),
            coord(28.6215, 77.2240),
            coord(28.6190, 77.2260),
            coord(28.6160, 77.2280),
            coord(28.6129, 77.2295)
        ]
    ),
    DemoRoute(
        name: "SF Bay Trip",
        emoji: "🌉",
        from: "Ferry Building",
        to: "Golden Gate Park",
        fromCoordinate: coord(37.7955, -122.3937),
        toCoordinate: coord(37.7694, -122.4862),
        distanceKm: 9.8,
        cachedPolyline: [
            coord(37.7955, -122.3937),
            coord(37.7945, -122.4000),
            coord(37.7935, -122.4060),
            coord(37.7920, -122.4120),
            coord(37.7905, -122.4190),
            coord(37.7880, -122.4260),
            coord(37.7855, -122.4340),
            coord(37.7830, -122.4410),
            coord(37.7800, -122.4490),
            coord(37.7770, -122.4570),
            coord(37.7740, -122.4650),
            coord(37.7720, -122.4730),
            coord(37.7700, -122.4800),
            coord(37.7694, -122.4862)
        ]
    )
]
