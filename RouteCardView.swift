import SwiftUI

struct RouteCardView: View {
    let route: CommuteRoute
    let isSelected: Bool
    let isEcoPick: Bool
    var onStart: () -> Void = {}

    var body: some View {
        VStack(spacing: 14) {
            cardHeader
            greenDotDivider

            if isSelected {
                statsRow
                emissionSourceInfo
                startButton
            }
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    isSelected ? Color.green.opacity(0.6) : (isEcoPick ? Color.green.opacity(0.3) : .clear),
                    lineWidth: isSelected ? 2 : (isEcoPick ? 1.5 : 0)
                )
        )
        .shadow(color: isSelected ? Color.green.opacity(0.2) : .clear, radius: 12, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(route.accessibilityDescription(isRecommended: isEcoPick))
        .accessibilityHint("Double tap to select this route.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Header

    private var cardHeader: some View {
        HStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 12)
                .fill(route.mode.modeColor.opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: route.mode.iconName)
                        .font(.title3)
                        .foregroundColor(route.mode.modeColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(route.mode.displayName).font(.headline)
                Text(String(format: "%.1f km", route.distanceInKm))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                if isEcoPick { EcoPickBadge() }
                CO2Pill(emissionColor: route.emissionColor)
            }
        }
    }

    private var greenDotDivider: some View {
        HStack(spacing: 0) {
            Rectangle().fill(Color(.separator).opacity(0.5)).frame(height: 1)
            Circle()
                .fill(Color.green)
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 2))
                .shadow(color: Color.green.opacity(0.3), radius: 3)
            Rectangle().fill(Color(.separator).opacity(0.5)).frame(height: 1)
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 8) {
            StatColumn(icon: "clock", value: route.formattedTime, label: "Time")
                .glassEffect(.regular, in: .rect(cornerRadius: 10))

            StatColumn(icon: "leaf.arrow.triangle.circlepath", value: route.emissionString, label: "CO₂", valueColor: route.emissionColor)
                .background(RoundedRectangle(cornerRadius: 10).fill(route.emissionColor.opacity(0.08)))

            StatColumn(icon: "dollarsign.circle", value: route.costString, label: "Cost")
                .glassEffect(.regular, in: .rect(cornerRadius: 10))
        }
    }

    private var emissionSourceInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "info.circle.fill").font(.caption2).foregroundColor(.blue)
                Text("EF: \(route.mode.emissionFactorDisplay)")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
            Text(route.mode.emissionSource)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 8))
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button(action: onStart) {
            HStack {
                Spacer()
                Image(systemName: "location.fill").font(.subheadline.bold())
                Text("Start").font(.subheadline.bold())
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .shadow(color: Color.green.opacity(0.3), radius: 6, y: 3)
        }
    }
}

// MARK: - Badges & Pills

struct EcoPickBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill").font(.caption2)
            Text("ECO PICK").font(.caption2.bold()).tracking(0.5)
        }
        .foregroundColor(.green)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .glassEffect(.regular, in: .capsule)
    }
}

struct CO2Pill: View {
    let emissionColor: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(emissionColor).frame(width: 8, height: 8)
            Text("CO₂").font(.caption2.bold()).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .glassEffect(.regular, in: .capsule)
    }
}

// MARK: - Stat Column

struct StatColumn: View {
    let icon: String
    let value: String
    let label: String
    var valueColor: Color = .primary

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.callout).foregroundStyle(.secondary)
            Text(value).font(.subheadline.bold()).foregroundColor(valueColor)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}
