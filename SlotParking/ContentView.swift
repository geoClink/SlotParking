//
//  ContentView.swift
//  SlotParking
//
//  Created by George Clinkscales on 3/14/26.
//

import SwiftUI
import MapKit
#if canImport(FirebaseCore)
import FirebaseCore
#endif

struct ContentView: View {
    @StateObject private var viewModel = LotsViewModel()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.3417, longitude: -83.0555), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))

    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $region, annotationItems: viewModel.lots) { lot in
                    MapAnnotation(coordinate: lot.coordinate) {
                        VStack(spacing: 4) {
                            Image(systemName: "parkingsign.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                            Text("\(lot.availableSpots)")
                                .font(.caption)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(6)
                        }
                    }
                }
                .frame(height: 320)

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
                }
                .listStyle(.plain)
            }
            .navigationTitle("Detroit Parking")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") { viewModel.fetchLots() }
                }
            }
        }
        .onAppear {
            // verify GoogleService-Info.plist presence
            if let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") {
                print("GoogleService-Info.plist bundled at: \(url.path)")
                if let dict = NSDictionary(contentsOf: url) as? [String: Any], let bundleId = dict["BUNDLE_ID"] as? String {
                    print("GoogleService-Info.plist BUNDLE_ID: \(bundleId)")
                }
            } else {
                print("GoogleService-Info.plist not found in main bundle")
            }

            // If FirebaseCore is available, verify FirebaseApp is configured
            #if canImport(FirebaseCore)
            if let app = FirebaseApp.app() {
                print("FirebaseApp is configured. name=\(app.name)")
                let opts = app.options
                print("Firebase options: googleAppID=\(opts.googleAppID), projectID=\(opts.projectID ?? "<nil>"), apiKey=\(opts.apiKey ?? "<nil>")")
            } else {
                print("FirebaseApp not configured yet. If you added Firebase packages, ensure FirebaseApp.configure() runs on launch.")
            }
            #else
            print("Firebase not available in this build (FirebaseCore not imported). Add Firebase via Swift Package Manager or CocoaPods.")
            #endif
        }
    }
}

#Preview {
    ContentView()
}
