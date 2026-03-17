import SwiftUI

struct MVPContentView: View {
    @StateObject private var viewModel = LotsViewModel()
    @State private var showAttendantLogin = false
    @State private var showAttendantPanel = false
    @State private var selectedLot: ParkingLot? = nil
    @State private var showOwnerRegister = false
    @State private var showAdminPanel = false

    @State private var selectedSegment: Int = 0 // default to Map
    @State private var searchText: String = ""

    private var filteredLots: [ParkingLot] {
        if searchText.isEmpty { return viewModel.lots }
        let lower = searchText.lowercased()
        return viewModel.lots.filter { $0.name.lowercased().contains(lower) || ($0.address?.lowercased().contains(lower) ?? false) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedSegment) {
                    Text("Map").tag(0)
                    Text("List").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.horizontal, .top])

                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search lots", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 6)

                if selectedSegment == 0 {
                    // Map view
                    // Debug badge: show number of loaded lots so it's obvious why map might be empty
                    HStack {
                        Spacer()
                        Text("Lots: \(filteredLots.count)")
                            .font(.caption2)
                            .padding(6)
                            .background(Color(.systemBackground).opacity(0.8))
                            .cornerRadius(8)
                            .padding(.trailing)
                    }
                    .padding(.top, 4)

                    if filteredLots.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "mappin.slash")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No parking lots available — check admin approvals or DevConfig")
                                .foregroundColor(.secondary)
                            Button("Refresh") { viewModel.fetchLots() }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 280)
                        .padding()
                    } else {
                        MapKitView(lots: filteredLots, selectedLot: $selectedLot, centerCoordinate: filteredLots.first?.coordinate)
                            .frame(maxHeight: 320)
                            .padding(.top, 8)
                    }
                } else {
                    // List view
                    List(filteredLots) { lot in
                        NavigationLink(destination: LotDetailView(lot: lot, onOpenAttendant: {
                            selectedLot = lot
                            showAttendantPanel = true
                        }).environmentObject(viewModel)) {
                            VStack(alignment: .leading, spacing: 6) {
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
                                Text("Available: \(lot.availableSpots)/\(lot.totalSpots)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .navigationTitle("Detroit Parking")
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.25).ignoresSafeArea()
                        ProgressView("Loading lots...")
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showOwnerRegister = true }) {
                            Label("Register Lot", systemImage: "plus.square")
                        }
                        Button(action: { showAttendantLogin = true }) {
                            Label("Attendant Login", systemImage: "person.fill")
                        }
                        Button(action: { viewModel.fetchLots() }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        #if DEBUG
                        Divider()
                        Button(action: { showAdminPanel = true }) {
                            Label("Admin", systemImage: "gearshape")
                        }
                        #endif
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                }
            }
            #if DEBUG
            .sheet(isPresented: $showAdminPanel) {
                AdminPanelView()
                    .environmentObject(viewModel)
            }
            #endif
            .sheet(isPresented: $showOwnerRegister) {
                OwnerOnboardingView()
                    .environmentObject(viewModel)
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
