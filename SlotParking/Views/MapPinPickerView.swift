import SwiftUI
import MapKit

struct MapPinPickerView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D?
    var showsUserLocation: Bool = true

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(gesture)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        if let coord = coordinate {
            let anno = MKPointAnnotation()
            anno.coordinate = coord
            uiView.addAnnotation(anno)
            let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            uiView.setRegion(region, animated: true)
        } else if let user = uiView.userLocation.location {
            let region = MKCoordinateRegion(center: user.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            uiView.setRegion(region, animated: false)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapPinPickerView
        init(_ parent: MapPinPickerView) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)
            DispatchQueue.main.async { self.parent.coordinate = coord }
        }
    }
}

#Preview {
    MapPinPickerView(coordinate: .constant(CLLocationCoordinate2D(latitude: 42.3417, longitude: -83.0555)))
}
