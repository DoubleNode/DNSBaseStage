//
//  DNSBaseStageConfigurator.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import DNSCoreThreading
import DNSCrashWorkers
import DNSProtocols
import UIKit

// (end: Bool, intent: String, dataChanged: Bool, results: DNSBaseStageBaseResults?)
public typealias DNSBaseStageConfiguratorBlock = (Bool, String, Bool, DNSBaseStageBaseResults?) -> Void

open class DNSBaseStageConfigurator {
    public typealias BaseStage = DNSBaseStage
    
    // MARK: - Public Associated Type Properties -
    open var initializationObject: DNSBaseStageBaseInitialization?

    open var interactorType: BaseStage.Interactor.Type {
        return BaseStage.Interactor.self
    }
    open var presenterType: BaseStage.Presenter.Type {
        return BaseStage.Presenter.self
    }
    open var viewControllerType: BaseStage.ViewController.Type {
        return BaseStage.ViewController.self
    }

    // MARK: - VIP Objects Creation -
    public var navDrawerController: DNSUINavDrawerController?
    public var navigationController: DNSUINavigationController?
    public var parentConfigurator: BaseStage.Configurator?
    public var rootViewController: BaseStage.ViewController?
    public var tabBarController: DNSUITabBarController?

    public lazy var baseInteractor: BaseStage.Interactor = createInteractor()
    public lazy var basePresenter: BaseStage.Presenter = createPresenter()
    public lazy var baseViewController: BaseStage.ViewController = createViewController()

    public var coordinator: DNSCoordinator?
    public var intentBlock: DNSBaseStageConfiguratorBlock?

    public init() {
    }

    private func createInteractor() -> BaseStage.Interactor {
        return interactorType.init(configurator: self)
    }
    private func createPresenter() -> BaseStage.Presenter {
        return presenterType.init(configurator: self)
    }
    private func createViewController() -> BaseStage.ViewController {
        if Bundle.dnsLookupNibBundle(for: viewControllerType) != nil {
            var retval: BaseStage.ViewController?
            DNSUIThread.run {
                retval = self.viewControllerType
                    .init(nibName: String(describing: self.viewControllerType),
                          bundle: Bundle.dnsLookupBundle(for: self.viewControllerType))
            }
            return retval!
        }

        var retval: BaseStage.ViewController?
        DNSUIThread.run {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // swiftlint:disable:next force_cast line_length
            retval = storyboard.instantiateViewController(withIdentifier: String(describing: self.viewControllerType)) as? BaseStage.ViewController
        }
        return retval!
    }
    open func configureStage() {
        // Interactor Defaults
        BaseStage.Models.defaults = BaseStage.Models.Defaults()

        // Connect VIP Object Publishers
        baseInteractor.subscribe(to: baseViewController)
        basePresenter.subscribe(to: baseInteractor)
        baseViewController.subscribe(to: basePresenter)

        // Interactor Dependency Injection
        baseInteractor.analyticsWorker = WKRCrashAnalyticsWorker.init()

        // Presenter Dependency Injection
        basePresenter.analyticsWorker  = WKRCrashAnalyticsWorker.init()

        // ViewController Dependency Injection
        baseViewController.analyticsWorker = WKRCrashAnalyticsWorker.init()
    }
    open func endStage(with intent: String,
                       and dataChanged: Bool,
                       and results: DNSBaseStageBaseResults?) {
        _ = DNSUIThread.run(after: 0.3) {
            self.intentBlock?(true, intent, dataChanged, results)
            self.baseInteractor.removeStage()
        }
    }
    open func runStage(with coordinator: DNSCoordinator,
                       and displayMode: BaseStage.Display.Mode,
                       with displayOptions: BaseStage.Display.Options = [],
                       and initializationObject: DNSBaseStageBaseInitialization,
                       thenRun intentBlock: DNSBaseStageConfiguratorBlock?) -> BaseStage.ViewController {
        self.coordinator = coordinator
        self.intentBlock = intentBlock
        self.initializationObject = initializationObject
        self.rootViewController = coordinator.defaultRootViewController

        baseViewController.baseConfigurator = self
        baseViewController.stageTitle = String(describing: type(of: baseViewController))

        baseInteractor.startStage(with: displayMode,
                                  with: displayOptions,
                                  and: initializationObject)

        return baseViewController
    }
    open func updateStage(with initializationObject: DNSBaseStageBaseInitialization) {
        self.initializationObject = initializationObject
        baseInteractor.updateStage(with: initializationObject)
    }
    open func send(intent: String,
                   with dataChanged: Bool,
                   and results: DNSBaseStageBaseResults?) {
        intentBlock?(false, intent, dataChanged, results)
    }
}
