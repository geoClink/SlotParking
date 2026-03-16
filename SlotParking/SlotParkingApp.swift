//
//  SlotParkingApp.swift
//  SlotParking
//
//  Created by George Clinkscales on 3/14/26.
//

import SwiftUI
import UserNotifications
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

@main
struct SlotParkingApp: App {
    // register app delegate for Firebase setup when available
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MVPContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif

        // Request notification permission and register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification auth error: \(error)")
            }
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    print("User denied notifications")
                }
            }
        }

        #if canImport(FirebaseMessaging)
        // Set Messaging delegate
        Messaging.messaging().delegate = self
        #endif

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = deviceToken
        #endif
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    // UNUserNotificationCenterDelegate: show notifications while app is foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

#if canImport(FirebaseMessaging)
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM registration token: \(token)")
        // Broadcast token so models can register it with Firestore
        NotificationCenter.default.post(name: .fcmTokenUpdated, object: token)
    }
}
#endif

extension Notification.Name {
    static let fcmTokenUpdated = Notification.Name("fcmTokenUpdated")
}
