import SwiftUI
import MapKit

struct RouteMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var startCoordinate: CLLocationCoordinate2D
    var endCoordinate: CLLocationCoordinate2D
    var polylineCoordinates: [CLLocationCoordinate2D]

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.isUserInteractionEnabled = false
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        let startPin = MKPointAnnotation()
        startPin.coordinate = startCoordinate
        startPin.title = "Start"

        let endPin = MKPointAnnotation()
        endPin.coordinate = endCoordinate
        endPin.title = "Destination"

        mapView.addAnnotations([startPin, endPin])

        if polylineCoordinates.count >= 2 {
            var coords = polylineCoordinates
            mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemGreen
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let point = annotation as? MKPointAnnotation else { return nil }
            let id = "RoutePin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.annotation = annotation
            view.canShowCallout = true
            if point.title == "Start" {
                view.markerTintColor = .systemGreen
                view.glyphImage = UIImage(systemName: "circle.fill")
            } else {
                view.markerTintColor = .systemRed
                view.glyphImage = UIImage(systemName: "mappin")
            }
            return view
        }
    }
}
