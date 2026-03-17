import SwiftUI

struct LotDetailView: View {
    @EnvironmentObject var viewModel: LotsViewModel
    var lot: ParkingLot
    var onOpenAttendant: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text(lot.name)
                .font(.title2)
                .bold()
            if let addr = lot.address {
                Text(addr)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Available: \(lot.availableSpots)/\(lot.totalSpots)")
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.0f/hr", lot.pricePerHour))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Distance to downtown venues:")
                    .font(.subheadline)
                    .bold()
                ForEach(viewModel.formattedDistances(for: lot), id: \.self) { line in
                    Text(line)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: { onOpenAttendant?() }) {
                Text("Open Attendant Panel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .onTapGesture {
                DispatchQueue.main.async {
                    let h = UIImpactFeedbackGenerator(style: .medium)
                    h.impactOccurred()
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Lot Details")
        .onAppear {
            DispatchQueue.main.async {
                let g = UIImpactFeedbackGenerator(style: .light)
                g.impactOccurred()
            }
        }
    }
}

#Preview {
    LotDetailView(lot: ParkingLot(name: "Preview Lot", latitude: 42.34, longitude: -83.05, totalSpots: 100, availableSpots: 12, pricePerHour: 6.0))
        .environmentObject(LotsViewModel())
}
