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
    // MARK: - Public Associated Type Properties -
    open var initializationObject: DNSBaseStageBaseInitialization?

    open var interactorType: DNSBaseStageInteractor.Type {
        return DNSBaseStageInteractor.self
    }
    open var presenterType: DNSBaseStagePresenter.Type {
        return DNSBaseStagePresenter.self
    }
    open var viewControllerType: DNSBaseStageViewController.Type {
        return DNSBaseStageViewController.self
    }

    // MARK: - VIP Objects Creation -
    public var parentConfigurator: DNSBaseStageConfigurator?
    public var navigationController: UINavigationController?
    public var tabBarController: UITabBarController?

    public lazy var baseInteractor: DNSBaseStageInteractor = createInteractor()
    public lazy var basePresenter: DNSBaseStagePresenter = createPresenter()
    public lazy var baseViewController: DNSBaseStageViewController = createViewController()

    public var intentBlock: DNSBaseStageConfiguratorBlock?

    public init() {
    }

    private func createInteractor() -> DNSBaseStageInteractor {
        return interactorType.init(configurator: self)
    }
    private func createPresenter() -> DNSBaseStagePresenter {
        return presenterType.init(configurator: self)
    }
    private func createViewController() -> DNSBaseStageViewController {
        if Bundle.dnsLookupNibBundle(for: viewControllerType) != nil {
            var retval: DNSBaseStageViewController?
            DNSUIThread.run {
                retval = self.viewControllerType.init(nibName: String(describing: self.viewControllerType),
                                                      bundle: Bundle.dnsLookupBundle(for: self.viewControllerType))
            }
            return retval!
        }

        var retval: DNSBaseStageViewController?
        DNSUIThread.run {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // swiftlint:disable:next force_cast line_length
            retval = storyboard.instantiateViewController(withIdentifier: String(describing: self.viewControllerType)) as? DNSBaseStageViewController
        }
        return retval!
    }

    open func configureStage() {
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
                       and displayType: DNSBaseStage.DisplayType,
                       with displayOptions: DNSBaseStageDisplayOptions = [],
                       and initializationObject: DNSBaseStageBaseInitialization,
                       thenRun intentBlock: DNSBaseStageConfiguratorBlock?) -> DNSBaseStageViewController {
        self.intentBlock = intentBlock
        self.initializationObject = initializationObject

        baseViewController.baseConfigurator = self
        baseViewController.stageTitle = String(describing: type(of: baseViewController))

        baseInteractor.startStage(with: displayType,
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
