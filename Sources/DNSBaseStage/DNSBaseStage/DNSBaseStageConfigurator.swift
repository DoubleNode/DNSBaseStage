//
//  DNSBaseStageConfigurator.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import DNSCore
import DNSCrashWorkers
import DNSProtocols
import UIKit

public typealias DNSBaseStageConfiguratorBlock = (String, Bool, DNSBaseStageBaseResults?) -> Void

open class DNSBaseStageConfigurator {
    // MARK: - Public Associated Type Properties
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

    // MARK: - VIP Objects Creation
    public var navigationController: UINavigationController?
    public var tabBarController: UITabBarController?

    public lazy var baseInteractor: DNSBaseStageInteractor = createInteractor()
    public lazy var basePresenter: DNSBaseStagePresenter = createPresenter()
    public lazy var baseViewController: DNSBaseStageViewController = createViewController()

    public var endBlock: DNSBaseStageConfiguratorBlock?

    public init() {
    }

    private func createInteractor() -> DNSBaseStageInteractor {
        return interactorType.init(configurator: self)
    }
    private func createPresenter() -> DNSBaseStagePresenter {
        return presenterType.init(configurator: self)
    }
    private func createViewController() -> DNSBaseStageViewController {
        let retval: DNSBaseStageViewController

        if Bundle.dnsLookupNibBundle(for: viewControllerType) != nil {
            return viewControllerType.init(nibName: String(describing: viewControllerType),
                                             bundle: Bundle.dnsLookupBundle(for: viewControllerType))
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable:next force_cast line_length
        return storyboard.instantiateViewController(withIdentifier: String(describing: viewControllerType)) as! DNSBaseStageViewController
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

    open func runStage(with coordinator: DNSCoordinator,
                       and displayType: DNSBaseStageDisplayType,
                       and initializationObject: DNSBaseStageBaseInitialization,
                       thenRun endBlock: DNSBaseStageConfiguratorBlock?) -> DNSBaseStageViewController {
        self.endBlock = endBlock
        self.initializationObject = initializationObject

        baseViewController.baseConfigurator = self
        baseViewController.stageTitle = String(describing: type(of: baseViewController))

        baseInteractor.startStage(with: displayType,
                                  and: initializationObject)

        return baseViewController
    }

    open func endStage(with intent: String,
                       and dataChanged: Bool,
                       and results: DNSBaseStageBaseResults?) {
        endBlock?(intent, dataChanged, results)
    }

    open func removeStage(displayType: DNSBaseStageDisplayType) {
        baseInteractor.removeStage(displayType: displayType)
    }
}
