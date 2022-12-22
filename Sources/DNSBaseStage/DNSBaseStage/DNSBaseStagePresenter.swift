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
import DNSCrashWorkers
import DNSProtocols
import UIKit

public protocol DNSBaseStagePresentationLogic: AnyObject {
    typealias BaseStage = DNSBaseStage
    
    // MARK: - Outgoing Pipelines -
    var stageStartPublisher: PassthroughSubject<BaseStage.Models.Start.ViewModel, Never> { get }
    var stageEndPublisher: PassthroughSubject<BaseStage.Models.Finish.ViewModel, Never> { get }

    var confirmationPublisher: PassthroughSubject<BaseStage.Models.Confirmation.ViewModel, Never> { get }
    var dismissPublisher: PassthroughSubject<BaseStage.Models.Dismiss.ViewModel, Never> { get }
    var messagePublisher: PassthroughSubject<BaseStage.Models.Message.ViewModel, Never> { get }
    var resetPublisher: PassthroughSubject<BaseStage.Models.Base.ViewModel, Never> { get }
    var spinnerPublisher: PassthroughSubject<BaseStage.Models.Spinner.ViewModel, Never> { get }
    var titlePublisher: PassthroughSubject<BaseStage.Models.Title.ViewModel, Never> { get }
}

open class DNSBaseStagePresenter: NSObject, DNSBaseStagePresentationLogic {
    public typealias BaseStage = DNSBaseStage
    
    // MARK: - Public Associated Type Properties -
    public var baseConfigurator: BaseStage.Configurator?

    // MARK: - Outgoing Pipelines -
    public let stageStartPublisher = PassthroughSubject<BaseStage.Models.Start.ViewModel, Never>()
    public let stageEndPublisher = PassthroughSubject<BaseStage.Models.Finish.ViewModel, Never>()

    public let confirmationPublisher = PassthroughSubject<BaseStage.Models.Confirmation.ViewModel, Never>()
    public let dismissPublisher = PassthroughSubject<BaseStage.Models.Dismiss.ViewModel, Never>()
    public let messagePublisher = PassthroughSubject<BaseStage.Models.Message.ViewModel, Never>()
    public let resetPublisher = PassthroughSubject<BaseStage.Models.Base.ViewModel, Never>()
    public let spinnerPublisher = PassthroughSubject<BaseStage.Models.Spinner.ViewModel, Never>()
    public let titlePublisher = PassthroughSubject<BaseStage.Models.Title.ViewModel, Never>()

    // MARK: - Incoming Pipelines -
    var stageStartSubscriber: AnyCancellable?
    var stageEndSubscriber: AnyCancellable?

    var confirmationSubscriber: AnyCancellable?
    var dismissSubscriber: AnyCancellable?
    var errorSubscriber: AnyCancellable?
    var messageSubscriber: AnyCancellable?
    var resetSubscriber: AnyCancellable?
    var spinnerSubscriber: AnyCancellable?
    var titleSubscriber: AnyCancellable?

    open func subscribe(to baseInteractor: BaseStage.Logic.Business) {
        stageStartSubscriber = baseInteractor.stageStartPublisher
            .sink { [weak self] response in self?.startStage(response) }
        stageEndSubscriber = baseInteractor.stageEndPublisher
            .sink { [weak self] response in self?.endStage(response) }

        confirmationSubscriber = baseInteractor.confirmationPublisher
            .sink { [weak self] response in self?.presentConfirmation(response) }
        dismissSubscriber = baseInteractor.dismissPublisher
            .sink { [weak self] response in self?.presentDismiss(response) }
        errorSubscriber = baseInteractor.errorPublisher
            .sink { [weak self] response in self?.presentErrorMessage(response) }
        messageSubscriber = baseInteractor.messagePublisher
            .sink { [weak self] response in self?.presentMessage(response) }
        resetSubscriber = baseInteractor.resetPublisher
            .sink { [weak self] response in self?.presentReset(response) }
        spinnerSubscriber = baseInteractor.spinnerPublisher
            .sink { [weak self] response in self?.presentSpinner(response) }
        titleSubscriber = baseInteractor.titlePublisher
            .sink { [weak self] response in self?.presentTitle(response) }
    }

    // MARK: - Private Properties -
    var spinnerCount: Int = 0

    // MARK: - Public Properties -
    // MARK: - Public Properties: Default Palette Colors -
    public var defaultBackgroundColor: UIColor = UIColor.blue
    public var defaultMessageColor: UIColor = UIColor.white
    public var defaultTitleColor: UIColor = UIColor.white

    // MARK: - Public Properties: Error Palette Colors -
    public var errorBackgroundColor: UIColor = UIColor.red
    public var errorMessageColor: UIColor = UIColor.white
    public var errorTitleColor: UIColor = UIColor.white

    // MARK: - Public Properties: Default Palette Fonts -
    public var defaultMessageFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var defaultTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 16)

    // MARK: - Public Properties: Error Palette Fonts -
    public var errorMessageFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var errorTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 16)

    // MARK: - Workers -
    public var wkrAnalytics: WKRPTCLAnalytics = WKRCrashAnalytics()

    required public init(configurator: BaseStage.Configurator) {
        self.baseConfigurator = configurator
    }

    // MARK: - Lifecycle Methods -
    open func startStage(_ response: BaseStage.Models.Start.Response) {
        self.spinnerCount = 0
        stageStartPublisher.send(BaseStage.Models.Start
            .ViewModel(animated: true,
                       displayMode: response.displayMode,
                       displayOptions: response.displayOptions))
    }
    open func endStage(_ response: BaseStage.Models.Finish.Response) {
        self.spinnerCount = 0
        stageEndPublisher.send(BaseStage.Models.Finish
            .ViewModel(animated: true,
                       displayMode: response.displayMode))
    }

    // MARK: - Presentation logic -
    open func presentConfirmation(_ response: BaseStage.Models.Confirmation.Response) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSThread.run { [weak self] in
            guard let self else { return }
            let viewModel = BaseStage.Models.Confirmation.ViewModel()
            viewModel.alertStyle = response.alertStyle
            viewModel.message = response.message
            viewModel.title = response.title
            viewModel.userData = response.userData

            for textField in response.textFields {
                 viewModel.textFields.append(
                    BaseStage.Models.Confirmation.ViewModel
                        .TextField(contentType: textField.contentType,
                                   keyboardType: textField.keyboardType,
                                   placeholder: textField.placeholder)
                )
            }
            for button in response.buttons {
                viewModel.buttons.append(
                    BaseStage.Models.Confirmation.ViewModel
                        .Button(code: button.code,
                                style: button.style,
                                title: button.title)
                )
            }
            self.confirmationPublisher.send(viewModel)
        }
    }
    open func presentDismiss(_ response: BaseStage.Models.Dismiss.Response) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        self.dismissPublisher.send(BaseStage.Models.Dismiss.ViewModel(animated: response.animated))
    }
    open func presentErrorMessage(_ response: BaseStage.Models.ErrorMessage.Response) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSAppGlobals.appLastDisplayedError = response.error
        DNSThread.run { [weak self] in
            guard let self else { return }
            var errorMessage = response.error.localizedDescription
            if let localizedError = response.error as? LocalizedError {
                if !(localizedError.failureReason?.isEmpty ?? true) {
                    errorMessage += "\n\n\(localizedError.failureReason ?? "")"
                }
            }
            
            var viewModel = BaseStage.Models.Message
                .ViewModel(message: errorMessage,
                           style: response.style,
                           title: response.title)
            viewModel.colors = BaseStage.Models.Message.ViewModel
                .Colors(background: self.errorBackgroundColor,
                        message: self.errorMessageColor,
                        title: self.errorTitleColor)
            viewModel.dismissingDirection = response.dismissingDirection
            viewModel.duration = response.duration
            viewModel.fonts = BaseStage.Models.Message.ViewModel.Fonts(message: self.errorMessageFont,
                                                                       title: self.errorTitleFont)
            viewModel.location = response.location
            viewModel.nibName = response.nibName
            viewModel.nibBundle = response.nibBundle
            viewModel.actions = [ "OK": response.okayButton.isEmpty ? "OK" : response.okayButton ]
            viewModel.presentingDirection = response.presentingDirection
            self.messagePublisher.send(viewModel)
        }
    }
    open func presentMessage(_ response: BaseStage.Models.Message.Response) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSThread.run { [weak self] in
            guard let self else { return }
            var viewModel = BaseStage.Models.Message.ViewModel(message: response.message,
                                                               percentage: response.percentage,
                                                               style: response.style,
                                                               title: response.title)
            viewModel.disclaimer = response.disclaimer
            viewModel.image = response.image
            viewModel.imageUrl = response.imageUrl
            viewModel.subTitle = response.subTitle
            viewModel.tags = response.tags
            viewModel.colors = BaseStage.Models.Message.ViewModel
                .Colors(background: self.defaultBackgroundColor,
                        message: self.defaultMessageColor,
                        title: self.defaultTitleColor)
            viewModel.colors?.subTitle = self.defaultMessageColor
            viewModel.dismissingDirection = response.dismissingDirection
            viewModel.duration = response.duration
            viewModel.fonts = BaseStage.Models.Message.ViewModel
                .Fonts(message: self.defaultMessageFont,
                       title: self.defaultTitleFont)
            viewModel.fonts?.subTitle = self.defaultMessageFont
            
            viewModel.actions = response.actions
            viewModel.cancelText = response.cancelText
            viewModel.location = response.location
            viewModel.nibName = response.nibName
            viewModel.nibBundle = response.nibBundle
            viewModel.presentingDirection = response.presentingDirection
            viewModel.userData = response.userData
            self.messagePublisher.send(viewModel)
        }
    }
    open func presentReset(_ response: BaseStage.Models.Base.Response) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSThread.run { [weak self] in
            guard let self else { return }
            self.resetPublisher.send(BaseStage.Models.Base.ViewModel())
        }
    }
    open func presentSpinner(_ response: BaseStage.Models.Spinner.Response) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")
        if response.forceReset {
            self.spinnerCount = 0
        }
        if response.show {
            spinnerCount += 1
            guard spinnerCount == 1 else { return }
            DNSUIThread.run(after: 0.3) {
                guard self.spinnerCount >= 1 else { return }
                self.spinner(show: response.show)
            }
        } else {
            if spinnerCount > 0 {
                spinnerCount -= 1
            }
            guard spinnerCount == 0 else { return }
            self.spinner(show: response.show)
        }
    }
    open func presentTitle(_ response: BaseStage.Models.Title.Response) {
        self.wkrAnalytics.doAutoTrack(class: String(describing: self), method: "\(#function)")

        var viewModel = BaseStage.Models.Title.ViewModel(title: response.title)
        if !(response.tabBarImageName.isEmpty) {
            viewModel.tabBarSelectedImage = UIImage(named: "\(response.tabBarImageName)Selected")
            viewModel.tabBarUnselectedImage = UIImage(named: "\(response.tabBarImageName)Unselected")
        }
        titlePublisher.send(viewModel)
    }

    // MARK: - Shortcut Methods
    open func spinner(show: Bool) {
        DNSThread.run { [weak self] in
            guard let self else { return }
            self.spinnerPublisher.send(BaseStage.Models.Spinner.ViewModel(show: show))
        }
    }
}
