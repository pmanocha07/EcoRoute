import SwiftUI

struct AccessibleRouteListView: View {
    var viewModel: RouteViewModel

    var body: some View {
        List {
            Section("Available Routes") {
                ForEach(viewModel.availableRoutes) { route in
                    let isRecommended = route.id == viewModel.availableRoutes.first?.id
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(route.mode.displayName) – \(route.formattedTime)")
                            .font(.headline)
                        Text("\(String(format: "%.1f", route.distanceInKm)) km · \(route.emissionString) CO₂ · \(route.costString)")
                            .font(.subheadline)
                        if isRecommended {
                            Text("Eco Recommended 🌱")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 5)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(route.accessibilityDescription(isRecommended: isRecommended))
                    .accessibilityAddTraits(viewModel.selectedRoute?.id == route.id ? .isSelected : [])
                }
            }
        }
    }
}
