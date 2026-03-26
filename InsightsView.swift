import SwiftUI
import Charts

struct InsightsView: View {
    @Environment(SettingsManager.self) private var settings

    let months = ["January", "February", "March", "April", "May", "June",
                  "July", "August", "September", "October", "November", "December"]
    @State private var selectedMonth = "February"

    let weeklyCO2: [Double] = [0.35, 0.7, 1.05, 0.6, 1.4, 0.9, 1.2]
    let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let modeUsage: [(String, Color, Double)] = [
        ("Train", .blue, 0.38),
        ("Bus", .orange, 0.22),
        ("Bike", .green, 0.28),
        ("Car", .red, 0.12)
    ]
    let treesSaved = 3
    let treesGoal = 5

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Month picker header
                HStack {
                    Menu {
                        ForEach(months, id: \.self) { month in
                            Button(month) { selectedMonth = month }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(selectedMonth) 2026")
                                .font(.title3.bold())
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.down")
                                .font(.caption.bold())
                                .foregroundStyle(.tertiary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                statGrid
                weeklyCO2Section
                modeUsageSection
                treesSavedSection
                ecoTipSection

                Spacer(minLength: 40)
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Stats Grid

    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(icon: "leaf", iconColor: .green, label: "CO₂ Saved", value: "18.4 kg")
            StatCard(icon: "flame.fill", iconColor: .orange, label: "Eco Streak", value: "7 days 🔥")
            StatCard(icon: "trophy.fill", iconColor: .blue, label: "Eco Trips", value: "24 trips")
            StatCard(icon: "tree", iconColor: .green, label: "Trees Equiv.", value: "3 trees 🌳")
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Weekly CO₂

    private var weeklyCO2Section: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Weekly CO₂ Saved").font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right").font(.caption.bold())
                    Text("+12% vs last week").font(.subheadline.bold())
                }
                .foregroundColor(.green)
            }
            .padding(.horizontal, 4)

            LineChart(data: weeklyCO2, dayLabels: dayLabels)
                .frame(height: 220)
                .padding(16)
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Mode Usage (Swift Charts)

    private var modeUsageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Transport Mode Usage").font(.headline).padding(.horizontal, 4)

            HStack(alignment: .center, spacing: 16) {
                // Native Swift Charts donut
                Chart(modeUsage.indices, id: \.self) { i in
                    let (label, color, value) = modeUsage[i]
                    SectorMark(
                        angle: .value(label, value),
                        innerRadius: .ratio(0.55),
                        angularInset: 2
                    )
                    .foregroundStyle(color)
                    .cornerRadius(4)
                }
                .frame(width: 130, height: 130)

                // Legend
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(modeUsage.indices, id: \.self) { i in
                        let (label, color, percent) = modeUsage[i]
                        HStack(spacing: 8) {
                            Circle().fill(color).frame(width: 12, height: 12)
                            Text(label).font(.subheadline)
                            Spacer(minLength: 8)
                            Text("\(Int(percent * 100))%")
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(16)
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Trees Saved

    private var treesSavedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "tree").foregroundColor(.green)
                Text("Equivalent Trees Saved").font(.headline)
            }

            HStack(spacing: 12) {
                ForEach(0..<treesGoal, id: \.self) { i in
                    VStack(spacing: 6) {
                        Image(systemName: "tree.fill")
                            .font(.largeTitle)
                            .foregroundColor(i < treesSaved ? .green : .gray.opacity(0.25))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i < treesSaved ? Color.green : Color.gray.opacity(0.2))
                            .frame(width: 4, height: 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)

            Text("\(treesSaved) trees").font(.title.bold())
            Text("Your \(selectedMonth.prefix(3)) savings equal planting \(treesSaved) trees, keep it up!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .padding(.horizontal, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.green.opacity(0.2), lineWidth: 1)
                .padding(.horizontal, 20)
        )
    }

    // MARK: - Eco Tip

    private var ecoTipSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "globe.europe.africa.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("EcoRoute").font(.caption.bold()).foregroundColor(.white)
                    Circle().fill(Color.white.opacity(0.7)).frame(width: 8, height: 8)
                }
                Text("Small choices. Big climate impact.")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text("You're in the top 8% of eco commuters this month.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
        }
        .padding(20)
        .background(Color.green.gradient, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(iconColor.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: icon).font(.title2).foregroundColor(iconColor))
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title2.bold())
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
    }
}

// MARK: - Line Chart

struct LineChart: View {
    let data: [Double]
    var dayLabels: [String] = []

    private var yTicks: [Double] {
        guard let maxVal = data.max() else { return [0] }
        let ceil = (maxVal * 10).rounded(.up) / 10
        let step = ceil / 4
        return stride(from: 0, through: ceil, by: step).map { $0 }
    }

    private var chartMax: Double { yTicks.last ?? 1 }

    var body: some View {
        GeometryReader { geo in
            let leftPad: CGFloat = 36
            let bottomPad: CGFloat = 28
            let chartW = geo.size.width - leftPad
            let chartH = geo.size.height - bottomPad

            let points = data.enumerated().map { i, y in
                CGPoint(
                    x: leftPad + chartW * CGFloat(i) / CGFloat(max(data.count - 1, 1)),
                    y: chartH * (1 - CGFloat(y / chartMax))
                )
            }

            ForEach(yTicks.indices, id: \.self) { i in
                let y = chartH * (1 - CGFloat(yTicks[i] / chartMax))
                Path { path in
                    path.move(to: CGPoint(x: leftPad, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
                .stroke(Color.green.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                Text(formatTick(yTicks[i]))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .position(x: leftPad / 2, y: y)
            }

            Path { path in
                guard let first = points.first else { return }
                path.move(to: CGPoint(x: first.x, y: chartH))
                path.addLine(to: first)
                for pt in points.dropFirst() { path.addLine(to: pt) }
                if let last = points.last {
                    path.addLine(to: CGPoint(x: last.x, y: chartH))
                }
                path.closeSubpath()
            }
            .fill(LinearGradient(
                colors: [Color.green.opacity(0.25), Color.green.opacity(0.02)],
                startPoint: .top, endPoint: .bottom
            ))

            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for pt in points.dropFirst() { path.addLine(to: pt) }
            }
            .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

            if let last = points.last {
                Circle().fill(Color.green).frame(width: 8, height: 8).position(last)
            }

            if dayLabels.count == data.count {
                ForEach(dayLabels.indices, id: \.self) { i in
                    let x = leftPad + chartW * CGFloat(i) / CGFloat(max(data.count - 1, 1))
                    Text(dayLabels[i])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .position(x: x, y: chartH + bottomPad / 2)
                }
            }
        }
    }

    private func formatTick(_ val: Double) -> String {
        if val == 0 { return "0" }
        if val == val.rounded() { return String(format: "%.0f", val) }
        return String(format: "%.2g", val)
    }
}
