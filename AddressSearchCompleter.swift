import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class AddressSearchCompleter {
    var query = "" {
        didSet {
            if query.isEmpty {
                suggestions = []
            } else {
                delegate?.completer.queryFragment = query
            }
        }
    }
    var suggestions: [MKLocalSearchCompletion] = []
    var isSearching = false

    private var delegate: CompleterDelegate?

    init() {
        let del = CompleterDelegate()
        self.delegate = del
        del.owner = self
    }

    func resolve(_ completion: MKLocalSearchCompletion) async -> String? {
        let search = MKLocalSearch(request: MKLocalSearch.Request(completion: completion))
        do {
            let response = try await search.start()
            if let item = response.mapItems.first {
                if let formatted = item.addressRepresentations?.fullAddress(includingRegion: false, singleLine: true) {
                    return formatted
                }
                if let name = item.name { return name }
            }
        } catch {}
        return [completion.title, completion.subtitle].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    func clear() {
        query = ""
        suggestions = []
    }

    fileprivate func handleResults(_ results: [MKLocalSearchCompletion]) {
        suggestions = results
        isSearching = false
    }

    fileprivate func handleError() {
        suggestions = []
        isSearching = false
    }
}

// MARK: - Search Completer Delegate

private class CompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    let completer = MKLocalSearchCompleter()
    weak var owner: AddressSearchCompleter?

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results
        let box = SendableBox(results)
        let owner = owner
        Task { @MainActor in owner?.handleResults(box.value) }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        let owner = owner
        Task { @MainActor in owner?.handleError() }
    }
}

private final class SendableBox<T>: @unchecked Sendable {
    let value: T
    init(_ value: T) { self.value = value }
}
