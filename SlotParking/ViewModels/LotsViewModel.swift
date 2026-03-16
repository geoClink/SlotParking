import Foundation
import Combine
import CoreLocation

final class LotsViewModel: ObservableObject {
    @Published private(set) var lots: [ParkingLot] = []
    @Published var venues: [Venue] = Venue.sampleVenues

    private var service: LotsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(service: LotsServiceProtocol? = nil) {
        #if canImport(FirebaseFirestore)
        if let svc = service {
            self.service = svc
        } else {
            self.service = FirebaseLotsService()
        }
        #else
        self.service = service ?? MockLotsService()
        #endif
        fetchLots()
    }

    func fetchLots() {
        service.fetchLots()
            .receive(on: RunLoop.main)
            .sink { [weak self] lots in
                self?.lots = lots
            }
            .store(in: &cancellables)
    }

    func distance(from lot: ParkingLot, to venue: Venue) -> Double {
        let loc1 = CLLocation(latitude: lot.latitude, longitude: lot.longitude)
        let loc2 = CLLocation(latitude: venue.latitude, longitude: venue.longitude)
        return loc1.distance(from: loc2) // meters
    }

    func nearestVenueDistanceString(for lot: ParkingLot) -> String {
        guard let nearest = venues.min(by: { distance(from: lot, to: $0) < distance(from: lot, to: $1) }) else { return "—" }
        let meters = distance(from: lot, to: nearest)
        if meters >= 1000 {
            return String(format: "%.1f km to %@", meters / 1000, nearest.name)
        } else {
            return String(format: "%.0f m to %@", meters, nearest.name)
        }
    }

    func updateAvailableSpots(lotId: UUID, delta: Int) {
        service.updateAvailableSpots(lotId: lotId, delta: delta)
            .receive(on: RunLoop.main)
            .sink { [weak self] updated in
                guard let self = self else { return }
                if let index = self.lots.firstIndex(where: { $0.id == updated.id }) {
                    self.lots[index] = updated
                } else {
                    self.lots.append(updated)
                }
            }
            .store(in: &cancellables)
    }
}
