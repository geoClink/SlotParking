import SwiftUI

struct OnboardingView: View {
    var onFinish: (() -> Void)?
    @State private var selection = 0

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $selection) {
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.blue)
                        Text("Find Parking in Detroit")
                            .font(.title)
                            .bold()
                        Text("See privately owned lots, current available spots, price per hour, and distance to major venues.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .tag(0)

                    VStack(spacing: 16) {
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.green)
                        Text("Quick Map View")
                            .font(.title)
                            .bold()
                        Text("Tap a marker to see available spots and prices. Use the list to quickly scan lots and open details for distances to nearby venues.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .tag(1)

                    VStack(spacing: 16) {
                        Image(systemName: "person.2.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.orange)
                        Text("Owners & Attendants")
                            .font(.title)
                            .bold()
                        Text("Owners register lots and upload photos; attendants update counts. All lots are reviewed by admins before appearing to drivers.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

                HStack {
                    if selection > 0 {
                        Button("Back") { withAnimation { selection -= 1 } }
                            .padding(.horizontal)
                    }
                    Spacer()
                    if selection < 2 {
                        Button(selection == 1 ? "Next" : "Next") { withAnimation { selection += 1 } }
                            .padding(.horizontal)
                    } else {
                        Button(action: {
                            onFinish?()
                        }) {
                            Text("Get Started")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        onFinish?()
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
