import SwiftUI
import MapKit

struct PlanRouteCard: View {
    @Bindable var viewModel: RouteViewModel
    var locationManager: LocationManager
    var networkMonitor: NetworkMonitor
    var focusedField: FocusState<HomeView.Field?>.Binding

    @State private var fromCompleter = AddressSearchCompleter()
    @State private var toCompleter = AddressSearchCompleter()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PLAN YOUR ROUTE")
                .font(.caption.bold())
                .tracking(1)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                fromField
                fromSuggestions
                dottedConnector
                toField
                toSuggestions
            }

            if let locError = locationManager.errorMessage {
                errorLabel(locError, color: .orange, icon: "exclamationmark.triangle.fill")
            }
            if let error = viewModel.errorMessage {
                errorLabel(error, color: .red)
            }
        }
        .padding(18)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
        .onChange(of: locationManager.locationName) {
            if let name = locationManager.locationName,
               viewModel.fromText.isEmpty || viewModel.fromText == fromCompleter.query {
                viewModel.fromText = name
                fromCompleter.clear()
            }
        }
    }

    // MARK: - From Field

    private var fromField: some View {
        HStack(spacing: 12) {
            Button { locationManager.requestLocation() } label: {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 40, height: 40)
                    if locationManager.isResolving {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Image(systemName: locationManager.permissionDenied ? "location.slash.fill" : "location.fill")
                            .foregroundColor(locationManager.permissionDenied ? .orange : .green)
                    }
                }
            }
            .accessibilityLabel(locationManager.permissionDenied ? "Location denied, tap to retry" : "Use current location")

            TextField("Current Location", text: $viewModel.fromText)
                .font(.body.weight(.medium))
                .textContentType(.fullStreetAddress)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused(focusedField, equals: .from)
                .onSubmit {
                    fromCompleter.clear()
                    focusedField.wrappedValue = .to
                }
                .onChange(of: viewModel.fromText) {
                    fromCompleter.query = viewModel.fromText
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }

    // MARK: - To Field

    private var toField: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.green)
            }

            TextField("Where to?", text: $viewModel.toText)
                .font(.body.weight(.medium))
                .textContentType(.fullStreetAddress)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .focused(focusedField, equals: .to)
                .onSubmit {
                    toCompleter.clear()
                    focusedField.wrappedValue = nil
                }
                .onChange(of: viewModel.toText) {
                    toCompleter.query = viewModel.toText
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }

    // MARK: - Suggestions

    @ViewBuilder
    private var fromSuggestions: some View {
        if networkMonitor.isConnected && focusedField.wrappedValue == .from && !fromCompleter.suggestions.isEmpty {
            SuggestionsList(suggestions: fromCompleter.suggestions) { completion in
                Task {
                    viewModel.fromText = await fromCompleter.resolve(completion) ?? completion.title
                    fromCompleter.clear()
                    focusedField.wrappedValue = .to
                }
            }
        }
    }

    @ViewBuilder
    private var toSuggestions: some View {
        if networkMonitor.isConnected && focusedField.wrappedValue == .to && !toCompleter.suggestions.isEmpty {
            SuggestionsList(suggestions: toCompleter.suggestions) { completion in
                Task {
                    viewModel.toText = await toCompleter.resolve(completion) ?? completion.title
                    toCompleter.clear()
                    focusedField.wrappedValue = nil
                }
            }
        }
    }

    // MARK: - Subviews

    private var dottedConnector: some View {
        HStack(spacing: 6) {
            Circle().fill(Color(.systemGray4)).frame(width: 4, height: 4)
            Rectangle().fill(Color(.systemGray4)).frame(width: 8, height: 2)
            Circle().fill(Color(.systemGray4)).frame(width: 4, height: 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private func errorLabel(_ text: String, color: Color, icon: String? = nil) -> some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon).foregroundColor(color).font(.caption)
            }
            Text(text).font(.caption).foregroundColor(color)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Suggestions List

struct SuggestionsList: View {
    let suggestions: [MKLocalSearchCompletion]
    let onSelect: (MKLocalSearchCompletion) -> Void

    var body: some View {
        let limited = Array(suggestions.prefix(5))
        VStack(spacing: 0) {
            ForEach(Array(limited.enumerated()), id: \.offset) { index, suggestion in
                Button { onSelect(suggestion) } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.green)
                            .font(.caption)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(suggestion.title)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            if !suggestion.subtitle.isEmpty {
                                Text(suggestion.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Image(systemName: "arrow.up.left")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < limited.count - 1 {
                    Divider().padding(.leading, 48)
                }
            }
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
        .padding(.top, 4)
    }
}
