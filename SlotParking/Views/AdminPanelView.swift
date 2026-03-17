import SwiftUI

#if DEBUG
struct AdminPanelView: View {
    @EnvironmentObject var viewModel: LotsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var allLots: [ParkingLot] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(allLots) { lot in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(lot.name).bold()
                            Spacer()
                            Text(lot.status.capitalized)
                                .foregroundColor(lot.status == "approved" ? .green : (lot.status == "pending" ? .orange : .red))
                        }
                        Text(lot.address ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("Available: \(lot.availableSpots)/\(lot.totalSpots)")
                            Spacer()
                            if lot.status == "pending" {
                                Button("Approve") {
                                    viewModel.approveLot(lot.id) { updated in
                                        // success haptic for admin approve
                                        Haptics.success()
                                        refresh()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Admin — Lots")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Close") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Refresh") { refresh() } }
            }
            .onAppear(perform: refresh)
        }
    }

    private func refresh() {
        viewModel.fetchAllLots { lots in allLots = lots }
    }
}
#endif

#Preview {
#if DEBUG
    AdminPanelView().environmentObject(LotsViewModel())
#endif
}
