//
//  DNSBaseStageInteractor.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Combine
import DNSProtocols
import Foundation

public protocol DNSBaseStageBusinessLogic: class {
    // MARK: - Outgoing Pipelines -
    var stageStartPublisher: PassthroughSubject<DNSBaseStageModels.Start.Response, Never> { get }
    var stageEndPublisher: PassthroughSubject<DNSBaseStageModels.Finish.Response, Never> { get }

    var confirmationPublisher: PassthroughSubject<DNSBaseStageModels.Confirmation.Response, Never> { get }
    var dismissPublisher: PassthroughSubject<DNSBaseStageModels.Dismiss.Response, Never> { get }
    var errorPublisher: PassthroughSubject<DNSBaseStageModels.Error.Response, Never> { get }
    var messagePublisher: PassthroughSubject<DNSBaseStageModels.Message.Response, Never> { get }
    var spinnerPublisher: PassthroughSubject<DNSBaseStageModels.Spinner.Response, Never> { get }
    var titlePublisher: PassthroughSubject<DNSBaseStageModels.Title.Response, Never> { get }
}

open class DNSBaseStageInteractor: NSObject, DNSBaseStageBusinessLogic {
    // MARK: - Public Associated Type Properties -
    public var baseConfigurator: DNSBaseStageConfigurator?
    public var baseInitializationObject: DNSBaseStageBaseInitialization?

    // MARK: - Outgoing Pipelines -
    public let stageStartPublisher = PassthroughSubject<DNSBaseStageModels.Start.Response, Never>()
    public let stageEndPublisher = PassthroughSubject<DNSBaseStageModels.Finish.Response, Never>()

    public let confirmationPublisher = PassthroughSubject<DNSBaseStageModels.Confirmation.Response, Never>()
    public let dismissPublisher = PassthroughSubject<DNSBaseStageModels.Dismiss.Response, Never>()
    public let errorPublisher = PassthroughSubject<DNSBaseStageModels.Error.Response, Never>()
    public let messagePublisher = PassthroughSubject<DNSBaseStageModels.Message.Response, Never>()
    public let spinnerPublisher = PassthroughSubject<DNSBaseStageModels.Spinner.Response, Never>()
    public let titlePublisher = PassthroughSubject<DNSBaseStageModels.Title.Response, Never>()

    // MARK: - Incoming Pipelines -
    var stageDidAppearSubscriber: AnyCancellable?
    var stageDidCloseSubscriber: AnyCancellable?
    var stageDidDisappearSubscriber: AnyCancellable?
    var stageDidHideSubscriber: AnyCancellable?
    var stageDidLoadSubscriber: AnyCancellable?
    var stageWillAppearSubscriber: AnyCancellable?
    var stageWillDisappearSubscriber: AnyCancellable?
    var stageWillHideSubscriber: AnyCancellable?

    var closeNavBarButtonSubscriber: AnyCancellable?
    var confirmationSubscriber: AnyCancellable?
    var errorOccurredSubscriber: AnyCancellable?
    var webStartNavigationSubscriber: AnyCancellable?
    var webFinishNavigationSubscriber: AnyCancellable?
    var webErrorNavigationSubscriber: AnyCancellable?
    var webLoadProgressSubscriber: AnyCancellable?

    open func subscribe(to baseViewController: DNSBaseStageDisplayLogic) {
        stageDidAppearSubscriber = baseViewController.stageDidAppearPublisher
            .sink { request in self.stageDidAppear(request) }
        stageDidCloseSubscriber = baseViewController.stageDidClosePublisher
            .sink { request in self.stageDidClose(request) }
        stageDidDisappearSubscriber = baseViewController.stageDidDisappearPublisher
            .sink { request in self.stageDidDisappear(request) }
        stageDidHideSubscriber = baseViewController.stageDidHidePublisher
            .sink { request in self.stageDidHide(request) }
        stageDidLoadSubscriber = baseViewController.stageDidLoadPublisher
            .sink { request in self.stageDidLoad(request) }
        stageWillAppearSubscriber = baseViewController.stageWillAppearPublisher
            .sink { request in self.stageWillAppear(request) }
        stageWillDisappearSubscriber = baseViewController.stageWillDisappearPublisher
            .sink { request in self.stageWillDisappear(request) }
        stageWillHideSubscriber = baseViewController.stageWillHidePublisher
            .sink { request in self.stageWillHide(request) }

        closeNavBarButtonSubscriber = baseViewController.closeNavBarButtonPublisher
            .sink { request in self.doCloseNavBar(request) }
        confirmationSubscriber = baseViewController.confirmationPublisher
            .sink { request in self.doConfirmation(request) }
        errorOccurredSubscriber = baseViewController.errorOccurredPublisher
            .sink { request in self.doErrorOccurred(request) }
        webStartNavigationSubscriber = baseViewController.webStartNavigationPublisher
            .sink { request in self.doWebStartNavigation(request) }
        webFinishNavigationSubscriber = baseViewController.webFinishNavigationPublisher
            .sink { request in self.doWebFinishNavigation(request) }
        webErrorNavigationSubscriber = baseViewController.webErrorNavigationPublisher
            .sink { request in self.doWebErrorNavigation(request) }
        webLoadProgressSubscriber = baseViewController.webLoadProgressPublisher
            .sink { request in self.doWebLoadProgress(request) }
    }

    // MARK: - Private Properties -
    var hasStageEnded:  Bool = false

    // MARK: - Public Properties -
    public var displayType: DNSBaseStage.DisplayType?
    public var displayOptions: DNSBaseStageDisplayOptions = []

    // MARK: - Workers -
    public var analyticsWorker: PTCLAnalytics_Protocol?

    required public init(configurator: DNSBaseStageConfigurator) {
        self.baseConfigurator = configurator
    }

    open func startStage(with displayType: DNSBaseStage.DisplayType,
                         with displayOptions: DNSBaseStageDisplayOptions = [],
                         and initialization: DNSBaseStageBaseInitialization?) {
        self.displayType = displayType
        self.displayOptions = displayOptions
        self.baseInitializationObject = initialization

        stageStartPublisher.send(DNSBaseStageModels.Start.Response(displayType: displayType,
                                                                   displayOptions: displayOptions))
    }

    open func updateStage(with initializationObject: DNSBaseStageBaseInitialization) {
        self.baseInitializationObject = initializationObject
    }

    open func shouldEndStage() -> Bool {
        let retval = !self.hasStageEnded

        self.hasStageEnded = true
        return retval
    }

    open func endStage(with intent: String, and dataChanged: Bool, and results: DNSBaseStageBaseResults?) {
        self.endStage(conditionally: false,
                      with: intent,
                      and: dataChanged,
                      and: results)
    }

    open func endStage(conditionally: Bool,
                       with intent: String,
                       and dataChanged: Bool,
                       and results: DNSBaseStageBaseResults?) {
        let shouldEndStage = self.shouldEndStage()
        if conditionally &&
            !shouldEndStage {
            return
        }

        self.baseConfigurator?.endStage(with: intent,
                                        and: dataChanged,
                                        and: results)
    }

    open func removeStage() {
        guard self.displayType != nil else { return }
        stageEndPublisher.send(DNSBaseStageModels.Finish.Response(displayType: self.displayType!))
    }

    open func send(intent: String,
                   with dataChanged: Bool,
                   and results: DNSBaseStageBaseResults?) {
        self.baseConfigurator?.send(intent: intent,
                                    with: dataChanged,
                                    and: results)
    }

    // MARK: - Stage Lifecycle -
    
    open func stageDidAppear(_ request: DNSBaseStageBaseRequest) {
        self.hasStageEnded  = false
    }
    open func stageDidClose(_ request: DNSBaseStageBaseRequest) {
        self.endStage(conditionally: true, with: "", and: false, and: nil)
    }
    open func stageDidDisappear(_ request: DNSBaseStageBaseRequest) {
    }
    open func stageDidHide(_ request: DNSBaseStageBaseRequest) {
    }
    open func stageDidLoad(_ request: DNSBaseStageBaseRequest) {
    }
    open func stageWillAppear(_ request: DNSBaseStageBaseRequest) {
        try? self.analyticsWorker?.doScreen(screenTitle: String(describing: self.baseConfigurator!))
    }
    open func stageWillDisappear(_ request: DNSBaseStageBaseRequest) {
    }
    open func stageWillHide(_ request: DNSBaseStageBaseRequest) {
    }
    
    // MARK: - Business Logic -
    
    open func doCloseNavBar(_ request: DNSBaseStageModels.Base.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        self.endStage(conditionally: true, with: "", and: false, and: nil)
    }
    open func doConfirmation(_ request: DNSBaseStageModels.Confirmation.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doErrorOccurred(_ request: DNSBaseStageModels.Error.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        var response = DNSBaseStageModels.Error.Response(error: request.error,
                                                         style: .popup,
                                                         title: request.title)
        response.okayButton = request.okayButton
        self.errorPublisher.send(response)
    }

    open func doWebStartNavigation(_ request: DNSBaseStageModels.Webpage.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doWebFinishNavigation(_ request: DNSBaseStageModels.Webpage.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doWebErrorNavigation(_ request: DNSBaseStageModels.WebpageError.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        self.errorPublisher.send(DNSBaseStageModels.Error.Response(error: request.error,
                                                                   style: .popup,
                                                                   title: "Web Error"))
    }
    open func doWebLoadProgress(_ request: DNSBaseStageModels.WebpageProgress.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
}
