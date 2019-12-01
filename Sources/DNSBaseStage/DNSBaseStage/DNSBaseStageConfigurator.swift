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

public protocol DNSBaseStageConfiguratorLogic: class {
    associatedtype InitializationObjectType
    associatedtype InteractorType
    associatedtype PresenterType
    associatedtype ViewControllerType

    var initializationObject: InitializationObjectType? { get }
    var interactorType: InteractorType.Type { get }
    var presenterType: PresenterType.Type { get }
    var viewControllerType: ViewControllerType.Type { get }
}

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

    public var interactor: DNSBaseStageInteractor {
        return interactorType.init(configurator: self)
    }
    public var presenter: DNSBaseStagePresenter {
        return presenterType.init(configurator: self)
    }
    public var viewController: DNSBaseStageViewController {
        let retval: DNSBaseStageViewController

        if Bundle.dnsLookupNibBundle(for: viewControllerType) != nil {
            retval = viewControllerType.init(nibName: String(describing: viewControllerType),
                                             bundle: Bundle.dnsLookupBundle(for: viewControllerType))
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // swiftlint:disable:next force_cast line_length
            retval = storyboard.instantiateViewController(withIdentifier: String(describing: viewControllerType)) as! DNSBaseStageViewController
        }

        retval.configurator = self
        return retval
    }

    public var endBlock: DNSBaseStageConfiguratorBlock?

    public init() {
    }

    open func configureStage(_ viewController: DNSBaseStageViewController) {
        // Connect VIP Object Publishers
        interactor.subscribe(to: viewController)
        presenter.subscribe(to: self.interactor)
        viewController.subscribe(to: self.presenter)

        // Interactor Dependency Injection
        interactor.analyticsWorker = WKRCrashAnalyticsWorker.init()

        // Presenter Dependency Injection
        presenter.analyticsWorker  = WKRCrashAnalyticsWorker.init()

        // ViewController Dependency Injection
        viewController.analyticsWorker = WKRCrashAnalyticsWorker.init()
    }

    open func runStage(with coordinator: DNSCoordinator,
                       and displayType: DNSBaseStageDisplayType,
                       and initializationObject: DNSBaseStageBaseInitialization,
                       thenRun endBlock: DNSBaseStageConfiguratorBlock?) -> DNSBaseStageViewController {
        self.endBlock = endBlock
        self.initializationObject = initializationObject

        viewController.stageTitle = String(describing: type(of: viewController))

        interactor.startStage(with: displayType,
                              and: initializationObject)

        return viewController
    }

    open func endStage(with intent: String,
                       and dataChanged: Bool,
                       and results: DNSBaseStageBaseResults?) {
        endBlock?(intent, dataChanged, results)
    }

    open func removeStage(displayType: DNSBaseStageDisplayType) {
        interactor.removeStage(displayType: displayType)
    }
}
