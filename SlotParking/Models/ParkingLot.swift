import Foundation
import CoreLocation

struct ParkingLot: Identifiable, Codable {
    let id: UUID
    var ownerId: String?
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var totalSpots: Int
    var availableSpots: Int
    var pricePerHour: Double
    var status: String

    init(id: UUID = UUID(), ownerId: String? = nil, name: String, address: String? = nil, latitude: Double, longitude: Double, totalSpots: Int, availableSpots: Int, pricePerHour: Double, status: String = "approved") {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.totalSpots = totalSpots
        self.availableSpots = availableSpots
        self.pricePerHour = pricePerHour
        self.status = status
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
