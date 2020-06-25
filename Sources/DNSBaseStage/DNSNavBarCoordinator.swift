//
//  DNSNavBarCoordinator.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import DNSCoreThreading
import UIKit

open class DNSNavBarCoordinator: DNSCoordinator {
    public var navigationController: UINavigationController?
    public var savedViewControllers: [UIViewController]? = []

    // MARK: - Object lifecycle

    public init(with navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController

        super.init()
    }

    override open func start(then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(then: completionBlock)

        DNSUIThread.run {
            self.savedViewControllers = self.navigationController?.viewControllers
        }
    }
    override open func start(with openURLContexts: Set<UIOpenURLContext>,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: openURLContexts,
                    then: completionBlock)

        DNSUIThread.run {
            self.savedViewControllers = self.navigationController?.viewControllers
        }
    }
    override open func start(with userActivity: NSUserActivity,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: userActivity,
                    then: completionBlock)

        DNSUIThread.run {
            self.savedViewControllers = self.navigationController?.viewControllers
        }
    }

    override open func reset() {
        super.reset()

        self.savedViewControllers = nil
    }
    override open func stop() {
        if self.savedViewControllers != nil {
            DNSUIThread.run {
                self.navigationController?.setViewControllers(self.savedViewControllers!,
                                                              animated: true)
            }
        }

        self.savedViewControllers = nil

        super.stop()
    }
    override open func cancel() {
        self.savedViewControllers = nil

        super.cancel()
    }
}
