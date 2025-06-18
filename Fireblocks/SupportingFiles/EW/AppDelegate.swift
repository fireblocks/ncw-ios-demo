//
//  AppDelegate.swift
//  Fireblocks
//
//  Created by Ofir Barzilay  on 05/06/2025.
//

import UIKit
import FirebaseCore
import FirebaseMessaging

/*
 Important: Add the following to Info.plist:
 
 <key>FirebaseAppDelegateProxyEnabled</key>
 <false/>
 It will disable swizzling of AppDelegate methods by Firebase, allowing you to handle notifications manually.
 
 Certificate Setup Instructions:
 1. Generate APNs certificate in Apple Developer Console:
    - Go to Certificates, Identifiers & Profiles
    - Create a new certificate (Apple Push Notification service SSL)
    - Select your app ID and follow the instructions to create a CSR
    - Download the certificate (.cer file)
 
 2. Convert to .p12 format:
    - Open Keychain Access on your Mac
    - Import the .cer file
    - Right-click on the imported certificate and export as .p12
    - Set a password (remember it for Firebase)
 
 3. Upload to Firebase:
    - Go to your Firebase project console
    - Navigate to Project Settings > Cloud Messaging
    - In the "Apple app configuration" section, upload the .p12 file
    - Enter the password you created
    - Save changes
 */
class AppDelegate: UIResponder, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        Messaging.messaging().delegate = self

        return true
    }
    
    func application(_ application: UIApplication,
         didReceiveRemoteNotification userInfo: [AnyHashable: Any],
         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // Silent Push Notification processing
        if let silentNotification = userInfo["aps"] as? [String: AnyObject],
           silentNotification["content-available"] as? Int == 1 {
            
            print("Received silent notification: \(userInfo)")            
            // Launch of a some service
            Task {
                await FireblocksManager.shared.handleNotificationPayload(userInfo: userInfo)
            }
        }
        // Ending a background operation
        completionHandler(.noData)
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device token received: \(tokenString)")
        
        // Pass to Firebase
        Messaging.messaging().apnsToken = deviceToken
        
        // Register with your backend
        Task {
            do {
                try await FireblocksManager.shared.registerPushNotificationToken(tokenString)
            } catch {
                print("Failed to register token: \(error)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Extract and log data without showing notification UI
        let userInfo = notification.request.content.userInfo
        
        // Log the full notification data
        print("Received notification in foreground: \(userInfo)")            
        
        Task {
            await FireblocksManager.shared.handleNotificationPayload(userInfo: userInfo)
        }
        
        // Pass empty array to prevent visible notification
        completionHandler([])
        
    }

    // Handle notification tap (this won't trigger if notification isn't shown)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped with data: \(userInfo)")
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
       
        
        // This is the correct token to register with your server
        if let fcmToken = fcmToken {
            Task {
                do {
                    try await FireblocksManager.shared.registerPushNotificationToken(fcmToken)
                } catch {
                    print("FCM Token registration deferred: \(error)")
                }
            }
        } else {
            print("Firebase registration token is nil.")
        }
    }
}
