//
//  DNSBaseStageInteractor.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import Combine
import DNSProtocols

public protocol DNSBaseStageBusinessLogic: class {
    // MARK: - Outgoing Pipelines
    var stageStartPublisher: PassthroughSubject<DNSBaseStageModels.Start.Response, Never> { get }
    var stageEndPublisher: PassthroughSubject<DNSBaseStageModels.Finish.Response, Never> { get }

    var confirmationPublisher: PassthroughSubject<DNSBaseStageModels.Confirmation.Response, Never> { get }
    var dismissPublisher: PassthroughSubject<DNSBaseStageModels.Dismiss.Response, Never> { get }
    var errorPublisher: PassthroughSubject<DNSBaseStageModels.Error.Response, Never> { get }
    var messagePublisher: PassthroughSubject<DNSBaseStageModels.Message.Response, Never> { get }
    var spinnerPublisher: PassthroughSubject<DNSBaseStageModels.Spinner.Response, Never> { get }
    var titlePublisher: PassthroughSubject<DNSBaseStageModels.Title.Response, Never> { get }
}

open class DNSBaseStageInteractor: DNSBaseStageBusinessLogic {
    // MARK: - Outgoing Pipelines
    public let stageStartPublisher = PassthroughSubject<DNSBaseStageModels.Start.Response, Never>()
    public let stageEndPublisher = PassthroughSubject<DNSBaseStageModels.Finish.Response, Never>()

    public let confirmationPublisher = PassthroughSubject<DNSBaseStageModels.Confirmation.Response, Never>()
    public let dismissPublisher = PassthroughSubject<DNSBaseStageModels.Dismiss.Response, Never>()
    public let errorPublisher = PassthroughSubject<DNSBaseStageModels.Error.Response, Never>()
    public let messagePublisher = PassthroughSubject<DNSBaseStageModels.Message.Response, Never>()
    public let spinnerPublisher = PassthroughSubject<DNSBaseStageModels.Spinner.Response, Never>()
    public let titlePublisher = PassthroughSubject<DNSBaseStageModels.Title.Response, Never>()

    // MARK: - Incoming Pipelines
    var stageDidAppearSubscriber: AnyCancellable?
    var stageDidCloseSubscriber: AnyCancellable?
    var stageDidDisappearSubscriber: AnyCancellable?
    var stageDidHideSubscriber: AnyCancellable?
    var stageDidLoadSubscriber: AnyCancellable?
    var stageWillAppearSubscriber: AnyCancellable?
    var stageWillDisappearSubscriber: AnyCancellable?

    open func subscribe(to viewController: DNSBaseStageDisplayLogic) {
        stageDidAppearSubscriber = viewController.stageDidAppearPublisher
            .sink { request in self.stageDidAppear(request) }
        stageDidCloseSubscriber = viewController.stageDidClosePublisher
            .sink { request in self.stageDidClose(request) }
        stageDidDisappearSubscriber = viewController.stageDidDisappearPublisher
            .sink { request in self.stageDidDisappear(request) }
        stageDidHideSubscriber = viewController.stageDidHidePublisher
            .sink { request in self.stageDidHide(request) }
        stageDidLoadSubscriber = viewController.stageDidLoadPublisher
            .sink { request in self.stageDidLoad(request) }
        stageWillAppearSubscriber = viewController.stageWillAppearPublisher
            .sink { request in self.stageWillAppear(request) }
        stageWillDisappearSubscriber = viewController.stageWillDisappearPublisher
            .sink { request in self.stageWillDisappear(request) }
    }
    
    // MARK: - Private Properties
    var hasStageEnded:  Bool = false

    // MARK: - Public Properties
    public var configurator: Any DNSBaseStageConfigurator?
    public var initializationObject: Any DNSBaseStageBaseInitialization?
    public var displayType: DNSBaseStageDisplayType?

    // MARK: - Workers
    public var analyticsWorker: PTCLAnalytics_Protocol?

    required public init(configurator: DNSBaseStageConfigurator) {
        self.configurator = configurator
    }

    open func startStage(with displayType: DNSBaseStageDisplayType,
                         and initialization: DNSBaseStageBaseInitialization?) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.displayType = displayType
        self.initializationObject = initialization

        stageStartPublisher.send(DNSBaseStageModels.Start.Response(displayType: displayType))
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
        if conditionally &&
            !self.shouldEndStage() {
            return
        }

        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.configurator?.endStage(with: intent,
                                        and: dataChanged,
                                        and: results)
    }

    open func removeStage(displayType: DNSBaseStageDisplayType) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        stageEndPublisher.send(DNSBaseStageModels.Finish.Response(displayType: displayType))
    }

    // MARK: - Stage Lifecycle
    open func stageDidAppear(_ request: DNSBaseStageBaseRequest) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.hasStageEnded  = false
        
        titlePublisher.send(DNSBaseStageModels.Title.Response(title: "Test Title"))
    }

    open func stageDidClose(_ request: DNSBaseStageBaseRequest) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.endStage(conditionally: true, with: "", and: false, and: nil)
    }

    open func stageDidDisappear(_ request: DNSBaseStageBaseRequest) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }
    }

    open func stageDidHide(_ request: DNSBaseStageBaseRequest) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }
    }

    open func stageDidLoad(_ request: DNSBaseStageBaseRequest) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }
    }

    open func stageWillAppear(_ request: DNSBaseStageBaseRequest) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }
    }

    open func stageWillDisappear(_ request: DNSBaseStageBaseRequest) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }
    }

    // MARK: - Business Logic
    open func doConfirmation(_ request: DNSBaseStageModels.Confirmation.Request) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }
    }

    open func doErrorOccurred(_ request: DNSBaseStageModels.Error.Request) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.errorPublisher.send(DNSBaseStageModels.Error.Response(error: request.error,
                                                                   style: .popup,
                                                                   title: request.title))
    }

    open func doWebStartNavigation(_ request: DNSBaseStageModels.Webpage.Request) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }
    }

    open func doWebFinishNavigation(_ request: DNSBaseStageModels.Webpage.Request) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }
    }

    open func doWebErrorNavigation(_ request: DNSBaseStageModels.WebpageError.Request) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.errorPublisher.send(DNSBaseStageModels.Error.Response(error: request.error,
                                                                   style: .popup,
                                                                   title: "Web Error"))
    }
}
