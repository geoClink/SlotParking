import SwiftUI

struct MVPContentView: View {
    @StateObject private var viewModel = LotsViewModel()
    @State private var showAttendantLogin = false
    @State private var showAttendantPanel = false
    @State private var selectedLot: ParkingLot? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Simple map placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 220)
                        .padding(.horizontal)
                    VStack {
                        Image(systemName: "map")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.blue)
                        Text("Map view coming — shows nearby lots")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                List(viewModel.lots) { lot in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(lot.name)
                                .font(.headline)
                            Spacer()
                            Text(String(format: "$%.0f/hr", lot.pricePerHour))
                                .foregroundColor(.secondary)
                        }
                        Text(lot.address ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("Available: \(lot.availableSpots)/\(lot.totalSpots)")
                            Spacer()
                            Text(viewModel.nearestVenueDistanceString(for: lot))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                    .onTapGesture {
                        selectedLot = lot
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Detroit Parking")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Refresh") { viewModel.fetchLots() }
                        Button("Attendant") { showAttendantLogin = true }
                    }
                }
            }
            .sheet(isPresented: $showAttendantLogin) {
                AttendantLoginView(onSignedIn: { userId in
                    // after sign in, show attendant panel for the selected lot, or default to first lot
                    if let s = selectedLot {
                        selectedLot = s
                    } else {
                        selectedLot = viewModel.lots.first
                    }
                    showAttendantLogin = false
                    if selectedLot != nil { showAttendantPanel = true }
                })
            }
            .sheet(isPresented: $showAttendantPanel) {
                if let lot = selectedLot {
                    AttendantPanelView(lot: lot)
                        .environmentObject(viewModel)
                } else {
                    Text("No lot selected")
                }
            }
        }
    }
}

#Preview {
    MVPContentView()
}
