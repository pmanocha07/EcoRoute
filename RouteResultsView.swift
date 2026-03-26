import SwiftUI

struct RouteResultsView: View {
    @Bindable var viewModel: RouteViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var navigatingRoute: CommuteRoute?

    var body: some View {
        VStack(spacing: 0) {
            routeHeader

            RouteMapView(
                region: $viewModel.mapRegion,
                startCoordinate: viewModel.startLocation,
                endCoordinate: viewModel.endLocation,
                polylineCoordinates: viewModel.routePolylineCoordinates
            )
            .frame(height: 240)
            .allowsHitTesting(false)

            ScrollView {
                VStack(spacing: 0) {
                    routesFoundHeader.padding(.top, 16)
                    routeCardsList
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $navigatingRoute) { route in
            NavigationStack {
                RouteNavigationView(
                    route: route,
                    from: viewModel.fromText,
                    to: viewModel.toText,
                    polyline: viewModel.routePolylineCoordinates,
                    startCoord: viewModel.startLocation,
                    endCoord: viewModel.endLocation
                )
            }
        }
    }

    // MARK: - Header

    private var routeHeader: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.interactive(), in: .circle)
            }
            .accessibilityLabel("Go back")

            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.fromText) → \(viewModel.toText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("Choose Your Route")
                    .font(.title2.bold())
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var routesFoundHeader: some View {
        HStack {
            Text("\(viewModel.availableRoutes.count) ROUTES FOUND")
                .font(.caption.bold())
                .tracking(1)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Route Cards

    private var routeCardsList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.availableRoutes) { route in
                let isEcoPick = route.id == viewModel.availableRoutes.first?.id
                let isSelected = viewModel.selectedRoute?.id == route.id

                RouteCardView(route: route, isSelected: isSelected, isEcoPick: isEcoPick) {
                    navigatingRoute = route
                }
                .contentShape(Rectangle())
                .onTapGesture { selectRoute(route) }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }

    private func selectRoute(_ route: CommuteRoute) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if reduceMotion {
            viewModel.selectedRoute = route
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                viewModel.selectedRoute = route
            }
        }
    }
}
