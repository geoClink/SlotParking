o import SwiftUI

struct AttendantPanelView: View {
    @EnvironmentObject var viewModel: LotsViewModel
    var lot: ParkingLot

    @State private var isUpdating = false

    var body: some View {
        VStack(spacing: 16) {
            Text(lot.name)
                .font(.title2)
            Text("Available: \(lot.availableSpots)/\(lot.totalSpots)")
                .font(.headline)

            HStack(spacing: 20) {
                Button(action: { update(delta: -1) }) {
                    Label("Out", systemImage: "arrow.down.circle")
                        .font(.title3)
                }
                .disabled(lot.availableSpots <= 0 || isUpdating)

                Button(action: { update(delta: 1) }) {
                    Label("In", systemImage: "arrow.up.circle")
                        .font(.title3)
                }
                .disabled(lot.availableSpots >= lot.totalSpots || isUpdating)
            }

            Spacer()
        }
        .padding()
    }

    private func update(delta: Int) {
        isUpdating = true
        viewModel.updateAvailableSpots(lotId: lot.id, delta: delta)
        // light haptic feedback to indicate update
        Haptics.success()
        // small delay to allow the view model to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isUpdating = false
        }
    }
}

#Preview {
    AttendantPanelView(lot: ParkingLot(name: "Preview Lot", latitude: 42.34, longitude: -83.05, totalSpots: 10, availableSpots: 5, pricePerHour: 5.0))
}
