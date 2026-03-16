import Foundation
import CoreLocation

struct ParkingLot: Identifiable, Codable {
    let id: UUID
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var totalSpots: Int
    var availableSpots: Int
    var pricePerHour: Double

    init(id: UUID = UUID(), name: String, address: String? = nil, latitude: Double, longitude: Double, totalSpots: Int, availableSpots: Int, pricePerHour: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.totalSpots = totalSpots
        self.availableSpots = availableSpots
        self.pricePerHour = pricePerHour
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
