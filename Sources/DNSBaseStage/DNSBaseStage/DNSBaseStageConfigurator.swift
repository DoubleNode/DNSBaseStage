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
    associatedtype InitializationObjectType: DNSBaseStageBaseInitialization
    associatedtype InteractorType: DNSBaseStageBusinessLogic
    associatedtype PresenterType: DNSBaseStagePresentationLogic
    associatedtype ViewControllerType: DNSBaseStageDisplayLogic

    var initializationObject: InitializationObjectType? { get }
    var interactorType: InteractorType.Type { get }
    var presenterType: PresenterType.Type { get }
    var viewControllerType: ViewControllerType.Type { get }
}

open class DNSBaseStageConfigurator {
    public typealias InitializationObjectType = DNSBaseStageBaseInitialization
    public typealias InteractorType = DNSBaseStageInteractor
    public typealias PresenterType = DNSBaseStagePresenter
    public typealias ViewControllerType = DNSBaseStageViewController

    // MARK: - Public Associated Type Properties
    open var initializationObject: InitializationObjectType?

    open var interactorType: InteractorType.Type {
        return InteractorType.self
    }
    open var presenterType: PresenterType.Type {
        return PresenterType.self
    }
    open var viewControllerType: ViewControllerType.Type {
        return ViewControllerType.self
    }

    // MARK: - VIP Objects Creation
    public var navigationController: UINavigationController?
    public var tabBarController: UITabBarController?

    public var interactor: InteractorType {
        return interactorType.init(configurator: self)
    }
    public var presenter: PresenterType {
        return presenterType.init(configurator: self)
    }
    public var viewController: ViewControllerType {
        let retval: ViewControllerType

        if Bundle.dnsLookupNibBundle(for: viewControllerType) != nil {
            retval = viewControllerType.init(nibName: String(describing: viewControllerType),
                                             bundle: Bundle.dnsLookupBundle(for: viewControllerType))
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // swiftlint:disable:next force_cast line_length
            retval = storyboard.instantiateViewController(withIdentifier: String(describing: viewControllerType)) as! ViewControllerType
        }

        retval.configurator = self
        return retval
    }

    public var endBlock: DNSBaseStageConfiguratorBlock?

    public init() {
    }

    open func configureStage(_ viewController: ViewControllerType) {
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
                       and initializationObject: InitializationObjectType,
                       thenRun endBlock: DNSBaseStageConfiguratorBlock?) -> ViewControllerType {
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
