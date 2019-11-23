//
//  DNSTabBarCoordinator.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import DNSCore
import DNSCoreThreading
import UIKit

open class DNSTabBarCoordinator: DNSCoordinator {
    public var tabBarController: UITabBarController
    public var savedViewControllers: [UIViewController]? = []

    // MARK: - Object lifecycle

    public init(with tabBarController: UITabBarController) {
        self.tabBarController = tabBarController

        super.init()
    }

    override open func start() {
        super.start()

        DNSUIThread.run {
            self.savedViewControllers = self.tabBarController.viewControllers
        }
    }
    override open func reset() {
        super.reset()

        self.savedViewControllers = nil
    }
    override open func stop() {
        super.stop()

        if self.savedViewControllers != nil {
            DNSUIThread.run {
                self.tabBarController.setViewControllers(self.savedViewControllers!,
                                                         animated: true)
            }
        }

        self.savedViewControllers = nil
    }
}
