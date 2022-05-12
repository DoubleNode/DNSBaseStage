//
//  DNSNavBarCoordinator.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import DNSCoreThreading
import DNSDataObjects
import JKDrawer
import UIKit

open class DNSNavBarCoordinator: DNSCoordinator {
    public var navDrawerController: DNSUINavDrawerController?
    public var navigationController: DNSUINavigationController?
    public var savedViewControllers: [UIViewController]? = []

    // MARK: - Object lifecycle

    public init(with navDrawerController: DNSUINavDrawerController? = nil) {
        self.navDrawerController = navDrawerController
        super.init()
    }
    public init(with navigationController: DNSUINavigationController? = nil) {
        self.navigationController = navigationController
        super.init()
    }

    override open func start(then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(then: completionBlock)
    }
    override open func start(with connectionOptions: UIScene.ConnectionOptions,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: connectionOptions,
                    then: completionBlock)
    }
    override open func start(with notification: DAONotification,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: notification,
                    then: completionBlock)
    }
    override open func start(with openURLContexts: Set<UIOpenURLContext>,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: openURLContexts,
                    then: completionBlock)
    }
    override open func start(with userActivity: NSUserActivity,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: userActivity,
                    then: completionBlock)
    }

    override open func start(then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(then: completionResultsBlock)
    }
    override open func start(with connectionOptions: UIScene.ConnectionOptions,
                             then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(with: connectionOptions,
                    then: completionResultsBlock)
    }
    override open func start(with notification: DAONotification,
                             then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(with: notification,
                    then: completionResultsBlock)
    }
    override open func start(with openURLContexts: Set<UIOpenURLContext>,
                             then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(with: openURLContexts,
                    then: completionResultsBlock)
    }
    override open func start(with userActivity: NSUserActivity,
                             then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(with: userActivity,
                    then: completionResultsBlock)
    }
    override open func commonStart() {
        super.commonStart()
        DNSUIThread.run {
            if let navDrawerController = self.navDrawerController {
                self.savedViewControllers = navDrawerController.viewControllers
//            } else if let navigationController = self.navigationController {
//                self.savedViewControllers = navigationController.viewControllers
            }
        }
    }

    override open func continueRunning(with connectionOptions: UIScene.ConnectionOptions) {
        super.continueRunning(with: connectionOptions)
    }
    override open func continueRunning(with notification: DAONotification) {
        super.continueRunning(with: notification)
    }
    override open func continueRunning(with openURLContexts: Set<UIOpenURLContext>) {
        super.continueRunning(with: openURLContexts)
    }
    override open func continueRunning(with userActivity: NSUserActivity) {
        super.continueRunning(with: userActivity)
    }
    
    override open func reset() {
        super.reset()
        self.savedViewControllers = nil
    }
    override open func stop(with results: DNSBaseStageBaseResults? = nil) {
        if self.savedViewControllers != nil {
            DNSUIThread.run {
                if let navDrawerController = self.navDrawerController {
                    navDrawerController.setViewControllers(self.savedViewControllers!,
                                                           animated: true)
    //            } else if let navigationController = self.navigationController {
    //                self.savedViewControllers = navigationController.viewControllers
                }
            }
        }
        self.savedViewControllers = nil
        super.stop(with: results)
    }
    override open func cancel() {
        self.savedViewControllers = nil
        super.cancel()
    }
}
