import SwiftUI

@MainActor
struct HomeView: View {
    @State private var viewModel = RouteViewModel()
    @State private var locationManager = LocationManager()
    @State private var networkMonitor = NetworkMonitor()
    @Environment(SettingsManager.self) private var settings
    @FocusState private var focusedField: Field?
    @State private var showRouteResults = false

    enum Field { case from, to }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case ..<12: return "Good morning"
        case ..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var canSearch: Bool {
        !viewModel.fromText.trimmingCharacters(in: .whitespaces).isEmpty
        && !viewModel.toText.trimmingCharacters(in: .whitespaces).isEmpty
        && !viewModel.isLoading
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    SavingsCard()
                    demoRouteSection
                    PlanRouteCard(
                        viewModel: viewModel,
                        locationManager: locationManager,
                        networkMonitor: networkMonitor,
                        focusedField: $focusedField
                    )
                    findEcoRouteButton
                    quickDestinations
                    brandingFooter
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showRouteResults) {
                RouteResultsView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(greeting)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("🌿")
                }
                Text("Pavni Manocha")
                    .font(.system(size: 28, weight: .bold))
            }
            Spacer()
            Circle()
                .fill(Color.green)
                .frame(width: 44, height: 44)
                .overlay(
                    Text("PM")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
                .accessibilityHidden(true)
        }
        .padding(.top, 8)
    }

    // MARK: - Demo Routes

    private var demoRouteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "map.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                Text("TRY A DEMO ROUTE")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(demoRoutes) { demo in
                        Button {
                            viewModel.routeFromDemo(demo)
                            showRouteResults = true
                        } label: {
                            VStack(spacing: 6) {
                                Text(demo.emoji).font(.title2)
                                Text(demo.name)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Text("\(String(format: "%.1f", demo.distanceKm)) km")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 88)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 4)
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(demo.name): \(demo.from) to \(demo.to), \(String(format: "%.1f", demo.distanceKm)) km")
                    }
                }
            }
        }
    }

    // MARK: - Quick Destinations

    private var quickDestinations: some View {
        let recentPlace = viewModel.lastSearchedDestination ?? "Connaught Place"
        return HStack(spacing: 12) {
            QuickDestinationCard(icon: "house.fill", title: "Home", subtitle: "Vasant Kunj") {
                viewModel.toText = "Vasant Kunj"
            }
            QuickDestinationCard(icon: "building.2.fill", title: "Work", subtitle: "Cyber City, Gurugram") {
                viewModel.toText = "Cyber City, Gurugram"
            }
            QuickDestinationCard(icon: "clock.fill", title: "Recent", subtitle: recentPlace) {
                viewModel.toText = recentPlace
            }
        }
    }

    // MARK: - Find Route Button

    private var findEcoRouteButton: some View {
        Button {
            focusedField = nil
            viewModel.geocodeAndRoute(
                isOnline: networkMonitor.isConnected,
                currentLocation: locationManager.currentLocation
            )
            showRouteResults = true
        } label: {
            HStack(spacing: 10) {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "magnifyingglass").font(.body.bold())
                }
                Text(viewModel.isLoading ? "Finding Route…" : "Find Eco Route")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(
                        colors: [.green, .green.opacity(0.8), .mint.opacity(0.7)],
                        startPoint: .leading, endPoint: .trailing
                    ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
            )
            .shadow(color: .green.opacity(0.35), radius: 12, y: 5)
        }
        .disabled(!canSearch)
        .opacity(canSearch ? 1.0 : 0.5)
        .accessibilityLabel("Find eco-friendly route")
    }

    // MARK: - Footer

    private var brandingFooter: some View {
        HStack(spacing: 6) {
            Image(systemName: "leaf.circle.fill").foregroundColor(.green)
            Text("Seeded by Pavni Manocha")
                .font(.subheadline.bold())
                .foregroundColor(.green)
        }
        .padding(.top, 4)
    }
}
