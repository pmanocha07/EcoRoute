import SwiftUI

struct SettingsView: View {
    @Environment(SettingsManager.self) private var settings

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings").font(.system(size: 34, weight: .bold))
                    Text("Personalise your EcoRoute experience")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

                profileCard

                // Appearance
                settingsSection(title: "APPEARANCE") {
                    SettingsToggleRow(
                        icon: "sun.max.fill", iconColor: .orange,
                        title: "Dark Mode",
                        subtitle: settings.darkMode ? "Dark theme enabled" : "Light theme enabled",
                        isOn: $settings.darkMode
                    )
                }

                // Accessibility
                settingsSection(title: "ACCESSIBILITY") {
                    VStack(spacing: 0) {
                        SettingsToggleRow(
                            icon: "textformat.size", iconColor: .blue,
                            title: "Larger Text",
                            subtitle: "Increase text size throughout app",
                            isOn: $settings.largerText
                        )
                        Divider().padding(.leading, 60)
                        SettingsToggleRow(
                            icon: "circle.lefthalf.filled", iconColor: .red.opacity(0.8),
                            title: "High Contrast",
                            subtitle: "Enhance visual distinction",
                            isOn: $settings.highContrast
                        )
                        Divider().padding(.leading, 60)
                        SettingsToggleRow(
                            icon: "bolt.slash.fill", iconColor: .red,
                            title: "Reduce Motion",
                            subtitle: "Minimise animations",
                            isOn: $settings.reduceMotion
                        )
                    }
                }

                // Data & Science
                settingsSection(title: "DATA & SCIENCE") {
                    NavigationLink(destination: EmissionInfoView()) {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(Color.green.opacity(0.12))
                                .frame(width: 44, height: 44)
                                .overlay(Image(systemName: "atom").foregroundColor(.green))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("How We Calculate").font(.body.bold())
                                Text("Emission factors, costs & sources").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
                        }
                        .padding(16)
                    }
                    .buttonStyle(.plain)
                }

                // About
                settingsSection(title: "ABOUT") {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "info.circle.fill").font(.title3).foregroundStyle(.secondary))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("EcoRoute").font(.body.bold())
                            Text("Version 1.0").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("v1.0").font(.subheadline.bold()).foregroundStyle(.secondary)
                    }
                    .padding(16)
                }

                Spacer(minLength: 40)
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.green)
                .frame(width: 56, height: 56)
                .overlay(Text("PM").font(.system(size: 20, weight: .bold)).foregroundColor(.white))

            VStack(alignment: .leading, spacing: 3) {
                Text("Pavni Manocha").font(.headline)
                Text("pmanocha553@gmail.com").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "leaf.arrow.triangle.circlepath").font(.caption2)
                    Text("Eco Commuter · Level 7").font(.caption.bold())
                }
                .foregroundColor(.green)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.green.opacity(0.2), lineWidth: 1))
        .padding(.horizontal, 20)
    }

    // MARK: - Section Builder

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.bold())
                .tracking(1)
                .foregroundStyle(.secondary)
                .padding(.leading, 24)

            content()
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(iconColor.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: icon).foregroundColor(iconColor))

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn).labelsHidden().tint(.green)
        }
        .padding(16)
    }
}
