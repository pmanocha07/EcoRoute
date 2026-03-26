import Foundation
import SwiftUI
import MapKit

// MARK: - Transport Mode

enum TransportMode: String, CaseIterable, Identifiable {
    case car = "Car (Petrol)"
    case ev = "EV (Electric)"
    case bus = "Bus"
    case metro = "Train"
    case bike = "Bike"
    case walk = "Walk"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .car: return "Drive"
        case .ev: return "EV Drive"
        case .bus: return "Bus"
        case .metro: return "Train + Walk"
        case .bike: return "Cycling"
        case .walk: return "Walking"
        }
    }

    var iconName: String {
        switch self {
        case .car: return "car.fill"
        case .ev: return "bolt.car.fill"
        case .bus: return "bus.fill"
        case .metro: return "tram.fill"
        case .bike: return "bicycle"
        case .walk: return "figure.walk"
        }
    }

    var modeColor: Color {
        switch self {
        case .car: return .red
        case .ev: return .purple
        case .bus: return .orange
        case .metro: return .blue
        case .bike: return .green
        case .walk: return .teal
        }
    }

    // kg CO₂ per passenger-km (sources noted per case)
    var emissionFactor: Double {
        switch self {
        case .car:   return 0.170   // OurWorldInData / ICCT — avg single-occupant petrol
        case .ev:    return 0.109   // Grid EF × kWh/km (India grid: 0.727 × 0.15)
        case .bus:   return 0.100   // Typical urban bus aggregate
        case .metro: return 0.035   // OurWorldInData — national rail
        case .bike, .walk: return 0.0
        }
    }

    var emissionSource: String {
        switch self {
        case .car:   return "OurWorldInData / ICCT summary"
        case .ev:    return "Grid EF (India): 0.727 kg/kWh × 0.15 kWh/km"
        case .bus:   return "Typical aggregated urban figures"
        case .metro: return "OurWorldInData – national rail"
        case .bike, .walk: return "Zero tailpipe emissions"
        }
    }

    var emissionFactorDisplay: String {
        emissionFactor == 0 ? "0 g/km" : "\(Int(emissionFactor * 1000)) g/km"
    }

    // Cost per km in ₹
    var costPerKm: Double {
        switch self {
        case .car:   return 8.0
        case .ev:    return 2.0
        case .bus:   return 1.5
        case .metro: return 3.0
        case .bike, .walk: return 0.0
        }
    }

    // Route-distance multiplier per mode (bus takes a longer path than cycling, etc.)
    var distanceFactor: Double {
        switch self {
        case .car:   return 1.2
        case .ev:    return 1.2
        case .bus:   return 1.15
        case .metro: return 1.05
        case .bike:  return 0.85
        case .walk:  return 0.80
        }
    }

    // Average travel speed (km/h) for time estimation
    var averageSpeedKmh: Double {
        switch self {
        case .car:   return 40
        case .ev:    return 40
        case .bus:   return 20
        case .metro: return 35
        case .bike:  return 15
        case .walk:  return 5
        }
    }

    // Extra overhead minutes (wait times, transfers)
    var overheadMinutes: Int {
        switch self {
        case .car, .ev: return 5
        case .bus:      return 10
        case .metro:    return 8
        case .bike:     return 2
        case .walk:     return 0
        }
    }
}

// MARK: - Commute Route

struct CommuteRoute: Identifiable {
    let id = UUID()
    let mode: TransportMode
    let distanceInKm: Double
    let estimatedTimeMinutes: Int

    var formattedTime: String {
        guard estimatedTimeMinutes >= 60 else { return "\(estimatedTimeMinutes) min" }
        let totalHrs = estimatedTimeMinutes / 60
        let mins = estimatedTimeMinutes % 60
        if totalHrs >= 24 {
            let days = totalHrs / 24
            let hrs = totalHrs % 24
            if hrs > 0 {
                return "\(days)d \(hrs)h"
            }
            return "\(days) day\(days > 1 ? "s" : "")"
        }
        return mins == 0 ? "\(totalHrs) hr" : "\(totalHrs)h \(mins)m"
    }

    var carbonEmission: Double { distanceInKm * mode.emissionFactor }
    var costEstimate: Double   { distanceInKm * mode.costPerKm }

    var costString: String {
        costEstimate == 0 ? "Free" : String(format: "₹%.0f", costEstimate)
    }

    var emissionString: String {
        carbonEmission == 0 ? "Zero" : String(format: "%.2fkg", carbonEmission)
    }

    var emissionLevelString: String {
        if carbonEmission == 0  { return "Zero Emission" }
        if carbonEmission < 1.0 { return "Low Emission" }
        return "High Emission"
    }

    var emissionColor: Color {
        if carbonEmission == 0  { return .green }
        if carbonEmission < 1.0 { return .yellow }
        return .red
    }

    func accessibilityDescription(isRecommended: Bool) -> String {
        let rec = isRecommended ? "Eco recommended route. " : ""
        return "\(rec)\(mode.rawValue). \(formattedTime). CO₂: \(String(format: "%.2f", carbonEmission)) kg. \(emissionLevelString)."
    }
}
