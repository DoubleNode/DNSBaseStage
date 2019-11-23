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
    associatedtype InteractorType: DNSBaseStageBusinessLogic
    associatedtype PresenterType: DNSBaseStagePresentationLogic
    associatedtype ViewControllerType: DNSBaseStageDisplayLogic
}

open class DNSBaseStageConfigurator {
    public typealias InteractorType = DNSBaseStageInteractor
    public typealias PresenterType = DNSBaseStagePresenter
    public typealias ViewControllerType = DNSBaseStageViewController

    // MARK: - Public Associated Type Properties
    public var initializationObject: DNSBaseStageBaseInitialization?

    // MARK: - VIP Objects Creation
    public var navigationController: UINavigationController?
    public var tabBarController: UITabBarController?

    public var interactor: InteractorType {
        return InteractorType.init(configurator: self)
    }
    public var presenter: PresenterType {
        return PresenterType.init(configurator: self)
    }
    public var viewController: ViewControllerType {
        let retval: ViewControllerType

        if Bundle.dnsLookupNibBundle(for: ViewControllerType.self) != nil {
            retval = ViewControllerType.init(nibName: String(describing: ViewControllerType.self),
                                             bundle: Bundle.dnsLookupBundle(for: ViewControllerType.self))
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // swiftlint:disable:next force_cast line_length
            retval = storyboard.instantiateViewController(withIdentifier: String(describing: ViewControllerType.self)) as! ViewControllerType
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
                       and initializationObject: DNSBaseStageBaseInitialization,
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
