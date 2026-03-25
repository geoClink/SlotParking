import SwiftUI
import CoreLocation

struct OwnerOnboardingView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var viewModel: LotsViewModel

    @State private var step: Int = 0
    @State private var name = ""
    @State private var address = ""
    @State private var totalSpotsText = "50"
    @State private var pricePerHourText = "5.0"
    @State private var coordinate: CLLocationCoordinate2D?

    struct PhotoItem: Identifiable {
        let id = UUID()
        var image: UIImage
        var label: String
    }
    @State private var photos: [PhotoItem] = []
    @State private var showImagePicker = false
    @State private var showCropper = false
    @State private var cropIndex: Int? = nil

    @State private var phone = ""
    @State private var otpSent = false
    @State private var otpCode = ""
    @State private var verified = false

    @State private var isApplying = false
    @State private var showSuccess = false

    var body: some View {
        NavigationView {
            VStack {
                ProgressView(value: Double(step), total: 3)
                    .padding()
                if step == 0 {
                    Form { Section(header: Text("Lot Information")) {
                        TextField("Name", text: $name)
                        TextField("Address", text: $address)
                        HStack { Text("Total spots"); TextField("50", text: $totalSpotsText).keyboardType(.numberPad).frame(width: 100) }
                        HStack { Text("Price/hr"); TextField("5.00", text: $pricePerHourText).keyboardType(.decimalPad).frame(width: 100) }
                    } }
                } else if step == 1 {
                    VStack {
                        Text("Tap the map to drop a pin at the lot location").font(.subheadline).foregroundColor(.secondary).padding(.horizontal)
                        MapPinPickerView(coordinate: $coordinate).frame(height: 300).cornerRadius(8).padding()
                        if let c = coordinate { Text("Selected: \(String(format: "%.5f, %.5f", c.latitude, c.longitude))").font(.caption).foregroundColor(.secondary) }
                    }
                } else if step == 2 {
                    VStack(alignment: .leading) {
                        ScrollView(.horizontal) { HStack(spacing: 12) {
                            ForEach(photos.indices, id: \.self) { idx in
                                VStack(alignment: .leading, spacing: 6) {
                                    Image(uiImage: photos[idx].image).resizable().scaledToFill().frame(width: 140, height: 90).clipped().cornerRadius(8).onTapGesture { cropIndex = idx; showCropper = true }
                                    TextField("Label (e.g. Entrance)", text: Binding(get: { photos[idx].label }, set: { photos[idx].label = $0 })).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 140)
                                    HStack { Button(action: { cropIndex = idx; showCropper = true }) { Text("Edit") }; Button(action: { photos.remove(at: idx) }) { Text("Remove") } }.font(.caption)
                                }
                            }
                            Button(action: { showImagePicker = true }) { VStack { Image(systemName: "photo.on.rectangle") ; Text("Add") }.frame(width: 140, height: 90).background(Color(.secondarySystemBackground)).cornerRadius(8) }
                        } .padding() }
                        Spacer()
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(images: Binding(get: { photos.map { $0.image } }, set: { newImages in for img in newImages { photos.append(PhotoItem(image: img, label: "")) } }), selectionLimit: 5)
                    }
                    .sheet(isPresented: $showCropper) {
                        if let idx = cropIndex, photos.indices.contains(idx) {
                            ImageCropperView(image: Binding(get: { photos[idx].image }, set: { photos[idx].image = $0 }), onComplete: { cropped in photos[idx].image = cropped; showCropper = false; cropIndex = nil }, onCancel: { showCropper = false; cropIndex = nil })
                        } else { EmptyView() }
                    }
                } else if step == 3 {
                    Form { Section(header: Text("Owner phone verification")) {
                        TextField("Phone", text: $phone).keyboardType(.phonePad)
                        if !otpSent { Button("Send OTP") { sendOTP() } } else if !verified { TextField("Enter OTP", text: $otpCode).keyboardType(.numberPad); Button("Verify") { verifyOTP() } } else { Label("Verified", systemImage: "checkmark.seal.fill").foregroundColor(.green) }
                    } }
                }

                HStack { if step > 0 { Button("Back") { step -= 1 }.padding() }; Spacer(); Button(action: nextOrApply) { if isApplying { ProgressView() } else { Text(step == 3 ? "Apply" : "Next") } }.disabled(!canProceed()).padding() }
            }
            .navigationTitle("Register Lot")
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } } }
            .alert("Registration Submitted", isPresented: $showSuccess) { Button("OK") { presentationMode.wrappedValue.dismiss() } } message: { Text("Your listing has been submitted and is pending review.") }
        }
    }

    private func canProceed() -> Bool {
        switch step { case 0: guard !name.isEmpty else { return false }; if Int(totalSpotsText) == nil { return false }; if Double(pricePerHourText) == nil { return false }; return true
        case 1: return coordinate != nil
        case 2: return !photos.isEmpty
        case 3: return verified
        default: return false }
    }

    private func nextOrApply() { if step < 3 { step += 1 } else { apply() } }

    private func apply() {
        guard let coord = coordinate else { return }
        guard let totalSpots = Int(totalSpotsText), let price = Double(pricePerHourText) else { return }
        isApplying = true
        let lot = ParkingLot(ownerId: nil, name: name, address: address.isEmpty ? nil : address, latitude: coord.latitude, longitude: coord.longitude, totalSpots: totalSpots, availableSpots: totalSpots, pricePerHour: price, status: "pending")
        viewModel.registerLot(lot)
        // haptic to indicate submission success
        Haptics.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isApplying = false; showSuccess = true }
    }

    private func sendOTP() { guard !phone.isEmpty else { return }; otpSent = true }
    private func verifyOTP() { if otpCode == "123456" { verified = true } }
    // haptic when OTP verified
    private func otpVerifiedHaptic() { Haptics.success() }
}

#Preview { OwnerOnboardingView().environmentObject(LotsViewModel()) }
