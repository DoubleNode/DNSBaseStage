//
//  DNSNavBarCoordinator.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import DNSCore
import DNSCoreThreading
import UIKit

open class DNSNavBarCoordinator: DNSCoordinator {
    public var navigationController: UINavigationController
    public var savedViewControllers: [UIViewController]? = []

    // MARK: - Object lifecycle

    public init(with navigationController: UINavigationController) {
        self.navigationController = navigationController

        super.init()
    }

    override public func start() {
        super.start()

        DNSUIThread.run {
            self.savedViewControllers = self.navigationController.viewControllers
        }
    }
    override public func reset() {
        super.reset()

        self.savedViewControllers = nil
    }
    override public func stop() {
        super.stop()

        if self.savedViewControllers != nil {
            DNSUIThread.run {
                self.navigationController.setViewControllers(self.savedViewControllers!,
                                                             animated: true)
            }
        }

        self.savedViewControllers = nil
    }
}
