import Foundation
import Combine
import CoreLocation

final class LotsViewModel: ObservableObject {
    @Published private(set) var lots: [ParkingLot] = []
    @Published var venues: [Venue] = Venue.sampleVenues
    @Published var isLoading: Bool = false

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
        isLoading = true
        // If dev admin server configured, prefer fetching approved lots from it so admin web approvals appear in-app during dev.
        if let base = ADMIN_SERVER_BASE_URL, let url = URL(string: base + "/lots") {
            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: [ParkingLot].self, decoder: JSONDecoder())
                .replaceError(with: [])
                .receive(on: RunLoop.main)
                .sink { [weak self] lots in
                    self?.lots = lots
                    self?.isLoading = false
                }
                .store(in: &cancellables)
            return
        }

        service.fetchLots()
            .receive(on: RunLoop.main)
            .sink { [weak self] lots in
                self?.lots = lots
                self?.isLoading = false
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

    // Return an array of (venue, distanceInMeters) sorted by distance ascending
    func distancesForLot(_ lot: ParkingLot) -> [(venue: Venue, meters: Double)] {
        return venues.map { ($0, distance(from: lot, to: $0)) }
            .sorted(by: { $0.meters < $1.meters })
    }

    // Return formatted strings like "350 m — Little Caesars Arena" for display
    func formattedDistances(for lot: ParkingLot) -> [String] {
        distancesForLot(lot).map { pair in
            let meters = pair.meters
            if meters >= 1000 {
                return String(format: "%.1f km — %@", meters / 1000, pair.venue.name)
            } else {
                return String(format: "%.0f m — %@", meters, pair.venue.name)
            }
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

    func registerLot(_ lot: ParkingLot) {
        service.registerLot(lot)
            .receive(on: RunLoop.main)
            .sink { [weak self] newLot in
                guard let self = self else { return }
                self.lots.append(newLot)
            }
            .store(in: &cancellables)
    }

    // Admin helpers (for mock/testing)
    func fetchAllLots(completion: (([ParkingLot]) -> Void)? = nil) {
        // If service supports fetchAllLots, use it; otherwise return current lots
        if let svc = service as? MockLotsService {
            svc.fetchAllLots()
                .receive(on: RunLoop.main)
                .sink { all in
                    completion?(all)
                }
                .store(in: &cancellables)
        } else {
            completion?(lots)
        }
    }

    func approveLot(_ lotId: UUID, completion: ((ParkingLot?) -> Void)? = nil) {
        if let svc = service as? MockLotsService {
            svc.approveLot(lotId: lotId)
                .receive(on: RunLoop.main)
                .sink { updated in
                    // refresh published lots for drivers
                    self.fetchLots()
                    completion?(updated)
                }
                .store(in: &cancellables)
        } else {
            // no-op for other services; in production this would call backend
            completion?(nil)
        }
    }
}
