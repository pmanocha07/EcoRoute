import SwiftUI
import MapKit

// MARK: - Direction Step

struct DirectionStep: Identifiable {
    let id = UUID()
    let icon: String
    let instruction: String
    let detail: String
    let distance: String
}

// MARK: - Route Navigation Screen

struct RouteNavigationView: View {
    let route: CommuteRoute
    let from: String
    let to: String
    let polyline: [CLLocationCoordinate2D]
    let startCoord: CLLocationCoordinate2D
    let endCoord: CLLocationCoordinate2D

    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var currentStepIndex = 0
    @State private var tripStarted = false

    init(route: CommuteRoute, from: String, to: String, polyline: [CLLocationCoordinate2D], startCoord: CLLocationCoordinate2D, endCoord: CLLocationCoordinate2D) {
        self.route = route
        self.from = from
        self.to = to
        self.polyline = polyline
        self.startCoord = startCoord
        self.endCoord = endCoord

        let midLat = (startCoord.latitude + endCoord.latitude) / 2
        let midLon = (startCoord.longitude + endCoord.longitude) / 2
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
            span: MKCoordinateSpan(
                latitudeDelta: max(abs(startCoord.latitude - endCoord.latitude) * 1.6, 0.01),
                longitudeDelta: max(abs(startCoord.longitude - endCoord.longitude) * 1.6, 0.01)
            )
        ))
    }

    private var steps: [DirectionStep] {
        generateSteps(for: route.mode, distance: route.distanceInKm, from: from, to: to)
    }

    var body: some View {
        VStack(spacing: 0) {
            navHeader
            mapSection
            currentDirectionBanner
            stepsList
            bottomBar
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var navHeader: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .glassEffect(.regular.interactive(), in: .circle)
            }
            .accessibilityLabel("Close navigation")

            VStack(alignment: .leading, spacing: 2) {
                Text(route.mode.displayName)
                    .font(.headline)
                Text("\(from) → \(to)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Mode icon badge
            Image(systemName: route.mode.iconName)
                .font(.title3)
                .foregroundColor(route.mode.modeColor)
                .frame(width: 40, height: 40)
                .glassEffect(.regular, in: .circle)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    // MARK: - Map

    private var mapSection: some View {
        RouteMapView(
            region: $region,
            startCoordinate: startCoord,
            endCoordinate: endCoord,
            polylineCoordinates: polyline
        )
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    // MARK: - Current Direction Banner

    private var currentDirectionBanner: some View {
        let step = steps[currentStepIndex]
        return HStack(spacing: 14) {
            Image(systemName: step.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color.green, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(step.instruction)
                    .font(.subheadline.bold())
                    .lineLimit(2)
                Text(step.distance)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(currentStepIndex + 1)/\(steps.count)")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassEffect(.regular, in: .capsule)
        }
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Steps List

    private var stepsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    HStack(spacing: 14) {
                        // Step indicator
                        VStack(spacing: 0) {
                            if index > 0 {
                                Rectangle()
                                    .fill(index <= currentStepIndex ? Color.green : Color(.systemGray4))
                                    .frame(width: 2)
                            }
                            ZStack {
                                Circle()
                                    .fill(index <= currentStepIndex ? Color.green : Color(.systemGray4))
                                    .frame(width: 28, height: 28)
                                if index < currentStepIndex {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                } else if index == currentStepIndex {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 10, height: 10)
                                } else {
                                    Text("\(index + 1)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                }
                            }
                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(index < currentStepIndex ? Color.green : Color(.systemGray4))
                                    .frame(width: 2)
                            }
                        }
                        .frame(width: 28)

                        // Step content
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: step.icon)
                                    .font(.callout)
                                    .foregroundColor(index == currentStepIndex ? .green : .secondary)
                                Text(step.instruction)
                                    .font(.subheadline)
                                    .fontWeight(index == currentStepIndex ? .semibold : .regular)
                            }
                            HStack(spacing: 12) {
                                Text(step.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(step.distance)
                                    .font(.caption.bold())
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 12)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation { currentStepIndex = index }
                    }

                    if index < steps.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 16) {
            // Route summary pills
            HStack(spacing: 8) {
                summaryPill(icon: "clock", text: route.formattedTime)
                summaryPill(icon: "leaf", text: route.emissionString)
                summaryPill(icon: "wallet.bifold", text: route.costString)
            }

            Spacer()

            // Next step / End button
            if currentStepIndex < steps.count - 1 {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentStepIndex += 1
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("Next").font(.subheadline.bold())
                        Image(systemName: "arrow.right").font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.green, in: Capsule())
                }
            } else {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "flag.checkered").font(.caption.bold())
                        Text("Done").font(.subheadline.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.green, in: Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .rect(cornerRadius: 0))
    }

    private func summaryPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(text).font(.caption2.bold())
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .glassEffect(.regular, in: .capsule)
    }
}

// MARK: - Step Generation

private func generateSteps(for mode: TransportMode, distance: Double, from: String, to: String) -> [DirectionStep] {
    switch mode {
    case .car, .ev:
        return [
            DirectionStep(icon: "car.fill", instruction: "Head out from \(from)", detail: "Start your trip", distance: "0 km"),
            DirectionStep(icon: "arrow.turn.up.right", instruction: "Take the main road heading east", detail: "Follow signs for the highway", distance: String(format: "%.1f km", distance * 0.15)),
            DirectionStep(icon: "road.lanes", instruction: "Merge onto the expressway", detail: "Stay in the middle lane", distance: String(format: "%.1f km", distance * 0.3)),
            DirectionStep(icon: "arrow.triangle.branch", instruction: "Take the exit towards \(to)", detail: "Move to the left lane", distance: String(format: "%.1f km", distance * 0.7)),
            DirectionStep(icon: "arrow.turn.down.right", instruction: "Turn right at the signal", detail: "After the flyover", distance: String(format: "%.1f km", distance * 0.85)),
            DirectionStep(icon: "mappin.and.ellipse", instruction: "Arrive at \(to)", detail: "Your destination is on the left", distance: String(format: "%.1f km", distance))
        ]
    case .bus:
        return [
            DirectionStep(icon: "figure.walk", instruction: "Walk to the nearest bus stop", detail: "From \(from)", distance: "200 m"),
            DirectionStep(icon: "bus.fill", instruction: "Board the bus", detail: "Check the route number on the display", distance: "0 km"),
            DirectionStep(icon: "arrow.right", instruction: "Stay on the bus", detail: "Approximately \(Int(distance * 0.6)) stops", distance: String(format: "%.1f km", distance * 0.6)),
            DirectionStep(icon: "bell.fill", instruction: "Ring the bell for your stop", detail: "Near \(to)", distance: String(format: "%.1f km", distance * 0.9)),
            DirectionStep(icon: "figure.walk", instruction: "Walk to your destination", detail: "Short walk from the bus stop", distance: "300 m"),
            DirectionStep(icon: "mappin.and.ellipse", instruction: "Arrive at \(to)", detail: "You've reached your destination", distance: String(format: "%.1f km", distance))
        ]
    case .metro:
        return [
            DirectionStep(icon: "figure.walk", instruction: "Walk to the nearest metro station", detail: "From \(from)", distance: "400 m"),
            DirectionStep(icon: "creditcard.fill", instruction: "Tap your metro card at the gate", detail: "Enter the station", distance: "—"),
            DirectionStep(icon: "tram.fill", instruction: "Board the train", detail: "Check the platform display for direction", distance: "0 km"),
            DirectionStep(icon: "arrow.right", instruction: "Travel \(max(1, Int(distance / 1.5))) stations", detail: "Stay seated or hold the rail", distance: String(format: "%.1f km", distance * 0.8)),
            DirectionStep(icon: "figure.walk", instruction: "Exit the station and walk", detail: "Follow signs to \(to)", distance: "350 m"),
            DirectionStep(icon: "mappin.and.ellipse", instruction: "Arrive at \(to)", detail: "You've reached your destination", distance: String(format: "%.1f km", distance))
        ]
    case .bike:
        return [
            DirectionStep(icon: "bicycle", instruction: "Start cycling from \(from)", detail: "Head towards the main road", distance: "0 km"),
            DirectionStep(icon: "arrow.turn.up.right", instruction: "Take the cycle lane heading east", detail: "Stay in the designated path", distance: String(format: "%.1f km", distance * 0.2)),
            DirectionStep(icon: "arrow.right", instruction: "Continue straight", detail: "Through the residential area", distance: String(format: "%.1f km", distance * 0.5)),
            DirectionStep(icon: "arrow.turn.down.left", instruction: "Turn left at the roundabout", detail: "Follow signs for \(to)", distance: String(format: "%.1f km", distance * 0.8)),
            DirectionStep(icon: "mappin.and.ellipse", instruction: "Arrive at \(to)", detail: "Lock your bike securely", distance: String(format: "%.1f km", distance))
        ]
    case .walk:
        return [
            DirectionStep(icon: "figure.walk", instruction: "Start walking from \(from)", detail: "Head north on the main path", distance: "0 km"),
            DirectionStep(icon: "arrow.turn.up.right", instruction: "Turn right at the intersection", detail: "Cross at the pedestrian signal", distance: String(format: "%.1f km", distance * 0.25)),
            DirectionStep(icon: "arrow.right", instruction: "Continue along the footpath", detail: "Pass through the park area", distance: String(format: "%.1f km", distance * 0.55)),
            DirectionStep(icon: "arrow.turn.down.left", instruction: "Turn left after the market", detail: "Your destination is ahead", distance: String(format: "%.1f km", distance * 0.85)),
            DirectionStep(icon: "mappin.and.ellipse", instruction: "Arrive at \(to)", detail: "You've reached your destination", distance: String(format: "%.1f km", distance))
        ]
    }
}
