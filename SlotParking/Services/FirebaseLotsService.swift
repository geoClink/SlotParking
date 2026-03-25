import Foundation
import Combine
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif



// Firebase-backed implementation of LotsServiceProtocol
#if canImport(FirebaseFirestore)
final class FirebaseLotsService: LotsServiceProtocol {
    func registerLot(_ lot: ParkingLot) -> AnyPublisher<ParkingLot, Never> {
        Just(lot)
            .eraseToAnyPublisher()
    }
    
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func fetchLots() -> AnyPublisher<[ParkingLot], Never> {
        let subject = PassthroughSubject<[ParkingLot], Never>()
        listener = db.collection("lots").addSnapshotListener { snapshot, error in
            var results: [ParkingLot] = []
            if let docs = snapshot?.documents {
                for doc in docs {
                    if let lot = try? doc.data(as: ParkingLot.self) {
                        results.append(lot)
                    } else {
                        // try manual decode
                        let data = doc.data()
                        if let name = data["name"] as? String,
                           let lat = data["location"] as? GeoPoint,
                           let total = data["totalSpots"] as? Int,
                           let available = data["availableSpots"] as? Int,
                           let price = data["pricePerHour"] as? Double {
                            let lot = ParkingLot(id: UUID(uuidString: doc.documentID) ?? UUID(), name: name, address: data["address"] as? String, latitude: lat.latitude, longitude: lat.longitude, totalSpots: total, availableSpots: available, pricePerHour: price)
                            results.append(lot)
                        }
                    }
                }
            }
            subject.send(results)
        }
        return subject.eraseToAnyPublisher()
    }

    func updateAvailableSpots(lotId: UUID, delta: Int) -> AnyPublisher<ParkingLot, Never> {
        let subject = PassthroughSubject<ParkingLot, Never>()
        let docRef = db.collection("lots").document(lotId.uuidString)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                try snapshot = transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let data = snapshot.data() else { return nil }
            let total = data["totalSpots"] as? Int ?? 0
            let available = data["availableSpots"] as? Int ?? 0
            let newAvailable = max(0, min(total, available + delta))
            transaction.updateData(["availableSpots": newAvailable, "updatedAt": FieldValue.serverTimestamp()], forDocument: docRef)
            return newAvailable
        }) { (result, error) in
            if let _ = error {
                // ignore failures; the subjects will not emit
            } else if let newAvailable = result as? Int {
                // fetch the updated document to build ParkingLot
                docRef.getDocument { docSnap, err in
                    if let ds = docSnap, let data = ds.data() {
                        if let name = data["name"] as? String,
                           let latLon = data["location"] as? GeoPoint,
                           let total = data["totalSpots"] as? Int,
                           let price = data["pricePerHour"] as? Double {
                            let lot = ParkingLot(id: UUID(uuidString: ds.documentID) ?? UUID(), name: name, address: data["address"] as? String, latitude: latLon.latitude, longitude: latLon.longitude, totalSpots: total, availableSpots: newAvailable, pricePerHour: price)
                            subject.send(lot)
                        }
                    }
                }
            }
        }
        return subject.eraseToAnyPublisher()
    }
}
#endif
