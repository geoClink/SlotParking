import SwiftUI
import MapKit
import UIKit

struct MapKitView: UIViewRepresentable {
    var lots: [ParkingLot]
    @Binding var selectedLot: ParkingLot?
    var centerCoordinate: CLLocationCoordinate2D?
    var fitToAnnotations: Bool = true

    class LotAnnotation: MKPointAnnotation {
        let lotId: UUID
        var availableSpots: Int

        init(lot: ParkingLot) {
            self.lotId = lot.id
            self.availableSpots = lot.availableSpots
            super.init()
            self.title = lot.name
            self.subtitle = lot.id.uuidString
            self.coordinate = lot.coordinate
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .includingAll
        mapView.mapType = .standard
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let existing = uiView.annotations.filter { $0 is LotAnnotation }
        uiView.removeAnnotations(existing)

        for lot in lots {
            let anno = LotAnnotation(lot: lot)
            uiView.addAnnotation(anno)
        }

        if fitToAnnotations && !uiView.annotations.isEmpty {
            var zoomRect = MKMapRect.null
            for annotation in uiView.annotations {
                let point = MKMapPoint(annotation.coordinate)
                let rect = MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1)
                zoomRect = zoomRect.union(rect)
            }
            let edgePadding = UIEdgeInsets(top: 60, left: 40, bottom: 200, right: 40)
            uiView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: true)
        } else if let center = centerCoordinate {
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            uiView.setRegion(region, animated: true)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitView
        init(_ parent: MapKitView) { self.parent = parent; super.init() }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            if let lotAnno = annotation as? LotAnnotation {
                let id = "lot"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: lotAnno, reuseIdentifier: id)
                    view?.canShowCallout = true
                    view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                } else { view?.annotation = lotAnno }
                let spotsText = String(lotAnno.availableSpots)
                view?.glyphText = spotsText.count <= 3 ? spotsText : nil
                view?.glyphTintColor = UIColor.white
                view?.markerTintColor = UIColor.systemBlue
                return view
            }
            return nil
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? LotAnnotation, let id = annotation.subtitle else { return }
            if let uuid = UUID(uuidString: id), let lot = parent.lots.first(where: { $0.id == uuid }) {
                // light haptic when selecting annotation
                Haptics.lightImpact()
                DispatchQueue.main.async { [weak self] in self?.parent.selectedLot = lot }
            }
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation as? LotAnnotation, let id = annotation.subtitle else { return }
            if let uuid = UUID(uuidString: id), let lot = parent.lots.first(where: { $0.id == uuid }) {
                DispatchQueue.main.async { [weak self] in self?.parent.selectedLot = lot }
            }
        }
    }
}
