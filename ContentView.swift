import SwiftUI

struct ContentView: View {
    @State private var settings = SettingsManager()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar.fill") }
                .tag(1)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(2)
        }
        .tint(.green)
        .environment(settings)
        .environment(\.sizeCategory, settings.largerText ? .extraExtraLarge : .large)
        .contrast(settings.highContrast ? 1.3 : 1.0)
        .preferredColorScheme(settings.darkMode ? .dark : .light)
    }
}
