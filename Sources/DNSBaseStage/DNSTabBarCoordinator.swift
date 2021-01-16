//
//  DNSTabBarCoordinator.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import DNSCoreThreading
import UIKit

open class DNSTabBarCoordinator: DNSCoordinator {
    public var tabBarController: UITabBarController?
    public var savedViewControllers: [UIViewController]? = []

    // MARK: - Tab management

    open func numberOfTabs() -> Int {
        return 0
    }
    open func coordinator(for tabNdx: Int) -> DNSCoordinator? {
        return nil
    }
    open func runCoordinator(for tabNdx: Int,
                             then block: DNSBoolBlock? = nil) {
        guard let coordinator = self.coordinator(for: tabNdx) else {
            block?(false)
            return
        }
        if coordinator.isRunning {
            self.changeCoordinator(to: tabNdx)
            coordinator.update(from: self)
        } else {
            coordinator.start { (result: Bool) in }
        }
        block?(true)
    }
    open func runCoordinators() {
        Array(Int(0)..<self.numberOfTabs())
            .forEach { self.runCoordinator(for: $0) }
    }
    open func changeCoordinator(to tabIndex: Int) {
        DNSUIThread.run {
            self.tabBarController?.selectedIndex = tabIndex
        }
    }

    // MARK: - Object lifecycle

    public init(with tabBarController: UITabBarController? = nil) {
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
