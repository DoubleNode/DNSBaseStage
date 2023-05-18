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
    open func coordinatorNdx(for tabNdx: Int) -> Int {
        guard tabNdx < self.numberOfTabs() else { return 0 }
        return tabNdx
    }
    open func coordinator(for tabNdx: Int) -> DNSCoordinator? {
        return nil
    }
    open func resetCoordinator(for tabNdx: Int) {
        guard let coordinator = self.coordinator(for: tabNdx) else {
            return
        }
        guard coordinator.isRunning else {
            return
        }
        coordinator.reset()
    }
    open func resetCoordinators() {
        Array(Int(0)..<self.numberOfTabs())
            .forEach {
                self.resetCoordinator(for: $0)
            }
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
                _ = DNSUIThread.run(after: 0.5) { [weak self] in
                    guard let self else { return }
                    self.changeCoordinator(to: tabNdx)
                }
            }
        }
        block?(coordinator, true)
    }
    open func startCoordinators(andShow tabNdx: Int = 0) {
        Array(Int(0)..<self.numberOfTabs())
            .forEach {
                self.runCoordinator(for: $0, with: $0 == tabNdx)
            }
    }
    open func changeCoordinator(to tabNdx: Int) {
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            self.reorderCoordinators()
            let coordinatorNdx = self.coordinatorNdx(for: tabNdx)
            self.tabBarController?.selectedIndex = coordinatorNdx
        }
    }
    open func reorderCoordinators() {
//        DNSUIThread.run { }
    }
    func setBadgeValue(_ value: Int? = nil,
                       for tabNdx: Int) {
        guard tabNdx < self.numberOfTabs() else { return }
        DNSUIThread.run {
            if let tabItems = self.tabBarController?.tabBar.items {
                let tabItem = tabItems[tabNdx]
                if let value {
                    tabItem.badgeValue = "\(value)"
                } else {
                    tabItem.badgeValue = nil
                }
            }
        }
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
        DNSUIThread.run { [weak self] in
            guard let self else { return }
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
            DNSUIThread.run { [weak self] in
                guard let self else { return }
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
