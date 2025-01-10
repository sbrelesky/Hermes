//
//  SceneDelegate.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static var shared: SceneDelegate? // Shared instance

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        SceneDelegate.shared = self
        
        FirestoreManager.shared.fetchNotices { result in
            switch result {
            case .success(let notices):
                if notices.isEmpty {
                    let navigationController = UINavigationController(rootViewController: LoginController())
                    self.setCurrentWindow(controller: navigationController)
                } else {
                    let noticesController = NoticeController(notices: notices)
                    self.setCurrentWindow(controller: noticesController)
                }
            case .failure(let error):
                print("Error loading notices: ", error)
                let navigationController = UINavigationController(rootViewController: LoginController())
                self.setCurrentWindow(controller: navigationController)
            }
        }
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

    func setCurrentWindow(controller: UIViewController) {
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        
        if let screenHeight = UIScreen.current?.bounds.height {
            Constants.Heights.button = screenHeight * 0.070
            Constants.Heights.textField = screenHeight * 0.076
            Constants.Padding.Vertical.textFieldSpacing = screenHeight * 0.035
            Constants.Padding.Vertical.bottomSpacing = screenHeight * 0.0469
        }
    }
}

