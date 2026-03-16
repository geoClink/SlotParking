import Foundation
import CoreLocation

struct Venue: Identifiable, Codable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
}

extension Venue {
    static let sampleVenues: [Venue] = [
        Venue(id: UUID(), name: "Little Caesars Arena", latitude: 42.3417, longitude: -83.0555),
        Venue(id: UUID(), name: "Fox Theatre", latitude: 42.3319, longitude: -83.0456),
        Venue(id: UUID(), name: "Ford Field", latitude: 42.3414, longitude: -83.0457),
        Venue(id: UUID(), name: "Comerica Park", latitude: 42.3390, longitude: -83.0486)
    ]
}
