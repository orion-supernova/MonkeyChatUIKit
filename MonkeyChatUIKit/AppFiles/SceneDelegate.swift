//
//  SceneDelegate.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import SafariServices
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var tabController: UITabBarController?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        UNUserNotificationCenter.current().delegate = self

        //MARK: Setup Logged In UI
        self.tabController = UITabBarController()
        let tabController = self.tabController
        let vc0 = UINavigationController(rootViewController: ProfileViewController())
        let vc1 = UINavigationController(rootViewController: ChatRoomListViewController())
        let vc2 = UINavigationController(rootViewController: SettingsViewController())
        tabController?.viewControllers = [/*vc0,*/ vc1, vc2]
        tabController?.selectedIndex = 0
        tabController?.tabBar.tintColor = .systemPink

        vc0.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        vc1.tabBarItem.image = UIImage(systemName: "list.bullet")
        vc2.tabBarItem.image = UIImage(systemName: "gear")

        vc0.title = "MonkeyList"
        vc1.title = "ChatList"
        vc2.title = "Settings"

        //MARK: Check For Auth & Navigate
        let currentUser = Auth.auth().currentUser

        if currentUser != nil {
            let confirmed = AppGlobal.shared.eulaConfirmed ?? false
            guard confirmed else {
                window?.rootViewController = EULAViewController()
                return
            }
            window?.rootViewController = tabController
        } else {
            window?.rootViewController = AuthViewController()
        }

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("DEBUG: -----------APPLICATIONDIDBECOMEACTIVE")
        let application = UIApplication.shared
        if application.applicationIconBadgeNumber != 0 {
            application.applicationIconBadgeNumber = 0
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

// MARK: - UNUserNotificationCenter Delegate
extension SceneDelegate: UNUserNotificationCenterDelegate {
    // If the user opens the app via notification, this function will be triggered.
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        guard let tabController else { return }
        let userInfo = response.notification.request.content.userInfo

        guard let aps = userInfo["aps"] as? [String: AnyObject] else { return }

        guard let identifier = PushNotificationIdentifiers.Action(rawValue: response.actionIdentifier) else {
            viewActionForChatRoom()
            return
        }
        switch identifier {
            case .viewAction:
                viewActionForChatRoom()
            case .nudgeAction:
                guard let chatRoomID = userInfo["chatRoomID"] as? String else { return }
                guard let fcmToken = userInfo["fcmToken"] as? String else { return }
                guard let chatRoomName = userInfo["chatRoomName"] as? String else { return }
                let sender = PushNotificationSender()
                sender.sendPushNotification(to: fcmToken , title: "DDDDRRRRTTTTT", body: "\(AppGlobal.shared.username ?? "") has sent a nudge back in \(chatRoomName)!", chatRoomID: chatRoomID, chatRoomName: chatRoomName, category: .nudgeCategory)
            case .dismissAction:
                break
        }

        // MARK: - Custom Methods Start
        func viewActionForChatRoom() {
            if let chatRoomID = userInfo["chatRoomID"] as? String {
                self.tabController?.selectedIndex = 0
                if let navigations = self.tabController?.viewControllers {
                    for item in navigations {
                        if let navigation = item as? UINavigationController {
                            navigation.popToRootViewController(animated: false)
                        }
                    }
                }
                tabController.navigationController?.present(ChatRoomListViewController(), animated: false)
                NotificationCenter.default.post(name: .openedChatRoomFromNotification, object: chatRoomID)
            }
        }

        func viewActionForFriendRequest() {
            //
        }

        // MARK: - Custom Methods End
        completionHandler()
    }

    //MARK: - Foreground Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        guard let userInfoDict = notification.request.content.userInfo as? [String: Any] else { return [.badge] }
        guard userInfoDict["userID"] as? String != AppGlobal.shared.userID else {
            return [.badge]
        }
        guard let apsDict = userInfoDict["aps"] as? [String: Any] else { return .badge }
//        guard let categoryString = apsDict["category"] as? String, let category = PushNotificationIdentifiers.Category(rawValue: categoryString) else { return .badge}
        let categoryIdentifier = notification.request.content.categoryIdentifier
        let category = PushNotificationIdentifiers.Category(rawValue: categoryIdentifier)

        switch category {
            case .messageCategory:
                let currentPage = AppGlobal.shared.currentPage
                if currentPage != .chatRoom {
                    return [.alert, .sound]
                } else {
                    guard userInfoDict["chatRoomID"] as? String == AppGlobal.shared.lastEnteredChatRoomID else { return [.alert, .sound] }
                    return .badge
                }
            case .nudgeCategory:
                let rootViewController = UIApplication.shared.windows.first!.rootViewController!
                if let topViewController = rootViewController.topController {
                    let alert = apsDict["alert"] as? [String : Any] ?? [:]
                    let title = alert["title"] as? String ?? ""
                    let body = alert["body"] as? String ?? ""
                    print("hmm")
                    AlertHelper.simpleAlertMessage(viewController: topViewController, title: title, message: body)
                }
//                NotificationCenter.default.post(name: .nudgeReceivedInsideChatRoom, object: username.isEmpty ? "Anonymous" : username)
                return .badge
            case .friendCategory:
                guard let viewController = UIApplication.shared.windows.first!.rootViewController!.topController else { return .badge }
                let username = userInfoDict["username"] as? String ?? ""
                AlertHelper.simpleAlertMessage(viewController: viewController, title: "WOW", message: "\(username) added you as a friend!")
                return .badge
            default:
                return .badge
        }
    }
}

