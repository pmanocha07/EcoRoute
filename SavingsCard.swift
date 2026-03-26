import SwiftUI

struct SavingsCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: [.green.opacity(0.8), .green.opacity(0.5), .mint.opacity(0.4)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))

            // Decorative background circles
            Circle().fill(.white.opacity(0.12)).blur(radius: 2).frame(width: 180, height: 180).offset(x: 80, y: -40)
            Circle().fill(.white.opacity(0.08)).blur(radius: 3).frame(width: 120, height: 120).offset(x: 100, y: 50)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.arrow.triangle.circlepath").font(.caption.bold())
                        Text("TODAY'S SAVINGS").font(.caption.bold()).tracking(1)
                    }
                    .foregroundColor(.white.opacity(0.9))

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("1.4").font(.system(size: 52, weight: .bold))
                        Text("kg CO₂").font(.title3.weight(.medium))
                    }
                    .foregroundColor(.white)

                    Text("vs. driving today")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 10) {
                    BadgePill(emoji: "🌳", text: "2 trees/month")
                    BadgePill(emoji: "🔥", text: "7 day streak")
                }
            }
            .padding(20)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .green.opacity(0.3), radius: 16, y: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today's savings: 1.4 kilograms CO₂ versus driving. 2 trees per month equivalent. 7 day streak.")
    }
}

struct BadgePill: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
            Text(text).font(.caption.bold())
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
    }
}
