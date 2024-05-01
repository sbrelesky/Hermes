//
//  AppDelegate.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import UIKit
import FirebaseCore
import Stripe
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    // Google API Cloud Console
    // https://console.cloud.google.com/google/maps-apis/home;onboard=true?project=hermes-416119

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        FirebaseFunctionManager.shared.getStripePublishableKey { result in
            
            switch result {
            case .success(let key):
                StripeAPI.defaultPublishableKey = key
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
//        #if DEBUG
//        StripeAPI.defaultPublishableKey = Constants.StripeKeys.testKey
//        #else
//        StripeAPI.defaultPublishableKey = Constants.StripeKeys.key
//        #endif
//        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        // If device token has changed, set the new one
        if UserDefaults.standard.deviceToken != fcmToken {
            UserDefaults.standard.updateToken(token: token)
            UserManager.shared.updateDeviceTokenIfNeeded()
        }
    }
}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    
        let userInfo = notification.request.content.userInfo

        // Print full message.
        print("User Notification willPresent")
        print(userInfo)

        // Change this to your preferred presentation option
        return [[.alert, .badge, .sound]]
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
    let userInfo = response.notification.request.content.userInfo

    // Print full message.
      print("User Notification didReceive")
      print(userInfo)
  }
}

