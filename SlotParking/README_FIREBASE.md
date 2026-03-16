Firebase setup for SlotParking (MVP)

Overview
- This document lists minimal steps to enable Firebase (Firestore + Auth) for the SlotParking iOS app.

1) Create a Firebase project
- Go to the Firebase Console and create a new project (e.g., slot-parking-detroit).

2) Add an iOS app
- Register your iOS bundle ID and download the GoogleService-Info.plist. Add it to the Xcode project target.

3) Add dependencies
- Using Xcode Swift Packages, add Firebase iOS SDK packages:
  - FirebaseAuth
  - FirebaseFirestore
  - FirebaseFirestoreSwift (optional, for Codable support)
  - FirebaseMessaging (optional, if you want push notifications)

4) Basic Firestore layout
- Collection `lots` (document id should be lotId, string)
  - name: string
  - ownerId: string
  - address: string
  - location: geopoint
  - totalSpots: number
  - availableSpots: number
  - pricePerHour: number
  - updatedAt: timestamp

5) Minimal security rules (pilot only)
- Allow reads to `lots` for everyone.
- Allow writes to `lots` only for authenticated users; owners may own their documents.

Example rules (pilot, not production):

service cloud.firestore {
  match /databases/{database}/documents {
    match /lots/{lotId} {
      allow read: if true;
      allow write: if request.auth != null; // restrict further in production
    }
  }
}

6) Use in the app
- Ensure `GoogleService-Info.plist` is in the app bundle.
- The project already calls `FirebaseApp.configure()` in `AppDelegate` when `FirebaseCore` is available.
- Replace the default `LotsViewModel` service with `FirebaseLotsService()` to get realtime updates.

Switching to Firebase in code (example):
- In `LotsViewModel`, init with `FirebaseLotsService()` instead of `MockLotsService()`.

Security & next steps
- Implement stricter Firestore rules before any public pilot (limit write access, validate owner/attendant relationships).
- Consider Cloud Functions for server-side validation (e.g., to prevent attendants from spoofing counts).
- Monitor Firestore usage to avoid unexpected costs.

