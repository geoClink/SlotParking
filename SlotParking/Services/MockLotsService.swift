import Foundation
import Combine

protocol LotsServiceProtocol {
    func fetchLots() -> AnyPublisher<[ParkingLot], Never>
    func updateAvailableSpots(lotId: UUID, delta: Int) -> AnyPublisher<ParkingLot, Never>
}

final class MockLotsService: LotsServiceProtocol {
    private var current: [UUID: ParkingLot]
    private let subject = PassthroughSubject<[ParkingLot], Never>()

    init() {
        let initial = [
            ParkingLot(name: "Riverfront Garage", address: "100 River St", latitude: 42.3389, longitude: -83.0476, totalSpots: 120, availableSpots: 37, pricePerHour: 8.0),
            ParkingLot(name: "The District Lot", address: "200 Monroe St", latitude: 42.3408, longitude: -83.0489, totalSpots: 80, availableSpots: 12, pricePerHour: 10.0),
            ParkingLot(name: "Arena Surface Lot", address: "1 Hockey Ave", latitude: 42.3415, longitude: -83.0550, totalSpots: 60, availableSpots: 5, pricePerHour: 12.0)
        ]
        self.current = Dictionary(uniqueKeysWithValues: initial.map { ($0.id, $0) })
    }

    func fetchLots() -> AnyPublisher<[ParkingLot], Never> {
        let lots = Array(current.values)
        return Just(lots)
            .delay(for: .milliseconds(200), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func updateAvailableSpots(lotId: UUID, delta: Int) -> AnyPublisher<ParkingLot, Never> {
        if var lot = current[lotId] {
            lot.availableSpots = max(0, min(lot.totalSpots, lot.availableSpots + delta))
            lot = ParkingLot(id: lot.id, name: lot.name, address: lot.address, latitude: lot.latitude, longitude: lot.longitude, totalSpots: lot.totalSpots, availableSpots: lot.availableSpots, pricePerHour: lot.pricePerHour)
            current[lotId] = lot
            return Just(lot)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
}
