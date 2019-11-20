//
//  DNSBaseStageInteractor.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import DNSProtocols

public protocol DNSBaseStageBusinessLogic: class {
    // MARK: - Stage Lifecycle
    func stageDidAppear(_ request: DNSBaseStageBaseRequest)
    func stageDidClose(_ request: DNSBaseStageBaseRequest)
    func stageDidDisappear(_ request: DNSBaseStageBaseRequest)
    func stageDidHide(_ request: DNSBaseStageBaseRequest)
    func stageDidLoad(_ request: DNSBaseStageBaseRequest)
    func stageWillAppear(_ request: DNSBaseStageBaseRequest)
    func stageWillDisappear(_ request: DNSBaseStageBaseRequest)

    // MARK: - Business Logic
    func doConfirmation(_ request: DNSBaseStageModels.Confirmation.Request)
    func doErrorOccurred(_ request: DNSBaseStageModels.Error.Request)
    func doWebStartNavigation(_ request: DNSBaseStageModels.Webpage.Request)
    func doWebFinishNavigation(_ request: DNSBaseStageModels.Webpage.Request)
    func doWebErrorNavigation(_ request: DNSBaseStageModels.WebpageError.Request)
}

open class DNSBaseStageInteractor: DNSBaseStageBusinessLogic {
    // MARK: - Private Properties
    var hasStageEnded:  Bool = false

    // MARK: - Public Properties
    public var basePresenter:               DNSBaseStagePresentationLogic?
    public var baseConfigurator:            DNSBaseStageConfigurator?
    public var baseInitializationObject:    DNSBaseStageBaseInitialization?
    public var displayType:                 DNSBaseStageDisplayType?

    // MARK: - Workers
    public var analyticsWorker:     PTCLAnalytics_Protocol?

    required public init(configurator: DNSBaseStageConfigurator) {
        self.baseConfigurator = configurator
    }

    open func startStage(with displayType: DNSBaseStageDisplayType,
                         and initialization: DNSBaseStageBaseInitialization?) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.displayType = displayType
        self.baseInitializationObject = initialization

        self.basePresenter?.startStage(DNSBaseStageModels.Start.Response(displayType: displayType))
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

        self.baseConfigurator?.endStage(with: intent,
                                        and: dataChanged,
                                        and: results)
    }

    open func removeStage(displayType: DNSBaseStageDisplayType) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.basePresenter?.endStage(DNSBaseStageModels.Finish.Response(displayType: displayType))
    }

    // MARK: - Stage Lifecycle
    open func stageDidAppear(_ request: DNSBaseStageBaseRequest) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.hasStageEnded  = false
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

        self.basePresenter?.presentError(DNSBaseStageModels.Error.Response(error: request.error,
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

        self.basePresenter?.presentError(DNSBaseStageModels.Error.Response(error: request.error,
                                                                           style: .popup,
                                                                           title: "Web Error"))
    }
}
