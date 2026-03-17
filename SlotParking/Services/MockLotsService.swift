import Foundation
import Combine

protocol LotsServiceProtocol {
    func fetchLots() -> AnyPublisher<[ParkingLot], Never>
    func updateAvailableSpots(lotId: UUID, delta: Int) -> AnyPublisher<ParkingLot, Never>
    func registerLot(_ lot: ParkingLot) -> AnyPublisher<ParkingLot, Never>
}

final class MockLotsService: LotsServiceProtocol {
    private var current: [UUID: ParkingLot]
    private var cancellables = Set<AnyCancellable>()

    init() {
        let initial = [
            ParkingLot(name: "Riverfront Garage", address: "100 River St", latitude: 42.3389, longitude: -83.0476, totalSpots: 120, availableSpots: 37, pricePerHour: 8.0),
            ParkingLot(name: "The District Lot", address: "200 Monroe St", latitude: 42.3408, longitude: -83.0489, totalSpots: 80, availableSpots: 12, pricePerHour: 10.0),
            ParkingLot(name: "Arena Surface Lot", address: "1 Hockey Ave", latitude: 42.3415, longitude: -83.0550, totalSpots: 60, availableSpots: 5, pricePerHour: 12.0)
        ]
        self.current = Dictionary(uniqueKeysWithValues: initial.map { ($0.id, $0) })
    }

    func fetchLots() -> AnyPublisher<[ParkingLot], Never> {
        // drivers should only see approved lots
        let lots = Array(current.values).filter { $0.status == "approved" }
        return Just(lots)
            .delay(for: .milliseconds(150), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func registerLot(_ lot: ParkingLot) -> AnyPublisher<ParkingLot, Never> {
        var newLot = lot
        if current[newLot.id] != nil {
            newLot = ParkingLot(id: UUID(), name: newLot.name, address: newLot.address, latitude: newLot.latitude, longitude: newLot.longitude, totalSpots: newLot.totalSpots, availableSpots: newLot.availableSpots, pricePerHour: newLot.pricePerHour)
        }
        // default to pending when registering
        newLot.status = "pending"
        current[newLot.id] = newLot

        // if admin server configured, POST the lot so admin can approve
        if let base = ADMIN_SERVER_BASE_URL, let url = URL(string: base + "/lots") {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("dev-token-1234", forHTTPHeaderField: "x-admin-token")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            if let data = try? encoder.encode(newLot) {
                req.httpBody = data
                URLSession.shared.dataTask(with: req) { _, _, _ in }
                .resume()
            }
        }

        return Just(newLot)
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func updateAvailableSpots(lotId: UUID, delta: Int) -> AnyPublisher<ParkingLot, Never> {
        if var lot = current[lotId] {
            let newAvailable = max(0, min(lot.totalSpots, lot.availableSpots + delta))
            lot.availableSpots = newAvailable
            current[lotId] = lot
            return Just(lot)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Empty().eraseToAnyPublisher()
    }
    
    func fetchAllLots() -> AnyPublisher<[ParkingLot], Never> {
        let lots = Array(current.values)
        return Just(lots)
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    // Admin helper to approve a lot in the mock
    func approveLot(lotId: UUID) -> AnyPublisher<ParkingLot, Never> {
        if var lot = current[lotId] {
            lot.status = "approved"
            current[lotId] = lot
            return Just(lot)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Empty().eraseToAnyPublisher()
    }
}
