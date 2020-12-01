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
        self.commonStart()
    }
    override open func start(with connectionOptions: UIScene.ConnectionOptions,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: connectionOptions,
                    then: completionBlock)
        self.commonStart()
    }
    override open func start(with openURLContexts: Set<UIOpenURLContext>,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: openURLContexts,
                    then: completionBlock)
        self.commonStart()
    }
    override open func start(with userActivity: NSUserActivity,
                             then completionBlock: DNSCoordinatorBoolBlock?) {
        super.start(with: userActivity,
                    then: completionBlock)
        self.commonStart()
    }

    override open func start(then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(then: completionResultsBlock)
        self.commonStart()
    }
    override open func start(with connectionOptions: UIScene.ConnectionOptions,
                             then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(with: connectionOptions,
                    then: completionResultsBlock)
        self.commonStart()
    }
    override open func start(with openURLContexts: Set<UIOpenURLContext>,
                             then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(with: openURLContexts,
                    then: completionResultsBlock)
        self.commonStart()
    }
    override open func start(with userActivity: NSUserActivity,
                             then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        super.start(with: userActivity,
                    then: completionResultsBlock)
        self.commonStart()
    }
    open func commonStart() {
        DNSUIThread.run {
            self.savedViewControllers = self.navigationController?.viewControllers
        }
    }

    override open func reset() {
        super.reset()

        self.savedViewControllers = nil
    }
    override open func stop(with results: DNSBaseStageBaseResults? = nil) {
        if self.savedViewControllers != nil {
            DNSUIThread.run {
                self.navigationController?.setViewControllers(self.savedViewControllers!,
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
