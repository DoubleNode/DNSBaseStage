//
//  DNSBaseStagePresenter.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Combine
import DNSAppCore
import DNSCoreThreading
import DNSProtocols
import UIKit

public protocol DNSBaseStagePresentationLogic: AnyObject {
    // MARK: - Outgoing Pipelines -
    var stageStartPublisher: PassthroughSubject<DNSBaseStageModels.Start.ViewModel, Never> { get }
    var stageEndPublisher: PassthroughSubject<DNSBaseStageModels.Finish.ViewModel, Never> { get }

    var confirmationPublisher: PassthroughSubject<DNSBaseStageModels.Confirmation.ViewModel, Never> { get }
    var dismissPublisher: PassthroughSubject<DNSBaseStageModels.Dismiss.ViewModel, Never> { get }
    var messagePublisher: PassthroughSubject<DNSBaseStageModels.Message.ViewModel, Never> { get }
    var spinnerPublisher: PassthroughSubject<DNSBaseStageModels.Spinner.ViewModel, Never> { get }
    var titlePublisher: PassthroughSubject<DNSBaseStageModels.Title.ViewModel, Never> { get }
}

open class DNSBaseStagePresenter: NSObject, DNSBaseStagePresentationLogic {
    // MARK: - Public Associated Type Properties -
    public var baseConfigurator: DNSBaseStageConfigurator?

    // MARK: - Outgoing Pipelines -
    public let stageStartPublisher = PassthroughSubject<DNSBaseStageModels.Start.ViewModel, Never>()
    public let stageEndPublisher = PassthroughSubject<DNSBaseStageModels.Finish.ViewModel, Never>()

    public let confirmationPublisher = PassthroughSubject<DNSBaseStageModels.Confirmation.ViewModel, Never>()
    public let dismissPublisher = PassthroughSubject<DNSBaseStageModels.Dismiss.ViewModel, Never>()
    public let messagePublisher = PassthroughSubject<DNSBaseStageModels.Message.ViewModel, Never>()
    public let spinnerPublisher = PassthroughSubject<DNSBaseStageModels.Spinner.ViewModel, Never>()
    public let titlePublisher = PassthroughSubject<DNSBaseStageModels.Title.ViewModel, Never>()

    // MARK: - Incoming Pipelines -
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

    // MARK: - Private Properties -
    var spinnerCount:   Int = 0

    // MARK: - Public Properties -

    // MARK: - Public Properties: Default Palette Colors -
    public var defaultBackgroundColor:  UIColor = UIColor.blue
    public var defaultMessageColor:     UIColor = UIColor.white
    public var defaultTitleColor:       UIColor = UIColor.white

    // MARK: - Public Properties: Error Palette Colors -
    public var errorBackgroundColor:    UIColor = UIColor.red
    public var errorMessageColor:       UIColor = UIColor.white
    public var errorTitleColor:         UIColor = UIColor.white

    // MARK: - Public Properties: Default Palette Fonts -
    public var defaultMessageFont:  UIFont = UIFont.systemFont(ofSize: 14)
    public var defaultTitleFont:    UIFont = UIFont.boldSystemFont(ofSize: 16)

    // MARK: - Public Properties: Error Palette Fonts -
    public var errorMessageFont:    UIFont = UIFont.systemFont(ofSize: 14)
    public var errorTitleFont:      UIFont = UIFont.boldSystemFont(ofSize: 16)

    // MARK: - Workers -
    public var analyticsWorker: PTCLAnalytics_Protocol?

    required public init(configurator: DNSBaseStageConfigurator) {
        self.baseConfigurator = configurator
    }

    // MARK: - Lifecycle Methods -
    open func startStage(_ response: DNSBaseStageModels.Start.Response) {
        self.spinnerCount = 0

        stageStartPublisher.send(DNSBaseStageModels.Start.ViewModel(animated: true,
                                                                    displayType: response.displayType,
                                                                    displayOptions: response.displayOptions))
    }
    open func endStage(_ response: DNSBaseStageModels.Finish.Response) {
        self.spinnerCount = 0

        stageEndPublisher.send(DNSBaseStageModels.Finish.ViewModel(animated: true,
                                                                   displayType: response.displayType))
    }

    // MARK: - Presentation logic -
    open func presentConfirmation(_ response: DNSBaseStageModels.Confirmation.Response) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

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
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        self.dismissPublisher.send(DNSBaseStageModels.Dismiss.ViewModel(animated: response.animated))
    }
    open func presentError(_ response: DNSBaseStageModels.Error.Response) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        DNSAppGlobals.appLastDisplayedError = response.error
        
        var errorMessage = response.error.nsError.localizedDescription
        if (response.error.nsError.localizedFailureReason?.count ?? 0) > 0 {
            errorMessage += "\n\n\(response.error.nsError.localizedFailureReason ?? "")"
        }

        var viewModel = DNSBaseStageModels.Message.ViewModel(message: errorMessage,
                                                             style: response.style,
                                                             title: response.title)
        viewModel.colors = DNSBaseStageModels.Message.ViewModel.Colors(background: errorBackgroundColor,
                                                                       message: errorMessageColor,
                                                                       title: errorTitleColor)
        viewModel.dismissingDirection = response.dismissingDirection
        viewModel.duration = response.duration
        viewModel.fonts = DNSBaseStageModels.Message.ViewModel.Fonts(message: errorMessageFont,
                                                                     title: errorTitleFont)
        viewModel.location = response.location
        viewModel.nibName = response.nibName
        viewModel.okayButton = response.okayButton
        viewModel.presentingDirection = response.presentingDirection
        self.messagePublisher.send(viewModel)
    }
    open func presentMessage(_ response: DNSBaseStageModels.Message.Response) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        var viewModel = DNSBaseStageModels.Message.ViewModel(message: response.message,
                                                             percentage: response.percentage,
                                                             style: response.style,
                                                             title: response.title)
        viewModel.image = response.image
        viewModel.subTitle = response.subTitle
        viewModel.colors = DNSBaseStageModels.Message.ViewModel.Colors(background: defaultBackgroundColor,
                                                                       message: defaultMessageColor,
                                                                       title: defaultTitleColor)
        viewModel.colors?.subTitle = defaultMessageColor
        viewModel.dismissingDirection = response.dismissingDirection
        viewModel.duration = response.duration
        viewModel.fonts = DNSBaseStageModels.Message.ViewModel.Fonts(message: defaultMessageFont,
                                                                     title: defaultTitleFont)
        viewModel.fonts?.subTitle = defaultMessageFont

        viewModel.cancelButton = response.cancelButton
        viewModel.location = response.location
        viewModel.nibName = response.nibName
        viewModel.okayButton = response.okayButton
        viewModel.presentingDirection = response.presentingDirection
        self.messagePublisher.send(viewModel)
    }
    open func presentSpinner(_ response: DNSBaseStageModels.Spinner.Response) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        if response.show {
            spinnerCount += 1
            guard spinnerCount == 1 else { return }

            _ = DNSThread.run(after: 0.3) {
                guard self.spinnerCount >= 1 else { return }

                let viewModel = DNSBaseStageModels.Spinner.ViewModel(show: response.show)
                self.spinnerPublisher.send(viewModel)
            }
        } else {
            if spinnerCount > 0 {
                spinnerCount -= 1
            }
            guard spinnerCount == 0 else { return }

            let viewModel = DNSBaseStageModels.Spinner.ViewModel(show: response.show)
            self.spinnerPublisher.send(viewModel)
        }
    }
    open func presentTitle(_ response: DNSBaseStageModels.Title.Response) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        var viewModel = DNSBaseStageModels.Title.ViewModel(title: response.title)
        if !(response.tabBarImageName.isEmpty) {
            viewModel.tabBarSelectedImage = UIImage(named: "\(response.tabBarImageName)Selected")
            viewModel.tabBarUnselectedImage = UIImage(named: "\(response.tabBarImageName)Unselected")
        }
        titlePublisher.send(viewModel)
    }
}
