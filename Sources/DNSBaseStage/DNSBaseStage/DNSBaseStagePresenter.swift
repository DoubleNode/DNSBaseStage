//
//  DNSBaseStagePresenter.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import DNSProtocols
import UIKit

public protocol DNSBaseStagePresentationLogic: class {
    // MARK: - Lifecycle Methods
    func startStage(_ response: DNSBaseStageModels.Start.Response)
    func endStage(_ response: DNSBaseStageModels.Finish.Response)

    // MARK: - Presentation logic
    func presentConfirmation(_ response: DNSBaseStageModels.Confirmation.Response)
    func presentDismiss(_ response: DNSBaseStageModels.Dismiss.Response)
    func presentError(_ response: DNSBaseStageModels.Error.Response)
    func presentMessage(_ response: DNSBaseStageModels.Message.Response)
    func presentSpinner(_ response: DNSBaseStageModels.Spinner.Response)
    func presentTitle(_ response: DNSBaseStageModels.Title.Response)
}

open class DNSBaseStagePresenter: DNSBaseStagePresentationLogic {
    // MARK: - Private Properties
    var spinnerCount:   Int = 0

    // MARK: - Public Properties
    public var baseDisplay:     DNSBaseStageDisplayLogic?
    public var configurator:    DNSBaseStageConfigurator?

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
        self.configurator   = configurator
    }

    // MARK: - Lifecycle Methods
    open func startStage(_ response: DNSBaseStageModels.Start.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.spinnerCount = 0

        self.baseDisplay?.startStage(DNSBaseStageModels.Start.ViewModel(animated: true,
                                                                        displayType: response.displayType))
    }
    open func endStage(_ response: DNSBaseStageModels.Finish.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.spinnerCount = 0

        self.baseDisplay?.endStage(DNSBaseStageModels.Finish.ViewModel(animated: true, displayType: response.displayType))
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
        self.baseDisplay?.displayConfirmation(viewModel)
    }
    open func presentDismiss(_ response: DNSBaseStageModels.Dismiss.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseDisplay?.displayDismiss(DNSBaseStageModels.Dismiss.ViewModel(animated: response.animated))
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
        self.baseDisplay?.displayMessage(viewModel)
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
        self.baseDisplay?.displayMessage(viewModel)
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
        self.baseDisplay?.displaySpinner(DNSBaseStageModels.Spinner.ViewModel(show: response.show))
    }
    open func presentTitle(_ response: DNSBaseStageModels.Title.Response) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseDisplay?.displayTitle(DNSBaseStageModels.Title.ViewModel(title: response.title))
    }
}
