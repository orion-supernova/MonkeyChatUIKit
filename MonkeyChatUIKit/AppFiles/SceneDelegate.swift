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


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        UNUserNotificationCenter.current().delegate = self

        //MARK: Setup Logged In UI
        let tabController = UITabBarController()
//        let vc0 = UINavigationController(rootViewController: MonkeyListViewController())
        let vc1 = UINavigationController(rootViewController: ChatRoomListViewController())
        let vc2 = UINavigationController(rootViewController: SettingsViewController())
        tabController.viewControllers = [/*vc0,*/ vc1, vc2]
        tabController.selectedIndex = 0
        tabController.tabBar.tintColor = .systemPink

//        vc0.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        vc1.tabBarItem.image = UIImage(systemName: "list.bullet")
        vc2.tabBarItem.image = UIImage(systemName: "gear")

//        vc0.title = "MonkeyList"
        vc1.title = "ChatList"
        vc2.title = "Settings"

        //MARK: Check For Auth & Navigate
        let currentUser = Auth.auth().currentUser

        if currentUser != nil {
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

// MARK: - UNUserNotificationCenterDelegate

extension SceneDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        if
            let aps = userInfo["aps"] as? [String: AnyObject] {
//            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1

            if response.actionIdentifier == Identifiers.viewAction,
               let url = URL(string: aps["link_url"] as! String) {
                let safari = SFSafariViewController(url: url)
                window?.rootViewController?.present(safari, animated: true, completion: nil)
            }
        }

        completionHandler()
    }

    //MARK: - Foreground Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        guard let apnsDict = notification.request.content.userInfo as? [String: Any] else { return [.badge] }
        if apnsDict["user"] as? String != AppGlobal.shared.userID {
            return [.alert, .badge, .sound]
        } else {
            return [.badge]
        }
    }
}

