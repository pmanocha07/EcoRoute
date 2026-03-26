import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsManager {
    var darkMode = false
    var largerText = false
    var highContrast = false
    var reduceMotion = false
}
