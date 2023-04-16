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
    
    var started = false
    var ending = false
    
    // MARK: - Public Associated Type Properties -
    open lazy var analyticsStageTitle: String = {
        String(describing: self)
    }()
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

    public var isRunning: Bool {
        return started && !ending
    }
    
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
            DNSUIThread.run { [weak self] in
                guard let self else { return }
                retval = self.viewControllerType
                    .init(nibName: String(describing: self.viewControllerType),
                          bundle: Bundle.dnsLookupBundle(for: self.viewControllerType))
            }
            return retval!
        }

        var retval: BaseStage.ViewController?
        DNSUIThread.run { [weak self] in
            guard let self else { return }
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
        baseInteractor.wkrAnalytics = WKRCrashAnalytics()

        // Presenter Dependency Injection
        basePresenter.wkrAnalytics  = WKRCrashAnalytics()

        // ViewController Dependency Injection
        baseViewController.wkrAnalytics = WKRCrashAnalytics()
    }
    open func endStage(with intent: String,
                       and dataChanged: Bool,
                       and results: DNSBaseStageBaseResults?) {
        guard !self.ending else { return }
        self.ending = true
        _ = DNSUIThread.run(after: 0.5) { [weak self] in
            guard let self else { return }
            self.intentBlock?(true, intent, dataChanged, results)
            self.baseInteractor.removeStage()
        }
    }
    open func restartEnding() {
        self.ending = false
    }
    open func runStage(with coordinator: DNSCoordinator,
                       and displayMode: BaseStage.Display.Mode,
                       with displayOptions: BaseStage.Display.Options = [],
                       and initializationObject: DNSBaseStageBaseInitialization,
                       thenRun intentBlock: DNSBaseStageConfiguratorBlock?) -> BaseStage.ViewController {
        self.restartEnding()
        self.coordinator = coordinator
        self.intentBlock = intentBlock
        self.initializationObject = initializationObject
        self.rootViewController = coordinator.defaultRootViewController

        baseViewController.baseConfigurator = self
        baseViewController.stageTitle = String(describing: type(of: baseViewController))

        baseInteractor.startStage(with: displayMode,
                                  with: displayOptions,
                                  and: initializationObject)

        self.started = true
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
