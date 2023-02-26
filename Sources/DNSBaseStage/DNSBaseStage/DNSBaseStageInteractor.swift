//
//  DNSBaseStageInteractor.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Combine
import DNSCoreThreading
import DNSCrashWorkers
import DNSProtocols
import Foundation

public protocol DNSBaseStageBusinessLogic: AnyObject {
    typealias BaseStage = DNSBaseStage
    
    // MARK: - Outgoing Pipelines -
    var stageStartPublisher: PassthroughSubject<BaseStage.Models.Start.Response, Never> { get }
    var stageEndPublisher: PassthroughSubject<BaseStage.Models.Finish.Response, Never> { get }

    var confirmationPublisher: PassthroughSubject<BaseStage.Models.Confirmation.Response, Never> { get }
    var disabledPublisher: PassthroughSubject<BaseStage.Models.Disabled.Response, Never> { get }
    var dismissPublisher: PassthroughSubject<BaseStage.Models.Dismiss.Response, Never> { get }
    var errorPublisher: PassthroughSubject<BaseStage.Models.ErrorMessage.Response, Never> { get }
    var messagePublisher: PassthroughSubject<BaseStage.Models.Message.Response, Never> { get }
    var resetPublisher: PassthroughSubject<BaseStage.Models.Base.Response, Never> { get }
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
    public let disabledPublisher = PassthroughSubject<BaseStage.Models.Disabled.Response, Never>()
    public let dismissPublisher = PassthroughSubject<BaseStage.Models.Dismiss.Response, Never>()
    public let errorPublisher = PassthroughSubject<BaseStage.Models.ErrorMessage.Response, Never>()
    public let messagePublisher = PassthroughSubject<BaseStage.Models.Message.Response, Never>()
    public let resetPublisher = PassthroughSubject<BaseStage.Models.Base.Response, Never>()
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

    var closeActionSubscriber: AnyCancellable?
    var confirmationSubscriber: AnyCancellable?
    var errorOccurredSubscriber: AnyCancellable?
    var messageSubscriber: AnyCancellable?
    var webStartNavigationSubscriber: AnyCancellable?
    var webFinishNavigationSubscriber: AnyCancellable?
    var webErrorNavigationSubscriber: AnyCancellable?
    var webLoadProgressSubscriber: AnyCancellable?

    open var subscribers: [AnyCancellable] = []
    open func subscribe(to baseViewController: BaseStage.Logic.Display) {
        subscribers.removeAll()
        stageDidAppearSubscriber = baseViewController.stageDidAppearPublisher
            .sink { [weak self] request in self?.stageDidAppear(request) }
        stageDidCloseSubscriber = baseViewController.stageDidClosePublisher
            .sink { [weak self] request in self?.stageDidClose(request) }
        stageDidDisappearSubscriber = baseViewController.stageDidDisappearPublisher
            .sink { [weak self] request in self?.stageDidDisappear(request) }
        stageDidHideSubscriber = baseViewController.stageDidHidePublisher
            .sink { [weak self] request in self?.stageDidHide(request) }
        stageDidLoadSubscriber = baseViewController.stageDidLoadPublisher
            .sink { [weak self] request in self?.stageDidLoad(request) }
        stageWillAppearSubscriber = baseViewController.stageWillAppearPublisher
            .sink { [weak self] request in self?.stageWillAppear(request) }
        stageWillDisappearSubscriber = baseViewController.stageWillDisappearPublisher
            .sink { [weak self] request in self?.stageWillDisappear(request) }
        stageWillHideSubscriber = baseViewController.stageWillHidePublisher
            .sink { [weak self] request in self?.stageWillHide(request) }

        closeActionSubscriber = baseViewController.closeActionPublisher
            .sink { [weak self] request in self?.doCloseAction(request) }
        confirmationSubscriber = baseViewController.confirmationPublisher
            .sink { [weak self] request in self?.doConfirmation(request) }
        errorOccurredSubscriber = baseViewController.errorOccurredPublisher
            .sink { [weak self] request in self?.doErrorOccurred(request) }
        messageSubscriber = baseViewController.messageDonePublisher
            .sink { [weak self] request in self?.doMessageDone(request) }
        webStartNavigationSubscriber = baseViewController.webStartNavigationPublisher
            .sink { [weak self] request in self?.doWebStartNavigation(request) }
        webFinishNavigationSubscriber = baseViewController.webFinishNavigationPublisher
            .sink { [weak self] request in self?.doWebFinishNavigation(request) }
        webErrorNavigationSubscriber = baseViewController.webErrorNavigationPublisher
            .sink { [weak self] request in self?.doWebErrorNavigation(request) }
        webLoadProgressSubscriber = baseViewController.webLoadProgressPublisher
            .sink { [weak self] request in self?.doWebLoadProgress(request) }
    }

    // MARK: - Private Properties -
    var hasStageAppeared: Bool = false
    var hasStageEnded: Bool = false

    // MARK: - Public Properties -
    public var displayMode: BaseStage.Display.Mode?
    public var displayOptions: BaseStage.Display.Options = []
    public var stageUpdated = false

    // MARK: - Workers -
    public var wkrAnalytics: WKRPTCLAnalytics = WKRCrashAnalytics()

    required public init(configurator: BaseStage.Configurator) {
        self.baseConfigurator = configurator
    }
    open func startStage(with displayMode: BaseStage.Display.Mode,
                         with displayOptions: BaseStage.Display.Options = [],
                         and initialization: DNSBaseStageBaseInitialization?) {
        self.hasStageAppeared = false
        self.displayMode = displayMode
        self.displayOptions = displayOptions
        self.baseInitializationObject = initialization
        stageStartPublisher.send(BaseStage.Models.Start.Response(displayMode: displayMode,
                                                                 displayOptions: displayOptions))
    }
    open func updateStage(with initializationObject: DNSBaseStageBaseInitialization) {
        self.baseInitializationObject = initializationObject
        guard self.hasStageAppeared else {
            return
        }
        self.stageUpdated = true
        self.stageWasUpdated()
    }
    open func stageWasUpdated() {
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
        guard !conditionally || shouldEndStage else { return }
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
        self.hasStageAppeared = true
        self.hasStageEnded = false
        self.stageUpdated = false
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
        self.wkrAnalytics.doScreen(screenTitle: String(describing: self.baseConfigurator!))
        self.baseConfigurator?.restartEnding()
    }
    open func stageWillDisappear(_ request: BaseStage.Models.Base.Request) {
    }
    open func stageWillHide(_ request: BaseStage.Models.Base.Request) {
    }
    
    // MARK: - Business Logic -
    open func doCloseAction(_ request: BaseStage.Models.Base.Request) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        self.utilityCloseAction()
    }
    open func doConfirmation(_ request: BaseStage.Models.Confirmation.Request) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doErrorOccurred(_ request: BaseStage.Models.ErrorMessage.Request) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSThread.run { [weak self] in
            guard let self else { return }
            var response = BaseStage.Models.ErrorMessage.Response(error: request.error,
                                                                  style: .popup,
                                                                  title: request.title)
            response.okayButton = request.okayButton
            self.errorPublisher.send(response)
        }
    }
    open func doMessageDone(_ request: BaseStage.Models.Message.Request) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }

    open func doWebStartNavigation(_ request: BaseStage.Models.Webpage.Request) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doWebFinishNavigation(_ request: BaseStage.Models.Webpage.Request) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    open func doWebErrorNavigation(_ request: BaseStage.Models.WebpageError.Request) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSThread.run { [weak self] in
            guard let self else { return }
            let response = BaseStage.Models.ErrorMessage.Response(error: request.error,
                                                                  style: .popup,
                                                                  title: "Web Error")
            self.errorPublisher.send(response)
        }
    }
    open func doWebLoadProgress(_ request: BaseStage.Models.WebpageProgress.Request) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
    }
    
    // MARK: - Shortcut Methods
    open func disabled(show: Bool,
                       forceReset: Bool = false) {
        DNSThread.run { [weak self] in
            guard let self else { return }
            var response = BaseStage.Models.Disabled.Response(show: show)
            response.forceReset = forceReset
            self.disabledPublisher.send(response)
        }
    }
    open func spinner(show: Bool,
                      forceReset: Bool = false) {
        DNSThread.run { [weak self] in
            guard let self else { return }
            var response = BaseStage.Models.Spinner.Response(show: show)
            response.forceReset = forceReset
            self.spinnerPublisher.send(response)
        }
    }

    // MARK: - Utility methods
    open func utilityCloseAction(with results: DNSBaseStageBaseResults? = nil) {
        self.hasStageEnded = false
        self.endStage(conditionally: true, with: BaseStage.BaseIntents.close, and: false, and: results)
        self.utilityReset()
    }
    open func utilityReset() {
        self.resetPublisher.send(BaseStage.Models.Base.Response())
    }
}
