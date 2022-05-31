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

public protocol DNSBaseStageBusinessLogic: AnyObject {
    typealias BaseStage = DNSBaseStage
    
    // MARK: - Outgoing Pipelines -
    var stageStartPublisher: PassthroughSubject<BaseStage.Models.Start.Response, Never> { get }
    var stageEndPublisher: PassthroughSubject<BaseStage.Models.Finish.Response, Never> { get }

    var confirmationPublisher: PassthroughSubject<BaseStage.Models.Confirmation.Response, Never> { get }
    var dismissPublisher: PassthroughSubject<BaseStage.Models.Dismiss.Response, Never> { get }
    var errorPublisher: PassthroughSubject<BaseStage.Models.ErrorMessage.Response, Never> { get }
    var messagePublisher: PassthroughSubject<BaseStage.Models.Message.Response, Never> { get }
    var spinnerPublisher: PassthroughSubject<BaseStage.Models.Spinner.Response, Never> { get }
    var titlePublisher: PassthroughSubject<BaseStage.Models.Title.Response, Never> { get }
}

open class DNSBaseStageInteractor: NSObject, DNSBaseStageBusinessLogic {
    public typealias BaseStage = DNSBaseStage
    
    // MARK: - Public Associated Type Properties -
    public var baseConfigurator: BaseStage.Configurator?
    public var baseInitializationObject: DNSBaseStageBaseInitialization?

    // MARK: - Outgoing Pipelines -
    public let stageStartPublisher = PassthroughSubject<BaseStage.Models.Start.Response, Never>()
    public let stageEndPublisher = PassthroughSubject<BaseStage.Models.Finish.Response, Never>()

    public let confirmationPublisher = PassthroughSubject<BaseStage.Models.Confirmation.Response, Never>()
    public let dismissPublisher = PassthroughSubject<BaseStage.Models.Dismiss.Response, Never>()
    public let errorPublisher = PassthroughSubject<BaseStage.Models.ErrorMessage.Response, Never>()
    public let messagePublisher = PassthroughSubject<BaseStage.Models.Message.Response, Never>()
    public let spinnerPublisher = PassthroughSubject<BaseStage.Models.Spinner.Response, Never>()
    public let titlePublisher = PassthroughSubject<BaseStage.Models.Title.Response, Never>()

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
    var messageSubscriber: AnyCancellable?
    var webStartNavigationSubscriber: AnyCancellable?
    var webFinishNavigationSubscriber: AnyCancellable?
    var webErrorNavigationSubscriber: AnyCancellable?
    var webLoadProgressSubscriber: AnyCancellable?

    open func subscribe(to baseViewController: BaseStage.Logic.Display) {
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
        messageSubscriber = baseViewController.messageDonePublisher
            .sink { request in self.doMessageDone(request) }
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
    public var displayMode: BaseStage.Display.Mode?
    public var displayOptions: BaseStage.Display.Options = []

    // MARK: - Workers -
    public var analyticsWorker: PTCLAnalytics?

    required public init(configurator: BaseStage.Configurator) {
        self.baseConfigurator = configurator
    }
    open func startStage(with displayMode: BaseStage.Display.Mode,
                         with displayOptions: BaseStage.Display.Options = [],
                         and initialization: DNSBaseStageBaseInitialization?) {
        self.displayMode = displayMode
        self.displayOptions = displayOptions
        self.baseInitializationObject = initialization
        stageStartPublisher.send(BaseStage.Models.Start.Response(displayMode: displayMode,
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
    open func endStage(with intent: String,
                       and dataChanged: Bool,
                       and results: DNSBaseStageBaseResults?) {
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
        guard !conditionally || !shouldEndStage else { return }
        self.baseConfigurator?.endStage(with: intent,
                                        and: dataChanged,
                                        and: results)
    }
    open func removeStage() {
        guard self.displayMode != nil else { return }
        stageEndPublisher.send(BaseStage.Models.Finish.Response(displayMode: self.displayMode!))
    }
    open func send(intent: String,
                   with dataChanged: Bool,
                   and results: DNSBaseStageBaseResults?) {
        self.baseConfigurator?.send(intent: intent,
                                    with: dataChanged,
                                    and: results)
    }

    // MARK: - Stage Lifecycle -
    open func stageDidAppear(_ request: BaseStage.Models.Base.Request) {
        self.hasStageEnded  = false
    }
    open func stageDidClose(_ request: BaseStage.Models.Base.Request) {
        self.endStage(conditionally: true, with: "", and: false, and: nil)
    }
    open func stageDidDisappear(_ request: BaseStage.Models.Base.Request) {
    }
    open func stageDidHide(_ request: BaseStage.Models.Base.Request) {
    }
    open func stageDidLoad(_ request: BaseStage.Models.Base.Request) {
    }
    open func stageWillAppear(_ request: BaseStage.Models.Base.Request) {
        try? self.analyticsWorker?.doScreen(screenTitle: String(describing: self.baseConfigurator!))
    }
    open func stageWillDisappear(_ request: BaseStage.Models.Base.Request) {
    }
    open func stageWillHide(_ request: BaseStage.Models.Base.Request) {
    }
    
    // MARK: - Business Logic -
    open func doCloseNavBar(_ request: BaseStage.Models.Base.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
        self.endStage(conditionally: true, with: "", and: false, and: nil)
    }
    open func doConfirmation(_ request: BaseStage.Models.Confirmation.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doErrorOccurred(_ request: BaseStage.Models.ErrorMessage.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
        var response = BaseStage.Models.ErrorMessage.Response(error: request.error,
                                                              style: .popup,
                                                              title: request.title)
        response.okayButton = request.okayButton
        self.errorPublisher.send(response)
    }
    open func doMessageDone(_ request: BaseStage.Models.Message.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }

    open func doWebStartNavigation(_ request: BaseStage.Models.Webpage.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doWebFinishNavigation(_ request: BaseStage.Models.Webpage.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doWebErrorNavigation(_ request: BaseStage.Models.WebpageError.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
        let response = BaseStage.Models.ErrorMessage.Response(error: request.error,
                                                              style: .popup,
                                                              title: "Web Error")
        self.errorPublisher.send(response)
    }
    open func doWebLoadProgress(_ request: BaseStage.Models.WebpageProgress.Request) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    
    // MARK: - Shortcut Methods
    open func spinner(show: Bool,
                      forceReset: Bool = false) {
        var response = BaseStage.Models.Spinner.Response(show: show)
        response.forceReset = forceReset
        self.spinnerPublisher.send(response)
    }
}
