//
//  DNSTabBarCoordinator.swift
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

open class DNSTabBarCoordinator: DNSCoordinator {
    public var tabBarController: DNSUITabBarController?
    public var savedViewControllers: [UIViewController]? = []

    // MARK: - Tab management

    open func numberOfTabs() -> Int {
        return 0
    }
    open func coordinator(for tabNdx: Int) -> DNSCoordinator? {
        return nil
    }
    open func runCoordinator(for tabNdx: Int,
                             then block: DNSCoordinatorChildBoolBlock? = nil) {
        self.runCoordinator(for: tabNdx,
                            with: true,
                            then: block)
    }
    private func runCoordinator(for tabNdx: Int,
                                with changing: Bool,
                                then block: DNSCoordinatorChildBoolBlock? = nil) {
        guard let coordinator = self.coordinator(for: tabNdx) else {
            block?(nil, false)
            return
        }
        if coordinator.isRunning {
            if changing {
                self.changeCoordinator(to: tabNdx)
            }
            coordinator.update(from: self)
        } else {
            coordinator.start { (result: Bool) in }
            if changing {
                _ = DNSUIThread.run(after: 0.3) {
                    self.changeCoordinator(to: tabNdx)
                }
            }
        }
        block?(coordinator, true)
    }
    open func startCoordinators(andShow tabNdx: Int = 0) {
        Array(Int(0)..<self.numberOfTabs())
            .forEach { self.runCoordinator(for: $0, with: $0 == tabNdx) }
    }
    open func changeCoordinator(to tabNdx: Int) {
//        guard let coordinator = self.coordinator(for: tabNdx) else {
//            return
//        }
        DNSUIThread.run {
            self.reorderCoordinators()
//            let child = self.tabBarController?.children.first(where: {
//                var viewController = $0
//                if viewController is JKDrawer.DrawerNavigationController {
//                    viewController = viewController.children.first!
//                }
//                return (viewController as? DNSBaseStageViewController)?.baseConfigurator?.coordinator == coordinator
//            })
//            guard let child = child else {
//                return
//            }
//            guard let childNdx = self.tabBarController?.children.firstIndex(of: child) else {
//                return
//            }
            self.tabBarController?.selectedIndex = tabNdx
        }
    }
    open func reorderCoordinators() {
        DNSUIThread.run { }
    }

    // MARK: - Object lifecycle

    public init(with tabBarController: DNSUITabBarController? = nil) {
        self.tabBarController = tabBarController
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
                             then completionBlock: DNSCoordinatorResultsBlock?) {
        super.start(with: notification,
                    then: completionBlock)
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
            self.savedViewControllers = self.tabBarController?.viewControllers
            self.tabBarController?.setViewControllers([], animated: false)
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
                self.tabBarController?.setViewControllers(self.savedViewControllers!,
                                                          animated: true)
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
