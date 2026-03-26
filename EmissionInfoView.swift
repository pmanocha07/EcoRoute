import SwiftUI

struct EmissionInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("How We Calculate Emissions")
                    .font(.title2.bold())
                    .padding(.top, 8)

                Text("EcoRoute estimates carbon emissions for each transport mode using published emission factors (grams of CO₂ per passenger-kilometre). Here's how it works.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Emission Factors
                sectionCard(title: "Emission Factors", icon: "leaf.arrow.triangle.circlepath") {
                    ForEach(TransportMode.allCases) { mode in
                        HStack(spacing: 12) {
                            Image(systemName: mode.iconName)
                                .foregroundColor(mode.modeColor)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.rawValue).font(.subheadline.bold())
                                Text(mode.emissionSource)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(mode.emissionFactorDisplay)
                                .font(.subheadline.bold())
                                .foregroundColor(mode.emissionFactor == 0 ? .green : .primary)
                        }
                        .padding(.vertical, 6)
                        if mode.id != TransportMode.allCases.last?.id {
                            Divider()
                        }
                    }
                }

                // How distance works
                sectionCard(title: "Distance Estimation", icon: "point.topleft.down.to.point.bottomright.curvepath") {
                    Text("Each mode uses a distance multiplier to reflect real-world route differences. For example, buses follow longer routes than cyclists who can take shortcuts.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        ForEach(TransportMode.allCases) { mode in
                            HStack {
                                Text(mode.displayName).font(.caption)
                                Spacer()
                                Text("×\(String(format: "%.2f", mode.distanceFactor))")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                // Cost estimation
                sectionCard(title: "Cost Estimation", icon: "dollarsign.circle") {
                    Text("Trip costs are estimated using average per-km rates for each mode in India.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        ForEach(TransportMode.allCases) { mode in
                            HStack {
                                Text(mode.displayName).font(.caption)
                                Spacer()
                                Text(mode.costPerKm == 0 ? "Free" : String(format: "₹%.1f/km", mode.costPerKm))
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                // Time estimation
                sectionCard(title: "Time Estimation", icon: "clock") {
                    Text("Travel time is calculated from average speeds plus overhead for waiting, transfers, and parking.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        ForEach(TransportMode.allCases) { mode in
                            HStack {
                                Text(mode.displayName).font(.caption)
                                Spacer()
                                Text("\(Int(mode.averageSpeedKmh)) km/h + \(mode.overheadMinutes) min")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                // Sources
                sectionCard(title: "Sources", icon: "book.closed") {
                    VStack(alignment: .leading, spacing: 6) {
                        sourceRow("OurWorldInData – CO₂ emissions by transport")
                        sourceRow("ICCT – Passenger vehicle emission factors")
                        sourceRow("IEA – Grid emission factors by country")
                    }
                }

                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundColor(.green)
                Text(title).font(.headline)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }

    private func sourceRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Circle().fill(Color.green).frame(width: 6, height: 6)
            Text(text).font(.caption).foregroundStyle(.secondary)
        }
    }
}
