//
//  DNSSceneCoordinator.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import UIKit

public protocol DNSSceneCoordinatorProtocol {
    // MARK: - Object lifecycle
    init(with scene: UIWindowScene)

    // MARK: - UIWindowSceneDelegate methods
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    func didBecomeActive()

    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    func willResignActive()

    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    func willEnterForeground()

    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    func didEnterBackground()
}
