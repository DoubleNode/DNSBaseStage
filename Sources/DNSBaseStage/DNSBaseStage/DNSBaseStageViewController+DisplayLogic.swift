//
//  DNSBaseStageViewController+DisplayLogic.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import DNSCore
import DNSCoreThreading
import JGProgressHUD
import Loaf
import UIKit

public protocol DNSBaseStageDisplayLogic: class {
    // MARK: - Lifecycle Methods
    func startStage(_ viewModel: DNSBaseStageModels.Start.ViewModel)
    func endStage(_ viewModel: DNSBaseStageModels.Finish.ViewModel)

    // MARK: - Presentation logic
    func displayConfirmation(_ viewModel: DNSBaseStageModels.Confirmation.ViewModel)
    func displayDismiss(_ viewModel: DNSBaseStageModels.Dismiss.ViewModel)
    func displayMessage(_ viewModel: DNSBaseStageModels.Message.ViewModel)
    func displaySpinner(_ viewModel: DNSBaseStageModels.Spinner.ViewModel)
    func displayTitle(_ viewModel: DNSBaseStageModels.Title.ViewModel)
}

extension DNSBaseStageViewController: DNSBaseStageDisplayLogic {
    public enum ToastState {
        case error, info, success, warning
    }

    var hud: JGProgressHUD {
        return JGProgressHUD(style: .dark)
    }
    
    // MARK: - Stage Lifecycle Methods

    open func stageDidAppear() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseInteractor?.stageDidAppear(DNSBaseStageModels.Base.Request())
    }

    open func stageDidClose() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseInteractor?.stageDidClose(DNSBaseStageModels.Base.Request())
    }

    open func stageDidDisappear() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseInteractor?.stageDidDisappear(DNSBaseStageModels.Base.Request())
    }

    open func stageDidHide() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseInteractor?.stageDidHide(DNSBaseStageModels.Base.Request())
    }

    open func stageDidLoad() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseInteractor?.stageDidLoad(DNSBaseStageModels.Base.Request())
    }

    open func stageWillAppear() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseInteractor?.stageWillAppear(DNSBaseStageModels.Base.Request())
    }

    open func stageWillDisappear() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.baseInteractor?.stageWillDisappear(DNSBaseStageModels.Base.Request())
    }

    // MARK: - Lifecycle Methods
    public func startStage(_ viewModel: DNSBaseStageModels.Start.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.displayType = viewModel.displayType

        switch self.displayType {
        case .none?:
            break

        case .modal?:
            DNSUIThread.run {
                DNSCore.appDelegate.rootViewController().present(self, animated: viewModel.animated)
            }

        case .navBarPush?, .navBarPushInstant?:
            guard self.configurator?.navigationController != nil else { return }

            self.startStageNavBarPush(viewModel)

        case .navBarRoot?, .navBarRootInstant?:
            guard self.configurator?.navigationController != nil else { return }

            let animated: Bool = (self.displayType == .navBarRoot)

            DNSUIThread.run {
                self.configurator?.navigationController?.setViewControllers([ self ], animated: animated)
            }

        case.tabBarAdd?, .tabBarAddInstant?:
            guard self.configurator?.tabBarController != nil else { return }

            let animated: Bool = (self.displayType == .tabBarAdd)

            DNSUIThread.run {
                var viewControllers = self.configurator?.tabBarController?.viewControllers ?? []
                viewControllers.append(self)

                self.configurator?.tabBarController?.setViewControllers(viewControllers, animated: animated)
            }

        default:
            break
        }
    }

    private func startStageNavBarPush(_ viewModel: DNSBaseStageModels.Start.ViewModel) {
        let animated: Bool = (viewModel.animated && (self.displayType == .navBarPush))

        DNSUIThread.run {
            guard self.configurator?.navigationController?.viewControllers.count ?? 0 > 0 else {
                self.configurator?.navigationController?.setViewControllers([ self ], animated: animated)
                return
            }
            guard self.configurator?.navigationController?.viewControllers.last != self else { return }

            if self.configurator?.navigationController?.viewControllers.contains(self) ?? false {
                let index = self.configurator?.navigationController?.viewControllers.firstIndex(of: self)
                if index != nil {
                    self.configurator?.navigationController?.viewControllers.remove(at: index!)
                }
            }

            let viewController      = self.configurator?.navigationController?.viewControllers.last
            let dnsViewController   = viewController as? DNSBaseStageViewController
            dnsViewController?.updateStageBackTitle()

            self.configurator?.navigationController?.pushViewController(self, animated: animated)
        }
    }

    public func endStage(_ viewModel: DNSBaseStageModels.Finish.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.displayType = viewModel.displayType

        switch self.displayType {
        case .none?:
            break

        case .modal?:
            _ = DNSUIThread.run(after: 1.0) {
                self.dismiss(animated: viewModel.animated)
            }

        case .navBarPush?, .navBarPushInstant?:
            guard self.configurator?.navigationController != nil else { return }

            self.endStageNavBarPush(viewModel)

        case .navBarRoot?, .navBarRootInstant?:
            guard self.configurator?.navigationController != nil else { return }

        case.tabBarAdd?, .tabBarAddInstant?:
            guard self.configurator?.tabBarController != nil else { return }
            guard self.configurator?.tabBarController?.viewControllers?.contains(self) ?? false else { return }

            let animated: Bool = (viewModel.animated && (self.displayType == .tabBarAdd))

            var viewControllers = self.configurator?.tabBarController?.viewControllers
            let index = viewControllers?.firstIndex(of: self)
            viewControllers?.remove(at: index!)

            DNSUIThread.run {
                self.configurator?.tabBarController?.setViewControllers(viewControllers, animated: animated)
            }

            DNSUIThread.run {
                self.removeFromParent()
            }

        default:
            break
        }
    }

    private func endStageNavBarPush(_ viewModel: DNSBaseStageModels.Finish.ViewModel) {
        let animated: Bool = (viewModel.animated && (self.displayType == .navBarPush))

        guard self.configurator?.navigationController?.viewControllers.contains(self) ?? false else { return }
        guard self.configurator?.navigationController?.viewControllers.count ?? 0 > 1 else { return }

        _ = DNSUIThread.run(after: 0.1) {
            self.configurator?.navigationController?.popViewController(animated: animated)
        }
    }

    // MARK: - Display logic
    public func displayConfirmation(_ viewModel: DNSBaseStageModels.Confirmation.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        DNSUIThread.run {
            var alertStyle = viewModel.alertStyle
            if DNSDevice.iPad {
                alertStyle = UIAlertController.Style.alert
            }
            if viewModel.textFields[0].placeholder?.count ?? 0 > 0 ||
                viewModel.textFields[1].placeholder?.count ?? 0 > 0 {
                alertStyle = UIAlertController.Style.alert
            }

            let alertController = UIAlertController.init(title: viewModel.title,
                                                         message: viewModel.message,
                                                         preferredStyle: alertStyle!)
            for viewModelTextField in viewModel.textFields where viewModelTextField.placeholder?.count ?? 0 > 0 {
                alertController.addTextField(configurationHandler: { (textField) in
                    textField.keyboardType  = viewModelTextField.keyboardType ?? UIKeyboardType.default
                    textField.placeholder   = viewModelTextField.placeholder ?? ""
                    if viewModelTextField.contentType?.count ?? 0 > 0 {
                        textField.textContentType = UITextContentType(rawValue: viewModelTextField.contentType ?? "")
                    }
                })
            }
            for viewModelButton in viewModel.buttons where viewModelButton.title?.count ?? 0 > 0 {
                let button = UIAlertAction.init(title: viewModelButton.title,
                                                style: viewModelButton.style!,
                                                handler: { (_) in
                    var value1: String?
                    var value2: String?

                    if alertController.textFields?.count ?? 0 > 0 {
                        value1 = alertController.textFields?[0].text
                    }
                    if alertController.textFields?.count ?? 0 > 1 {
                        value2 = alertController.textFields?[1].text
                    }

                    let request = DNSBaseStageModels.Confirmation.Request()
                    request.selection           = viewModelButton.code
                    request.textFields[0].value = value1
                    request.textFields[1].value = value2
                    request.userData            = viewModel.userData
                    self.baseInteractor?.doConfirmation(request)
                })

                alertController.addAction(button)
            }

            self.present(alertController, animated: true)
        }
    }

    public func displayDismiss(_ viewModel: DNSBaseStageModels.Dismiss.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.endStage(DNSBaseStageModels.Finish.ViewModel(animated: viewModel.animated, displayType: self.displayType!))
    }

    public func displayMessage(_ viewModel: DNSBaseStageModels.Message.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        DNSUIThread.run {
            switch viewModel.style {
            case .hudShow:
                self.updateHudDisplay(display: true, percent: viewModel.percentage, with: viewModel.title)
            case .hudHide:
                self.updateHudDisplay(display: false)
            case .popup:
                let alertController = UIAlertController.init(title: viewModel.title,
                                                             message: viewModel.message,
                                                             preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default))

                self.present(alertController, animated: true)
            case .toastError:
                self.updateToastDisplay(title: viewModel.title, state: .error)
            case .toastInfo:
                self.updateToastDisplay(title: viewModel.title, state: .info)
            case .toastSuccess:
                self.updateToastDisplay(title: viewModel.title, state: .success)
            case .toastWarning:
                self.updateToastDisplay(title: viewModel.title, state: .warning)
            }
        }
    }

    public func displaySpinner(_ viewModel: DNSBaseStageModels.Spinner.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        DNSUIThread.run {
            self.updateSpinnerDisplay(display: viewModel.show)
        }
    }

    public func displayTitle(_ viewModel: DNSBaseStageModels.Title.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.stageTitle = viewModel.title
    }

    // MARK: - parent class methods

    public func updateDisabledViewDisplay(display: Bool) {
        let headerHeight: CGFloat = (self.navigationController?.navigationBar.y ?? 0) +
            (self.navigationController?.navigationBar.height ?? 0)
        if headerHeight > 0 && (self.disabledViewTopConstraint?.constant ?? 0 >= CGFloat(0)) {
            self.disabledViewTopConstraint?.constant = 0 - headerHeight
        }

        if display {
            self.navigationController?.navigationBar.layer.zPosition = -1
        }

        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.disabledView?.alpha = display ? 1.0 : 0.0
        },
            completion: { (_) in
            if !display {
                self.navigationController?.navigationBar.layer.zPosition = 0
            }
        })
    }

    public func updateHudDisplay(display: Bool, percent: Float = -1, with title: String? = nil) {
        if display {
            self.updateDisabledViewDisplay(display: true)

            hud.textLabel.text = title
            if percent >= 0 {
                hud.progress = percent
                if !hud.isVisible {
                    hud.indicatorView = JGProgressHUDPieIndicatorView()
                }
            } else {
                if !hud.isVisible {
                    hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
                }
            }
            hud.show(in: view, animated: true)
        } else {
            _ = DNSUIThread.run(after: 2.0) {
                self.hud.dismiss(animated: true)
                self.updateDisabledViewDisplay(display: false)
            }
        }
    }

    public func updateSpinnerDisplay(display: Bool) {
        self.updateDisabledViewDisplay(display: display)

        if display {
            self.activityIndicator?.startAnimating()
        } else {
            UIView.animate(withDuration: 0.3) {
                self.activityIndicator?.stopAnimating()
            }
        }
    }

    public func updateToastDisplay(title: String? = nil,
                                   state: ToastState = .success ) {
        switch state {
        case .error:
            Loaf(title ?? "", state: .error, sender: self).show()
        case .info:
            Loaf(title ?? "", state: .info, sender: self).show()
        case .success:
            Loaf(title ?? "", state: .success, sender: self).show()
        case .warning:
            Loaf(title ?? "", state: .warning, sender: self).show()
        }
    }
}
