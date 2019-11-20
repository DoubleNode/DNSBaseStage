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
    // MARK: - VIP Objects Creation
    open var _interactor: DNSBaseStageInteractor?           // swiftlint:disable:this identifier_name
    open var _presenter: DNSBaseStagePresenter?             // swiftlint:disable:this identifier_name
    open var _viewController: DNSBaseStageViewController?   // swiftlint:disable:this identifier_name

    public var navigationController: UINavigationController?
    public var tabBarController: UITabBarController?

    open var interactorClassType: DNSBaseStageInteractor.Type {
        return DNSBaseStageInteractor.self
    }
    open var presenterClassType: DNSBaseStagePresenter.Type {
        return DNSBaseStagePresenter.self
    }
    open var viewControllerClassType: DNSBaseStageViewController.Type {
        return DNSBaseStageViewController.self
    }

    var interactor: DNSBaseStageInteractor {
        if _interactor == nil {
            _interactor = self.createInteractor(for: interactorClassType)
        }
        return _interactor!
    }
    var presenter: DNSBaseStagePresenter {
        if _presenter == nil {
            _presenter = self.createPresenter(for: presenterClassType)
        }
        return _presenter!
    }
    var viewController: DNSBaseStageViewController {
        if _viewController == nil {
            _viewController = self.createViewController(for: viewControllerClassType)
        }
        return _viewController!
    }

    func createInteractor(for classType: DNSBaseStageInteractor.Type) -> DNSBaseStageInteractor {
        return classType.init(configurator: self)
    }
    func createPresenter(for classType: DNSBaseStagePresenter.Type) -> DNSBaseStagePresenter {
        return classType.init(configurator: self)
    }
    func createViewController(for classType: DNSBaseStageViewController.Type) -> DNSBaseStageViewController {
        let retval: DNSBaseStageViewController

        if Bundle.dnsLookupNibBundle(for: classType) != nil {
            retval = classType.init(nibName: String(describing: classType),
                                    bundle: Bundle.dnsLookupBundle(for: classType))
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // swiftlint:disable:next force_cast line_length
            retval = storyboard.instantiateViewController(withIdentifier: String(describing: classType)) as! DNSBaseStageViewController
        }

        retval.configurator = self
        return retval
    }

    public var endBlock:    DNSBaseStageConfiguratorBlock?

    public init() {
    }

    open func configureStage(_ viewController: DNSBaseStageViewController) {
        // Connect VIP Objects
        self.interactor.basePresenter   = self.presenter
        self.presenter.baseDisplay      = viewController
        viewController.baseInteractor   = self.interactor

        // Interactor Dependency Injection
        self.interactor.analyticsWorker = WKRCrashAnalyticsWorker.init()

        // Presenter Dependency Injection
        self.presenter.analyticsWorker  = WKRCrashAnalyticsWorker.init()

        // ViewController Dependency Injection
        viewController.analyticsWorker = WKRCrashAnalyticsWorker.init()
    }

    open func runStage(with coordinator: DNSCoordinator,
                       and displayType: DNSBaseStageDisplayType,
                       and initialization: DNSBaseStageBaseInitialization,
                       thenRun endBlock: DNSBaseStageConfiguratorBlock?) -> DNSBaseStageViewController {
        self.endBlock   = endBlock

        self.viewController.stageTitle = String(describing: type(of: self))

        self.interactor.startStage(with: displayType, and: initialization)

        return self.viewController
    }

    open func endStage(with intent: String, and dataChanged: Bool, and results: DNSBaseStageBaseResults?) {
        endBlock?(intent, dataChanged, results)
    }

    open func removeStage(displayType: DNSBaseStageDisplayType) {
        interactor.removeStage(displayType: displayType)
    }
}
