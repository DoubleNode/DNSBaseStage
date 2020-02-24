//
//  DNSBaseStageViewController+DisplayLogic.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import Combine
import DNSCore
import DNSCoreThreading
import JGProgressHUD
import Loaf
import SFSymbol
import UIKit

extension DNSBaseStageViewController {
    public enum ToastState {
        case error, info, success, warning
    }

    var hud: JGProgressHUD {
        return JGProgressHUD(style: .dark)
    }

    // MARK: - Stage Lifecycle Methods -

    open func stageDidAppear() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        stageDidAppearPublisher.send(DNSBaseStageModels.Base.Request())
    }

    open func stageDidClose() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        stageDidClosePublisher.send(DNSBaseStageModels.Base.Request())
    }

    open func stageDidDisappear() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        stageDidDisappearPublisher.send(DNSBaseStageModels.Base.Request())
    }

    open func stageDidHide() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        stageDidHidePublisher.send(DNSBaseStageModels.Base.Request())
    }

    open func stageDidLoad() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        stageDidLoadPublisher.send(DNSBaseStageModels.Base.Request())
    }

    open func stageWillAppear() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        stageWillAppearPublisher.send(DNSBaseStageModels.Base.Request())
    }

    open func stageWillDisappear() {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        stageWillDisappearPublisher.send(DNSBaseStageModels.Base.Request())
    }

    // MARK: - Lifecycle Methods -
    
    public func startStage(_ viewModel: DNSBaseStageModels.Start.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.displayType = viewModel.displayType
        self.displayOptions = viewModel.displayOptions

        self.implementDisplayOptionsPreStart()
        defer {
            self.implementDisplayOptionsPostStart()
        }

        var presentingViewController: UIViewController? = self.baseConfigurator?.parentConfigurator?.baseViewController
        if presentingViewController != nil {
            if presentingViewController!.view.superview == nil ||
                presentingViewController!.isBeingDismissed {
                presentingViewController = presentingViewController!.parent
            }
        }
        if presentingViewController == nil {
            presentingViewController = DNSCore.appDelegate.rootViewController()
        }

        var viewControllerToPresent: UIViewController = self
        if self.baseConfigurator?.navigationController != nil {
            // swiftlint:disable:next force_cast line_length
            viewControllerToPresent = self.baseConfigurator!.navigationController!
        }
        
        switch self.displayType {
        case .none?:
            break

        case .modal?:
            self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.automatic,
                                 animated: viewModel.animated,
                                 presentingViewController: presentingViewController,
                                 viewControllerToPresent: viewControllerToPresent)

        case .modalCurrentContext?:
            self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.overCurrentContext,
                                 animated: viewModel.animated,
                                 presentingViewController: presentingViewController,
                                 viewControllerToPresent: viewControllerToPresent)

        case .modalFormSheet?:
            self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.formSheet,
                                 animated: viewModel.animated,
                                 presentingViewController: presentingViewController,
                                 viewControllerToPresent: viewControllerToPresent)

        case .modalFullScreen?:
            self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.overFullScreen,
                                 animated: viewModel.animated,
                                 presentingViewController: presentingViewController,
                                 viewControllerToPresent: viewControllerToPresent)

        case .modalPageSheet?:
            self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.pageSheet,
                                 animated: viewModel.animated,
                                 presentingViewController: presentingViewController,
                                 viewControllerToPresent: viewControllerToPresent)

        case .modalPopover?:
            self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.popover,
                                 animated: viewModel.animated,
                                 presentingViewController: presentingViewController,
                                 viewControllerToPresent: viewControllerToPresent)

        case .navBarPush?, .navBarPushInstant?:
            guard self.baseConfigurator?.navigationController != nil else { return }
            let navigationController = self.baseConfigurator!.navigationController!
            
            self.startStageNavBarPush(navBarController: navigationController, viewModel)

        case .navBarRoot?, .navBarRootInstant?:
            guard self.baseConfigurator?.navigationController != nil else { return }
            let navigationController = self.baseConfigurator!.navigationController!

            let animated: Bool = (self.displayType == .navBarRoot)

            _ = DNSUIThread.run {
                navigationController.setViewControllers([ self ], animated: animated)
            }

        case .navBarRootReplace:
            guard self.baseConfigurator?.navigationController != nil else { return }
            let navigationController = self.baseConfigurator!.navigationController!
            
            _ = DNSUIThread.run {
                var viewControllers = navigationController.viewControllers
                if viewControllers.contains(self) {
                    let index = viewControllers.firstIndex(of: self)
                    if index! > 0 {
                        viewControllers.remove(at: index!)
                    }
                }
                viewControllers[0] = self

                navigationController.setViewControllers(viewControllers, animated: false)
            }
            
        case.tabBarAdd?, .tabBarAddInstant?:
            guard self.baseConfigurator?.tabBarController != nil else { return }
            let tabBarController = self.baseConfigurator!.tabBarController!

            let animated: Bool = (self.displayType == .tabBarAdd)

            _ = DNSUIThread.run {
                var viewControllers = tabBarController.viewControllers ?? []
                if viewControllers.contains(viewControllerToPresent) {
                    let index = viewControllers.firstIndex(of: viewControllerToPresent)
                    viewControllers.remove(at: index!)
                }
                viewControllers.append(viewControllerToPresent)

                tabBarController.setViewControllers(viewControllers, animated: animated)
            }

        default:
            break
        }
    }

    private func startStageModal(modalPresentationStyle: UIModalPresentationStyle,
                                 animated: Bool,
                                 presentingViewController: UIViewController?,
                                 viewControllerToPresent: UIViewController) {
        guard presentingViewController != nil else {
            return
        }
        _ = DNSUIThread.run {
            self.definesPresentationContext = true
            self.modalPresentationStyle = UIModalPresentationStyle.automatic
            self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            
            presentingViewController!.present(viewControllerToPresent, animated: animated) {
                (presentingViewController as? DNSBaseStageViewController)?.stageDidHide()
            }
        }
    }
    
    private func startStageNavBarPush(navBarController: UINavigationController,
                                      _ viewModel: DNSBaseStageModels.Start.ViewModel) {
        let animated: Bool = (viewModel.animated && (self.displayType == .navBarPush))

        _ = DNSUIThread.run {
            guard !navBarController.viewControllers.isEmpty else {
                navBarController.setViewControllers([ self ], animated: animated)
                return
            }
            guard navBarController.viewControllers.last != self else { return }

            if navBarController.viewControllers.contains(self) {
                let index = navBarController.viewControllers.firstIndex(of: self)
                if index != nil {
                    navBarController.viewControllers.remove(at: index!)
                }
            }

            let viewController      = navBarController.viewControllers.last
            let dnsViewController   = viewController as? DNSBaseStageViewController
            dnsViewController?.updateStageBackTitle()

            navBarController.pushViewController(self, animated: animated)
        }
    }

    public func endStage(_ viewModel: DNSBaseStageModels.Finish.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.displayType = viewModel.displayType

        var presentingViewController: UIViewController? = self.baseConfigurator?.parentConfigurator?.baseViewController
        if presentingViewController != nil {
            if presentingViewController!.view.superview == nil ||
                presentingViewController!.isBeingDismissed {
                presentingViewController = presentingViewController!.parent
            }
        }

        switch self.displayType {
        case .none?:
            break

        case .modal?, .modalCurrentContext?, .modalFormSheet?, .modalFullScreen?,
             .modalPageSheet?, .modalPopover?:
            _ = DNSUIThread.run {
                (presentingViewController as? DNSBaseStageViewController)?.stageWillAppear()
                self.dismiss(animated: viewModel.animated) {
                    (presentingViewController as? DNSBaseStageViewController)?.stageDidAppear()
                }
            }

        case .navBarPush?, .navBarPushInstant?:
            guard self.baseConfigurator?.navigationController != nil else { return }
            let navigationController = self.baseConfigurator!.navigationController!

            self.endStageNavBarPush(navBarController: navigationController, viewModel)

        case .navBarRoot?, .navBarRootInstant?, .navBarRootReplace? :
            guard self.baseConfigurator?.navigationController != nil else { return }
            let navigationController = self.baseConfigurator!.navigationController!

            guard navigationController.viewControllers.contains(self) else { return }
            
            _ = DNSUIThread.run {
                navigationController.dismiss(animated: viewModel.animated) {
                    self.baseConfigurator?.navigationController = nil
                }
            }

        case.tabBarAdd?, .tabBarAddInstant?:
            guard self.baseConfigurator?.tabBarController != nil else { return }
            let tabBarController = self.baseConfigurator!.tabBarController!

            guard tabBarController.viewControllers?.contains(self) ?? false else { return }

            let animated: Bool = (viewModel.animated && (self.displayType == .tabBarAdd))

            var viewControllers = tabBarController.viewControllers
            let index = viewControllers?.firstIndex(of: self)
            viewControllers?.remove(at: index!)

            _ = DNSUIThread.run {
                tabBarController.setViewControllers(viewControllers, animated: animated)
                self.removeFromParent()
            }

        default:
            break
        }
    }

    private func endStageNavBarPush(navBarController: UINavigationController,
                                    _ viewModel: DNSBaseStageModels.Finish.ViewModel) {
        let animated: Bool = (viewModel.animated && (self.displayType == .navBarPush))

        guard navBarController.viewControllers.contains(self) else { return }
        guard navBarController.viewControllers.count > 1 else { return }

        _ = DNSUIThread.run(after: 0.1) {
            navBarController.popViewController(animated: animated)
        }
    }

    private func implementDisplayOptionsPreStart() {
        guard !displayOptions.isEmpty else { return }

        weak var weakSelf = self
        _ = DNSUIThread.run {
            guard weakSelf != nil else { return }
            let weakSelf = weakSelf!
            for displayOption in weakSelf.displayOptions {
                switch displayOption {
                case .navController:
                    if weakSelf.baseConfigurator?.navigationController == nil {
                        weakSelf.baseConfigurator?.navigationController = UINavigationController(rootViewController: weakSelf)
                    }
                default:
                    break
                }
            }
        }
    }

    private func implementDisplayOptionsPostStart() {
        guard !displayOptions.isEmpty else { return }

        weak var weakSelf = self
        _ = DNSUIThread.run {
            guard weakSelf != nil else { return }
            let weakSelf = weakSelf!

            var containsNavBarForced = false

            for displayOption in weakSelf.displayOptions {
                switch displayOption {
                case .navBarRightClose:
                    weakSelf.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                                        style: .plain,
                                                                        target: weakSelf,
                                                                        action: #selector(weakSelf.closeNavBarButtonAction))
                    weakSelf.navigationItem.rightBarButtonItem?.image = UIImage(systemName: SFSymbol.xmark.rawValue)
                case .navBarHidden, .navBarHiddenInstant:
                    containsNavBarForced = true
                    let animated: Bool = (displayOption == .navBarHidden)
                    weakSelf.navigationController?.setNavigationBarHidden(true, animated: animated)
                    _ = DNSUIThread.run(after:0.1) {
                        weakSelf.navigationController?.setNavigationBarHidden(true, animated: animated)
                    }
                case .navBarShown, .navBarShownInstant:
                    containsNavBarForced = true
                    let animated: Bool = (displayOption == .navBarShown)
                    weakSelf.navigationController?.setNavigationBarHidden(false, animated: animated)
                    _ = DNSUIThread.run(after:0.1) {
                        weakSelf.navigationController?.setNavigationBarHidden(false, animated: animated)
                    }
                default:
                    break
                }
            }
            
            if !containsNavBarForced {
                weakSelf.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }

    // MARK: - Display logic -

    public func displayConfirmation(_ viewModel: DNSBaseStageModels.Confirmation.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        _ = DNSUIThread.run {
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
                                                style: viewModelButton.style!) { (_) in
                    var value1: String?
                    var value2: String?

                    if alertController.textFields?.count ?? 0 > 0 {
                        value1 = alertController.textFields?[0].text
                    }
                    if alertController.textFields?.count ?? 0 > 1 {
                        value2 = alertController.textFields?[1].text
                    }

                    let request = DNSBaseStageModels.Confirmation.Request()
                    request.selection = viewModelButton.code
                    request.textFields[0].value = value1
                    request.textFields[1].value = value2
                    request.userData = viewModel.userData

                    self.confirmationPublisher.send(request)
                }

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

        _ = DNSUIThread.run {
            switch viewModel.style {
            case .none:
                break
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
                self.updateToastDisplay(message: viewModel.message, state: .error)
            case .toastInfo:
                self.updateToastDisplay(message: viewModel.message, state: .info)
            case .toastSuccess:
                self.updateToastDisplay(message: viewModel.message, state: .success)
            case .toastWarning:
                self.updateToastDisplay(message: viewModel.message, state: .warning)
            }
        }
    }

    public func displaySpinner(_ viewModel: DNSBaseStageModels.Spinner.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        _ = DNSUIThread.run {
            self.updateSpinnerDisplay(display: viewModel.show)
        }
    }

    public func displayTitle(_ viewModel: DNSBaseStageModels.Title.ViewModel) {
        do { try self.analyticsWorker?.doTrack(event: "\(#function)") } catch { }

        self.stageTitle = viewModel.title
    }

    // MARK: - parent class methods -

    public func updateDisabledViewDisplay(display: Bool) {
        guard self.disabledView != nil else { return }
        let disabledView = self.disabledView!

        let headerHeight: CGFloat = (self.navigationController?.navigationBar.y ?? 0) +
            (self.navigationController?.navigationBar.height ?? 0)
        if headerHeight > 0 && (self.disabledViewTopConstraint?.constant ?? 0 >= CGFloat(0)) {
            self.disabledViewTopConstraint?.constant = 0 - headerHeight
        }

        if display {
            self.navigationController?.navigationBar.layer.zPosition = -1
        }

        self.view.addSubview(disabledView)

        UIView.animate(withDuration: 0.3,
                       animations: {
                        disabledView.alpha = display ? 1.0 : 0.0
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
            _ = DNSUIThread.run(after: 2.5) {
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

    public func updateToastDisplay(message: String? = nil,
                                   state: ToastState = .success ) {
        switch state {
        case .error:
            Loaf(message ?? "", state: .error, sender: self).show()
        case .info:
            Loaf(message ?? "", state: .info, sender: self).show()
        case .success:
            Loaf(message ?? "", state: .success, sender: self).show()
        case .warning:
            Loaf(message ?? "", state: .warning, sender: self).show()
        }
    }
}
