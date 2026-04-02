# SlotParking

SlotParking is an iOS SwiftUI app for discovering nearby parking lots, tracking live spot availability, and supporting basic owner, attendant, and admin workflows for lot operations.

The current build is centered on Detroit-area parking and venues, with a driver-facing map/list experience and optional Firebase-backed data for realtime updates.

## Features

- Browse parking lots on a map or in a list
- Search lots by name or address
- View pricing, address, and available spot counts
- See distance from each lot to nearby Detroit venues
- Register a new lot through a multi-step owner onboarding flow
- Let attendants update available spot counts
- Review and approve pending lots in a debug-only admin panel
- Support mock data for local development and Firebase for live data

## Tech Stack

- Swift
- SwiftUI
- MapKit
- Combine
- Firebase Auth
- Firebase Firestore
- Firebase Messaging / Apple Push Notifications

## Current App Flow

### Drivers

Users can browse approved lots in either a map or list view, search lots, and open lot details.

### Owners

Owners can submit a lot with:

- Basic lot information
- Map pin placement
- Photo upload/cropping
- Simple phone verification flow

Submitted lots are marked as `pending` until approved.

### Attendants

Attendants can sign in and update spot counts using simple in/out controls.

### Admin

In `DEBUG` builds, an admin panel can review all lots and approve pending listings.

## Project Structure

```text
SlotParking/
├── SlotParking/
│   ├── Models/
│   ├── Services/
│   ├── Utils/
│   ├── ViewModels/
│   ├── Views/
│   ├── Assets.xcassets
│   ├── ContentView.swift
│   ├── SlotParkingApp.swift
│   └── GoogleService-Info.plist
└── Products/
```

## Running Locally

### Requirements

- Xcode
- iOS Simulator or physical iPhone

### Default Development Mode

The app can run with mock data when Firebase packages are not available. This is the simplest way to explore the UI and workflows locally.

Mock mode includes:

- Seeded parking lots
- Demo attendant login support
- Local pending/approval flow through the mock service

### Optional Dev Server

`DevConfig.swift` exposes `ADMIN_SERVER_BASE_URL`. If you point that value to a local backend, the app will fetch approved lots from that server and POST newly registered lots for approval.

### Firebase Setup

Firebase is optional but supported. To enable it:

1. Create a Firebase project.
2. Register the iOS app and add `GoogleService-Info.plist` to the target.
3. Add the Firebase packages used by the app:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseFirestoreSwift`
   - `FirebaseMessaging` (optional)
4. Configure Firestore with a `lots` collection.

The app already calls `FirebaseApp.configure()` on launch when Firebase is available.

For more detail, see [README_FIREBASE.md](./SlotParking/SlotParking/README_FIREBASE.md).

## Notes

- Approved lots are shown to drivers.
- Newly registered lots default to `pending`.
- The admin panel is intended for development/debug workflows.
- The current venue and sample lot data are Detroit-focused.

## Roadmap Ideas

- Production-grade owner and attendant authentication
- Stronger Firestore security rules
- Reservation and payment support
- Better admin moderation tools
- Richer notifications and live event-based pricing

