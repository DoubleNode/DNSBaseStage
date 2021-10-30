//
//  DNSSceneDelegate.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSBaseTheme
import DNSCore
import DNSCoreThreading
import UIKit

open class DNSSceneDelegate: UIResponder, UIWindowSceneDelegate {
    public var coordinator: DNSCoordinator?
    public var window: UIWindow?

    /// The instance of the `UIAlertController` used to present the update alert.
    private var alertController: UIAlertController?
    /// The `UIWindow` instance that presents the `DNSAlertViewController`.
    public lazy var updaterWindow = createWindow()

    public func presentAlert(_ alertController: UIAlertController) {
        self.alertController = alertController
        if let updaterWindow = updaterWindow, updaterWindow.isHidden {
            alertController.dnsShow(window: updaterWindow)
        } else {
            cleanUpAlert()
        }
    }
    public func cleanUpAlert() {
        guard let updaterWindow = updaterWindow else { return }
        alertController?.dnsHide(window: updaterWindow)
        alertController?.dismiss(animated: true, completion: nil)
        updaterWindow.resignKey()
    }

    // MARK: - UIWindowSceneDelegate methods

    open func scene(_ scene: UIScene,
                    willConnectTo session: UISceneSession,
                    options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new
        // (see `application:configurationForConnectingSceneSession` instead).
        guard (scene as? UIWindowScene) != nil else { return }
        guard let coordinator = self.coordinator else { return }

        DNSLowThread.run(.asynchronously) {
            if coordinator.isRunning {
                coordinator.continueRunning(with: connectionOptions)
            } else {
                coordinator.start(with: connectionOptions) { (success: Bool) in }
            }
        }
    }

    open func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new
        // (see `application:configurationForConnectingSceneSession` instead).
        guard (scene as? UIWindowScene) != nil else { return }
        guard let coordinator = self.coordinator else { return }

        DNSLowThread.run(.asynchronously) {
            if coordinator.isRunning {
                coordinator.continueRunning(with: URLContexts)
            } else {
                coordinator.start(with: URLContexts) { (success: Bool) in }
            }
        }
    }

    open func scene(_ scene: UIScene,
                    continue userActivity: NSUserActivity) {
        guard (scene as? UIWindowScene) != nil else { return }
        guard let coordinator = self.coordinator else { return }

        DNSLowThread.run(.asynchronously) {
            if coordinator.isRunning {
                coordinator.continueRunning(with: userActivity)
            } else {
                coordinator.start(with: userActivity) { (success: Bool) in }
            }
        }
    }

    open func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded
        // (see `application:didDiscardSceneSessions` instead).

        DNSLowThread.run(.synchronously) {
            self.coordinator?.stop()
        }
        coordinator = nil
    }

    open func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        (coordinator as? DNSSceneCoordinatorProtocol)?.didBecomeActive()
    }

    open func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        (coordinator as? DNSSceneCoordinatorProtocol)?.willResignActive()
    }

    open func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        (coordinator as? DNSSceneCoordinatorProtocol)?.willEnterForeground()
    }

    open func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        (coordinator as? DNSSceneCoordinatorProtocol)?.didEnterBackground()
    }
}
private extension DNSSceneDelegate {
    private func createWindow() -> UIWindow? {
        guard let windowScene = getFirstForegroundScene() else { return nil }
        
        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = UIWindow.Level.alert + 1
        
        let viewController = DNSAlertViewController()
        viewController.retainedWindow = window
        window.rootViewController = viewController
        
        return window
    }
    
    @available(iOS 13.0, tvOS 13.0, *)
    private func getFirstForegroundScene() -> UIWindowScene? {
        let connectedScenes = UIApplication.shared.connectedScenes
        if let windowActiveScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            return windowActiveScene
        } else if let windowInactiveScene = connectedScenes.first(where: { $0.activationState == .foregroundInactive }) as? UIWindowScene {
            return windowInactiveScene
        } else {
            return nil
        }
    }
}
