//
//  DNSBaseStagePresenter.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import Combine
import DNSProtocols
import UIKit

public protocol DNSBaseStagePresentationLogic: class {
    // MARK: - Outgoing Pipelines
    var stageStartPublisher: PassthroughSubject<DNSBaseStageModels.Start.ViewModel, Never> { get }
    var stageEndPublisher: PassthroughSubject<DNSBaseStageModels.Finish.ViewModel, Never> { get }

    var confirmationPublisher: PassthroughSubject<DNSBaseStageModels.Confirmation.ViewModel, Never> { get }
    var dismissPublisher: PassthroughSubject<DNSBaseStageModels.Dismiss.ViewModel, Never> { get }
    var messagePublisher: PassthroughSubject<DNSBaseStageModels.Message.ViewModel, Never> { get }
    var spinnerPublisher: PassthroughSubject<DNSBaseStageModels.Spinner.ViewModel, Never> { get }
    var titlePublisher: PassthroughSubject<DNSBaseStageModels.Title.ViewModel, Never> { get }
}

open class DNSBaseStagePresenter: NSObject, DNSBaseStagePresentationLogic {
    // MARK: - Public Associated Type Properties
    public var baseConfigurator: DNSBaseStageConfigurator?

    // MARK: - Outgoing Pipelines
    public let stageStartPublisher = PassthroughSubject<DNSBaseStageModels.Start.ViewModel, Never>()
    public let stageEndPublisher = PassthroughSubject<DNSBaseStageModels.Finish.ViewModel, Never>()

    public let confirmationPublisher = PassthroughSubject<DNSBaseStageModels.Confirmation.ViewModel, Never>()
    public let dismissPublisher = PassthroughSubject<DNSBaseStageModels.Dismiss.ViewModel, Never>()
    public let messagePublisher = PassthroughSubject<DNSBaseStageModels.Message.ViewModel, Never>()
    public let spinnerPublisher = PassthroughSubject<DNSBaseStageModels.Spinner.ViewModel, Never>()
    public let titlePublisher = PassthroughSubject<DNSBaseStageModels.Title.ViewModel, Never>()

    // MARK: - Incoming Pipelines
    var stageStartSubscriber: AnyCancellable?
    var stageEndSubscriber: AnyCancellable?

    var confirmationSubscriber: AnyCancellable?
    var dismissSubscriber: AnyCancellable?
    var errorSubscriber: AnyCancellable?
    var messageSubscriber: AnyCancellable?
    var spinnerSubscriber: AnyCancellable?
    var titleSubscriber: AnyCancellable?

    open func subscribe(to baseInteractor: DNSBaseStageBusinessLogic) {
        stageStartSubscriber = baseInteractor.stageStartPublisher
            .sink { response in self.startStage(response) }
        stageEndSubscriber = baseInteractor.stageEndPublisher
            .sink { response in self.endStage(response) }

        confirmationSubscriber = baseInteractor.confirmationPublisher
            .sink { response in self.presentConfirmation(response) }
        dismissSubscriber = baseInteractor.dismissPublisher
            .sink { response in self.presentDismiss(response) }
        errorSubscriber = baseInteractor.errorPublisher
            .sink { response in self.presentError(response) }
        messageSubscriber = baseInteractor.messagePublisher
            .sink { response in self.presentMessage(response) }
        spinnerSubscriber = baseInteractor.spinnerPublisher
            .sink { response in self.presentSpinner(response) }
        titleSubscriber = baseInteractor.titlePublisher
            .sink { response in self.presentTitle(response) }
    }

    // MARK: - Private Properties
    var spinnerCount:   Int = 0

    // MARK: - Public Properties

    // MARK: - Public Properties: Default Palette Colors
    public var defaultBackgroundColor:  UIColor = UIColor.blue
    public var defaultMessageColor:     UIColor = UIColor.white
    public var defaultTitleColor:       UIColor = UIColor.white

    // MARK: - Public Properties: Error Palette Colors
    public var errorBackgroundColor:    UIColor = UIColor.red
    public var errorMessageColor:       UIColor = UIColor.white
    public var errorTitleColor:         UIColor = UIColor.white

    // MARK: - Public Properties: Default Palette Fonts
    public var defaultMessageFont:  UIFont = UIFont.systemFont(ofSize: 14)
    public var defaultTitleFont:    UIFont = UIFont.boldSystemFont(ofSize: 16)

    // MARK: - Public Properties: Error Palette Fonts
    public var errorMessageFont:    UIFont = UIFont.systemFont(ofSize: 14)
    public var errorTitleFont:      UIFont = UIFont.boldSystemFont(ofSize: 16)

    // MARK: - Workers
    public var analyticsWorker: PTCLAnalytics_Protocol?

    required public init(configurator: DNSBaseStageConfigurator) {
        self.baseConfigurator = configurator
    }

    // MARK: - Lifecycle Methods
    open func startStage(_ response: DNSBaseStageModels.Start.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.spinnerCount = 0

        stageStartPublisher.send(DNSBaseStageModels.Start.ViewModel(animated: true,
                                                                    displayType: response.displayType))
    }
    open func endStage(_ response: DNSBaseStageModels.Finish.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.spinnerCount = 0

        stageEndPublisher.send(DNSBaseStageModels.Finish.ViewModel(animated: true,
                                                                   displayType: response.displayType))
    }

    // MARK: - Presentation logic
    open func presentConfirmation(_ response: DNSBaseStageModels.Confirmation.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        let viewModel = DNSBaseStageModels.Confirmation.ViewModel()
        viewModel.alertStyle    = response.alertStyle
        viewModel.message       = response.message
        viewModel.title         = response.title
        viewModel.userData      = response.userData

        for textField in response.textFields {
             viewModel.textFields.append(
                DNSBaseStageModels.Confirmation.ViewModel.TextField(contentType: textField.contentType,
                                                                    keyboardType: textField.keyboardType,
                                                                    placeholder: textField.placeholder)
            )
        }
        for button in response.buttons {
            viewModel.buttons.append(
                DNSBaseStageModels.Confirmation.ViewModel.Button(code: button.code,
                                                                 style: button.style,
                                                                 title: button.title)
            )
        }
        self.confirmationPublisher.send(viewModel)
    }
    open func presentDismiss(_ response: DNSBaseStageModels.Dismiss.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.dismissPublisher.send(DNSBaseStageModels.Dismiss.ViewModel(animated: response.animated))
    }
    open func presentError(_ response: DNSBaseStageModels.Error.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        var errorMessage = response.error.localizedDescription
        if (response.error.localizedFailureReason?.count ?? 0) > 0 {
            errorMessage += "\n\n\(response.error.localizedFailureReason ?? "")"
        }

        var viewModel = DNSBaseStageModels.Message.ViewModel(message: errorMessage,
                                                             style: response.style,
                                                             title: response.title)
        viewModel.colors = DNSBaseStageModels.Message.ViewModel.Colors(background: errorBackgroundColor,
                                                                       message: errorMessageColor,
                                                                       title: errorTitleColor)
        viewModel.fonts = DNSBaseStageModels.Message.ViewModel.Fonts(message: errorMessageFont,
                                                                     title: errorTitleFont)
        self.messagePublisher.send(viewModel)
    }
    open func presentMessage(_ response: DNSBaseStageModels.Message.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        var viewModel = DNSBaseStageModels.Message.ViewModel(message: response.message,
                                                             percentage: response.percentage,
                                                             style: response.style,
                                                             title: response.title)
        viewModel.colors = DNSBaseStageModels.Message.ViewModel.Colors(background: defaultBackgroundColor,
                                                                       message: defaultMessageColor,
                                                                       title: defaultTitleColor)
        viewModel.fonts = DNSBaseStageModels.Message.ViewModel.Fonts(message: defaultMessageFont,
                                                                     title: defaultTitleFont)
        self.messagePublisher.send(viewModel)
    }
    open func presentSpinner(_ response: DNSBaseStageModels.Spinner.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        if response.show {
            spinnerCount += 1
            guard spinnerCount == 1 else { return }
        } else {
            if spinnerCount > 0 {
                spinnerCount -= 1
            }
            guard spinnerCount == 0 else { return }
        }
        self.spinnerPublisher.send(DNSBaseStageModels.Spinner.ViewModel(show: response.show))
    }
    open func presentTitle(_ response: DNSBaseStageModels.Title.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        titlePublisher.send(DNSBaseStageModels.Title.ViewModel(title: response.title))
    }
}
