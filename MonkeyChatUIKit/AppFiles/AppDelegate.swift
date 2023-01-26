//
//  AppDelegate.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseDynamicLinks

enum PushNotificationIdentifiers {
    enum Category: String {
        case messageCategory = "MESSAGE_CATEGORY"
        case nudgeCategory   = "NUDGE_CATEGORY"
    }
    enum Action: String {
        case viewAction    = "VIEW_ACTION"
        case nudgeAction   = "NUDGE_ACTION"
        case dismissAction = "DISMISS_ACTION"
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        configureTabbarAndNavbarAppearance()

        registerForPushNotifications()
        AppGlobal.shared.fcmToken = Messaging.messaging().fcmToken
        let viewmodel = SettingsViewModel()
        viewmodel.unsubscribeForNewMessages(chatRoomID: "newMessage")
        viewmodel.unsubscribeForNewMessages(chatRoomID: "newMessages")
        addFCMTokenParameterToFirebaseUserIfNotExist()
        return true
    }

    /// After login, fcmToken parameter is set for new users but for legacy users we are updating here.
    private func addFCMTokenParameterToFirebaseUserIfNotExist() {
        guard let userID = AppGlobal.shared.userID else {
            AuthManager.shared.signOut {
                return
            }
            return
        }
        COLLECTION_USERS.document(userID).getDocument { snapshot, error in
            guard let snapshot else { return }
            let dict = snapshot.data()
            guard dict?["fcmToken"] == nil else { return }
            let data = ["fcmToken": AppGlobal.shared.fcmToken ?? ""] as [String: Any]
            snapshot.reference.updateData(data)
        }
    }

    // MARK: - Apple Push Notifications Service
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }

            // MARK: - Notification Actions
            let viewAction = UNNotificationAction(
                identifier: PushNotificationIdentifiers.Action.viewAction.rawValue,
                title: "Let's Go!",
                options: [.foreground])

            let dismissAction = UNNotificationAction(
                identifier: PushNotificationIdentifiers.Action.dismissAction.rawValue,
                title: "Nevermind...",
                options: [])

            let nudgeAction = UNNotificationAction(
                identifier: PushNotificationIdentifiers.Action.nudgeAction.rawValue,
                title: "Send a nudge back!",
                options: [])

            // MARK: - Notification Categories
            let messageCategory = UNNotificationCategory(
                identifier: PushNotificationIdentifiers.Category.messageCategory.rawValue,
                actions: [viewAction, dismissAction],
                intentIdentifiers: [],
                options: [])

            let nudgeCategory = UNNotificationCategory(
                identifier: PushNotificationIdentifiers.Category.nudgeCategory.rawValue,
                actions: [nudgeAction, dismissAction],
                intentIdentifiers: [],
                options: [])

            UNUserNotificationCenter.current().setNotificationCategories([messageCategory, nudgeCategory])

            self?.getNotificationSettings()
        }
    }

    // MARK: - Background Notification Handler
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        guard userInfo["userID"] as? String != AppGlobal.shared.userID else {
            completionHandler(.failed)
            return
        }
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
    }

    // MARK: - Notification Settings
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
#if DEBUG
        let firebaseAuth = Auth.auth()
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
#endif
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let token = token else { return }
            print("DEBUG: APNS Token: " + token)
        }
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            print("DEBUG: --- DYNAMIC LINK URL \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                guard error == nil else { return }
                if let dynamicLink {
                    self.handleIncomingDynamiclink(dynamicLink)
                }
            }
            if linkHandled {
                return true
            } else {
                return false
            }
        }
        return false
    }

    func handleIncomingDynamiclink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("DEBUG: --- That's weird. My dynamic link object has no url")
            return
        }
        print ("DEBUG: --- Your incoming link parameter is \(url.absoluteString)")
    }

    // MARK: - Configure Navbar and Tabbar Appearance
    func configureTabbarAndNavbarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance   = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance    = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
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
}

