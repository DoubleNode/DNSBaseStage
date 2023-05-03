//
//  DNSBaseStageViewController+DisplayLogic.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import AtomicSwift
import Combine
import DNSBaseTheme
import DNSCore
import DNSCoreThreading
import DNSError
import GTBlurView
import JGProgressHUD
import JKDrawer
import kCustomAlert
import Loaf
import SFSymbol
import UIKit

extension DNSBaseStageViewController: UIAdaptivePresentationControllerDelegate {
    public enum ToastState {
        case error, info, success, warning
    }
    var hud: JGProgressHUD {
        return JGProgressHUD(style: .dark)
    }

    // MARK: - Lifecycle Methods -
    public func startStage(_ viewModel: BaseStage.Models.Start.ViewModel) {
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            self.displayMode = viewModel.displayMode
            self.displayOptions = viewModel.displayOptions

            self.implementDisplayOptionsPreStart()
            defer {
                self.implementDisplayOptionsPostStart()
            }

            var presentingViewController: UIViewController? = self.baseConfigurator?.parentConfigurator?.baseViewController
            if presentingViewController != nil {
                if presentingViewController!.view.superview == nil ||
                    presentingViewController!.isBeingDismissed {
                    presentingViewController = presentingViewController!.parent as? DNSUIViewController
                }
            }
            if presentingViewController == nil {
                presentingViewController = self.baseConfigurator?.rootViewController
            }
            if presentingViewController == nil {
                presentingViewController = DNSCore.appDelegate?.rootViewController()
            }

            var viewControllerToPresent: UIViewController = self
            if let navDrawerController = self.baseConfigurator?.navDrawerController {
                viewControllerToPresent = navDrawerController
            } else if let navigationController = self.baseConfigurator?.navigationController {
                viewControllerToPresent = navigationController
            }

            switch self.displayMode {
            case .drawer(let animated)?:
                self.startStageDrawer(animated: animated,
                                      presentingViewController: presentingViewController as! DrawerPresenting,
                                      viewControllerToPresent: viewControllerToPresent as! DrawerPresentable)
            case .modal?:
                viewControllerToPresent = self
                self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.automatic,
                                     animated: viewModel.animated,
                                     presentingViewController: presentingViewController,
                                     viewControllerToPresent: viewControllerToPresent)
            case .modalCurrentContext?:
                viewControllerToPresent = self
                self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.overCurrentContext,
                                     animated: viewModel.animated,
                                     presentingViewController: presentingViewController,
                                     viewControllerToPresent: viewControllerToPresent)
            case .modalFormSheet?:
                viewControllerToPresent = self
                self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.formSheet,
                                     animated: viewModel.animated,
                                     presentingViewController: presentingViewController,
                                     viewControllerToPresent: viewControllerToPresent)
            case .modalFullScreen?:
//                viewControllerToPresent = self
                viewControllerToPresent = UINavigationController(rootViewController: self)
                self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.fullScreen,
                                     animated: viewModel.animated,
                                     presentingViewController: presentingViewController,
                                     viewControllerToPresent: viewControllerToPresent)
            case .modalPageSheet?:
                viewControllerToPresent = self
                self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.pageSheet,
                                     animated: viewModel.animated,
                                     presentingViewController: presentingViewController,
                                     viewControllerToPresent: viewControllerToPresent)
            case .modalPopover?:
                viewControllerToPresent = self
                self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.popover,
                                     animated: viewModel.animated,
                                     presentingViewController: presentingViewController,
                                     viewControllerToPresent: viewControllerToPresent)
            case .navBarPush(let animated)?:
                if let navDrawerController = self.baseConfigurator?.navDrawerController {
                    self.startStageNavBarPush(navBarController: navDrawerController, viewModel, animated)
                } else if let navigationController = self.baseConfigurator?.navigationController {
                    self.startStageNavBarPush(navBarController: navigationController, viewModel, animated)
                }
            case .navBarRoot(let animated)?:
                var navController: UINavigationController?
                if let navDrawerController = self.baseConfigurator?.navDrawerController {
                    navController = navDrawerController
                } else if let navigationController = self.baseConfigurator?.navigationController {
                    navController = navigationController
                }
                guard let navController = navController else { return }
                guard let presentingViewController = presentingViewController else { return }
                if navController.view.superview == nil {
                    self.utilityPresent(viewControllerToPresent: navController,
                                        using: presentingViewController,
                                        animated: animated) { success in
                        guard success else {
                            DNSCore.reportLog("navBarRoot - utilityPresent failed:" +
                                                " presenting \(type(of: navController))" +
                                                " on \(type(of: presentingViewController))")
                            return
                        }
                        navController.setViewControllers([ self ], animated: animated)
                    }
                    return
                }
                navController.setViewControllers([ self ], animated: animated)
            case .navBarRootReplace:
                var navController: UINavigationController?
                if let navDrawerController = self.baseConfigurator?.navDrawerController {
                    navController = navDrawerController
                } else if let navigationController = self.baseConfigurator?.navigationController {
                    navController = navigationController
                }
                guard let navController = navController else { return }
                var viewControllers = navController.viewControllers
                self.tabBarItem.image = navController.tabBarItem.image ??
                    viewControllers.first?.tabBarItem.image
                self.tabBarItem.selectedImage = navController.tabBarItem.selectedImage ??
                    viewControllers.first?.tabBarItem.selectedImage
                viewControllers.removeAll { $0 == self }
                viewControllers.insert(self, at: 0)
                navController.setViewControllers(viewControllers, animated: false)
            case .navBarRootReset:
                var navController: UINavigationController?
                if let navDrawerController = self.baseConfigurator?.navDrawerController {
                    navController = navDrawerController
                } else if let navigationController = self.baseConfigurator?.navigationController {
                    navController = navigationController
                }
                guard let navController = navController else { return }
                let viewControllers = [ self ]
                self.tabBarItem.image = navController.tabBarItem.image ??
                    viewControllers.first?.tabBarItem.image
                self.tabBarItem.selectedImage = navController.tabBarItem.selectedImage ??
                    viewControllers.first?.tabBarItem.selectedImage
                navController.setViewControllers(viewControllers, animated: false)
            case.tabBarAdd(let animated, let tabNdx)?:
                guard self.baseConfigurator?.tabBarController != nil else { return }
                let tabBarController = self.baseConfigurator!.tabBarController!
                _ = DNSUIThread.run(after: 0.1) {
                    var viewControllers = tabBarController.viewControllers ?? []
                    if viewControllers.contains(viewControllerToPresent) {
                        let index = viewControllers.firstIndex(of: viewControllerToPresent)
                        viewControllers.remove(at: index!)
                    }
                    if tabNdx < viewControllers.count {
                        viewControllers.insert(viewControllerToPresent, at: tabNdx)
                    } else {
                        viewControllers.append(viewControllerToPresent)
                    }
                    tabBarController.setViewControllers(viewControllers, animated: animated)
                }
            default:
                break
            }
        }
    }
    private func startStageDrawer(animated: Bool,
                                  presentingViewController: DrawerPresenting,
                                  viewControllerToPresent: DrawerPresentable) {
        DNSUIThread.run {
            let presentingVC = presentingViewController as? DNSBaseStageViewController
            guard let vcToPresent = viewControllerToPresent as? UIViewController else {
                return
            }
            presentingVC?.stageWillHide()
            presentingViewController.openDrawer(viewControllerToPresent,
                                                animated: animated)
            vcToPresent.viewWillAppear(animated)
            vcToPresent.viewDidAppear(animated)
            presentingVC?.stageDidHide()
        }
    }
    private func startStageModal(modalPresentationStyle: UIModalPresentationStyle,
                                 animated: Bool,
                                 presentingViewController: UIViewController?,
                                 viewControllerToPresent: UIViewController) {
        guard var presentingViewController = presentingViewController else {
            return
        }
        guard !self.isModal else {
            return
        }
        viewControllerToPresent.isModalInPresentation = !displayOptions
            .filter { $0 == .modalNotDismissable }
            .isEmpty

        DNSUIThread.run {
            if let topController = UIViewController.topController as? DNSBaseStageViewController {
                if topController.isModal {
                    presentingViewController = topController
                }
            }
            _ = DNSUIThread.run(after: 0.1) { [weak self] in
                guard let self else { return }
                self.presentationController?.delegate = presentingViewController as? UIAdaptivePresentationControllerDelegate
                self.definesPresentationContext = true
                self.modalPresentationStyle = modalPresentationStyle
                self.modalTransitionStyle = .coverVertical
                (presentingViewController as? DNSBaseStageViewController)?.stageWillHide()
                self.utilityPresent(viewControllerToPresent: viewControllerToPresent,
                                    using: presentingViewController,
                                    animated: animated) { success in
                    guard success else {
                        DNSCore.reportLog("startStageModal - utilityPresent failed:" +
                                            " presenting \(type(of: viewControllerToPresent))" +
                                            " on \(type(of: presentingViewController))")
                        return
                    }
                    (presentingViewController as? DNSBaseStageViewController)?.stageDidHide()
                }
            }
        }
    }
    private func startStageNavBarPush(navBarController: UINavigationController,
                                      _ viewModel: BaseStage.Models.Start.ViewModel,
                                      _ animated: Bool) {
        let animated: Bool = viewModel.animated && animated
        DNSUIThread.run { [weak self] in
            guard let self else { return }
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
    public func endStage(_ viewModel: BaseStage.Models.Finish.ViewModel) {
        self.displayMode = viewModel.displayMode
        var presentingViewController: UIViewController? = self.baseConfigurator?.parentConfigurator?.baseViewController
        if presentingViewController != nil {
            if presentingViewController!.view.superview == nil ||
                presentingViewController!.isBeingDismissed {
                presentingViewController = presentingViewController!.parent
            }
        }
        if presentingViewController == nil {
            presentingViewController = self.baseConfigurator?.rootViewController
        }
        if presentingViewController == nil {
            presentingViewController = DNSCore.appDelegate?.rootViewController()
        }
        if presentingViewController == nil {
            presentingViewController = self.parent
        }

        switch self.displayMode {
        case .drawer(let animated)?:
            guard let presentingViewController = presentingViewController as? DrawerPresenting else {
                return
            }
            self.endStageDrawer(animated: animated,
                                presentingViewController: presentingViewController,
                                viewControllerToEnd: self)
        case .modal?, .modalCurrentContext?, .modalFormSheet?, .modalFullScreen?,
             .modalPageSheet?, .modalPopover?:
            DNSUIThread.run { [weak self] in
                guard let self else { return }
                self.presentationController?.delegate = nil
                self.dismiss(animated: viewModel.animated)
            }
        case .navBarPush(let animated)?:
            if let navDrawerController = self.baseConfigurator?.navDrawerController {
                self.endStageNavBarPush(navBarController: navDrawerController, viewModel, animated)
            } else if let navigationController = self.baseConfigurator?.navigationController {
                self.endStageNavBarPush(navBarController: navigationController, viewModel, animated)
            }
        case .navBarRoot(let animated)?:
            if let navDrawerController = self.baseConfigurator?.navDrawerController {
                DNSUIThread.run { [weak self] in
                    guard let self else { return }
                    navDrawerController.dismiss(animated: viewModel.animated && animated) {
                        self.baseConfigurator?.navDrawerController = nil
                    }
                }
            } else if let navigationController = self.baseConfigurator?.navigationController {
                DNSUIThread.run { [weak self] in
                    guard let self else { return }
                    navigationController.dismiss(animated: viewModel.animated && animated) {
                        self.baseConfigurator?.navigationController = nil
                    }
                }
            }
        case .navBarRootReplace?, .navBarRootReset?:
            if let navDrawerController = self.baseConfigurator?.navDrawerController {
                guard navDrawerController.viewControllers.contains(self) else { return }
                DNSUIThread.run { [weak self] in
                    guard let self else { return }
                    navDrawerController.dismiss(animated: viewModel.animated) {
                        self.baseConfigurator?.navDrawerController = nil
                    }
                }
            } else if let navigationController = self.baseConfigurator?.navigationController {
                guard navigationController.viewControllers.contains(self) else { return }
                DNSUIThread.run { [weak self] in
                    guard let self else { return }
                    navigationController.dismiss(animated: viewModel.animated) {
                        self.baseConfigurator?.navigationController = nil
                    }
                }
            }
        case.tabBarAdd(let animated, _/*tabNdx*/)?:
            guard self.baseConfigurator?.tabBarController != nil else { return }
            let tabBarController = self.baseConfigurator!.tabBarController!
            guard tabBarController.viewControllers?.contains(self) ?? false else { return }
            DNSUIThread.run { [weak self] in
                guard let self else { return }
                var viewControllers = tabBarController.viewControllers ?? []
                if viewControllers.contains(self) {
                    let index = viewControllers.firstIndex(of: self)
                    viewControllers.remove(at: index!)
                }
                tabBarController.setViewControllers(viewControllers, animated: animated)
                self.removeFromParent()
            }
        default:
            break
        }
    }
    private func endStageDrawer(animated: Bool,
                                presentingViewController: DrawerPresenting,
                                viewControllerToEnd: DrawerPresentable) {
        DNSUIThread.run {
            let presentingVC = presentingViewController as? DNSBaseStageViewController
            guard let vcToEnd = viewControllerToEnd as? UIViewController else {
                return
            }
            presentingVC?.stageWillAppear()
            vcToEnd.viewWillDisappear(animated)
            presentingViewController.closeDrawer(viewControllerToEnd,
                                                 animated: animated)
            vcToEnd.viewDidDisappear(animated)
            presentingVC?.stageDidAppear()
            guard let tabBarController = (presentingViewController as? UITabBarController) else {
                return
            }
            var tabViewControllers = tabBarController.viewControllers
            tabViewControllers?.removeAll(where: { $0 == vcToEnd })
            tabBarController.setViewControllers(tabViewControllers,
                                                animated: false)
        }
    }
    private func endStageNavBarPush(navBarController: UINavigationController,
                                    _ viewModel: BaseStage.Models.Finish.ViewModel,
                                    _ animated: Bool) {
        let animated: Bool = viewModel.animated && animated
        guard navBarController.viewControllers.contains(self) else { return }
        guard !navBarController.viewControllers.isEmpty else { return }
        
        var delay = 0.1
        if !self.children.isEmpty {
            delay = 0.5
        }
        _ = DNSUIThread.run(after: delay) {
            navBarController.popViewController(animated: animated)
        }
    }
    internal func implementDisplayOptionsPreStart() {
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            var drawerClosable = false
            var drawerDraggable = false
            var drawerGravity = Gravity.bottom
            self.displayOptions.forEach {
                switch $0 {
                case .drawerClosable:
                    drawerClosable = true
                case .drawerDraggable:
                    drawerDraggable = true
                case .drawerGravity(let gravity):
                    drawerGravity = gravity
                case .navDrawerController:
                    guard self.baseConfigurator?.navDrawerController == nil else { break }
                    self.baseConfigurator?
                        .navDrawerController = DNSUINavDrawerController(rootViewController: self,
                                                                        configuration: self.configuration)
                case .navController:
                    guard self.baseConfigurator?.navigationController == nil else { break }
                    self.baseConfigurator?
                        .navigationController = DNSUINavigationController(rootViewController: self)
                default:
                    break
                }
            }
            self.configuration = DrawerConfiguration(gravity: drawerGravity,
                                                     offset: self.configuration.initialOffset,
                                                     isDraggable: drawerDraggable,
                                                     isClosable: drawerClosable)
        }
    }
    internal func implementDisplayOptionsPostStart() {
        guard !displayOptions.isEmpty else { return }
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            var containsNavBarForced = false

            for displayOption in self.displayOptions {
                switch displayOption {
                case .navBarRightClose:
                    self.navigationItem.rightBarButtonItem =
                        UIBarButtonItem(title: "Close",
                                        style: .plain,
                                        target: self,
                                        action: #selector(self.closeButtonAction))
                    self.navigationItem.rightBarButtonItem?.image = UIImage(dnsSymbol: SFSymbol.xmark)
                case .navBarHidden(let animated):
                    containsNavBarForced = true
                    self.navigationController?.setNavigationBarHidden(true, animated: animated)
                    _ = DNSUIThread.run(after:0.1) { [weak self] in
                        guard let self else { return }
                        self.navigationController?.setNavigationBarHidden(true, animated: animated)
                    }
                case .navBarShown(let animated):
                    containsNavBarForced = true
                    self.navigationController?.setNavigationBarHidden(false, animated: animated)
                    _ = DNSUIThread.run(after:0.1) { [weak self] in
                        guard let self else { return }
                        self.navigationController?.setNavigationBarHidden(false, animated: animated)
                    }
                default:
                    break
                }
            }
            
            if !containsNavBarForced {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }

    // MARK: - Display logic -
    public func displayConfirmation(_ viewModel: BaseStage.Models.Confirmation.ViewModel) {
        self.utilityAutoTrack("\(#function)")

        DNSUIThread.run { [weak self] in
            guard let self else { return }
            var alertStyle = viewModel.alertStyle
            if DNSDevice.isIpad {
                alertStyle = UIAlertController.Style.alert
            }
            let textFieldPlaceholder0 = (viewModel.textFields.count >= 1) ? viewModel.textFields[0].placeholder : ""
            let textFieldPlaceholder1 = (viewModel.textFields.count >= 2) ? viewModel.textFields[1].placeholder : ""
            if textFieldPlaceholder0?.count ?? 0 > 0 ||
                textFieldPlaceholder1?.count ?? 0 > 0 {
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
                    self.updateBlurredViewDisplay(display: false)
                    var textField1: BaseStage.Models.Confirmation.Request.TextField?
                    var textField2: BaseStage.Models.Confirmation.Request.TextField?

                    if alertController.textFields?.count ?? 0 > 0 {
                        textField1 = BaseStage.Models.Confirmation.Request.TextField()
                        textField1!.value = alertController.textFields?[0].text
                    }
                    if alertController.textFields?.count ?? 0 > 1 {
                        textField2 = BaseStage.Models.Confirmation.Request.TextField()
                        textField2!.value = alertController.textFields?[1].text
                    }

                    let request = BaseStage.Models.Confirmation.Request()
                    request.selection = viewModelButton.code
                    if textField1 != nil {
                        request.textFields.append(textField1!)
                    }
                    if textField2 != nil {
                        request.textFields.append(textField2!)
                    }
                    request.userData = viewModel.userData

                    self.confirmationPublisher.send(request)
                }

                alertController.addAction(button)
            }

            let presentingViewController: UIViewController = UIViewController.topController ?? self
            self.updateBlurredViewDisplay(display: true)
            self.utilityPresent(viewControllerToPresent: alertController,
                                using: presentingViewController,
                                animated: true) { success in
                guard success else {
                    DNSCore.reportLog("displayConfirmation - utilityPresent failed:" +
                                        " presenting \(type(of: alertController))" +
                                        " on \(type(of: self))")
                    return
                }
            }
        }
    }
    public func displayDisabled(_ viewModel: BaseStage.Models.Disabled.ViewModel) {
        self.utilityAutoTrack("\(#function)")
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            self.updateDisabledViewDisplay(display: viewModel.show)
        }
    }
    public func displayDismiss(_ viewModel: BaseStage.Models.Dismiss.ViewModel) {
        self.utilityAutoTrack("\(#function)")
        self.endStage(BaseStage.Models.Finish.ViewModel(animated: viewModel.animated,
                                                        displayMode: self.displayMode!))
    }
    public func displayMessage(_ viewModel: BaseStage.Models.Message.ViewModel) {
        self.utilityAutoTrack("\(#function)")
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            switch viewModel.style {
            case .none:
                break
            case .hudShow:
                self.updateHudDisplay(display: true, percent: viewModel.percentage, with: viewModel.title)
            case .hudHide:
                self.updateHudDisplay(display: false)
            case .popup, .popupAction:
                var okayText = "OK"
                var okayStyle: DNSThemeButtonStyle = DNSThemeButtonStyle.default
                var cancelText = "CANCEL"
                var cancelStyle: DNSThemeButtonStyle = DNSThemeButtonStyle.default
                var nibName = "DNSBaseStagePopupViewController"
                var nibBundle: Bundle?
                if !viewModel.cancelText.isEmpty {
                    cancelText = viewModel.cancelText
                    cancelStyle = viewModel.cancelStyle
                }
                if !viewModel.nibName.isEmpty {
                    nibName = viewModel.nibName
                    nibBundle = viewModel.nibBundle
                }
                if !viewModel.actions.isEmpty {
                    if let actionValue = viewModel.actions.values.first {
                        okayText = actionValue
                        okayStyle = viewModel.actionsStyles.values.first ?? DNSThemeButtonStyle.default
                    }
                }
                let actionOkayBlock: DNSStringBlock = { actionText in
                    self.updateBlurredViewDisplay(display: false)
                    DNSThread.run(after: 0.6) { [weak self] in
                        guard let self else { return }
                        // if .popup, then only 'OK' button for standard "dismiss" (ie: cancelled = true)
                        var actionCode = DNSBaseStage.ActionCodes.okay
                        viewModel.actions.forEach { (key, value) in
                            if actionText == value {
                                actionCode = key
                            }
                        }
                        if viewModel.userData is Error {
                            self.errorDonePublisher
                                .send(BaseStage.Models.Message.Request(actionCode: actionCode,
                                                                       cancelled: viewModel.style == .popup,
                                                                       userData: viewModel.userData))
                        } else {
                            self.messageDonePublisher
                                .send(BaseStage.Models.Message.Request(actionCode: actionCode,
                                                                       cancelled: viewModel.style == .popup,
                                                                       userData: viewModel.userData))
                        }
                    }
                }
                let actionCancelBlock: DNSStringBlock = { actionText in
                    self.updateBlurredViewDisplay(display: false)
                    DNSThread.run(after: 0.6) { [weak self] in
                        guard let self else { return }
                        var actionCode = DNSBaseStage.ActionCodes.cancel
                        viewModel.actions.forEach { (key, value) in
                            if actionText == value {
                                actionCode = key
                            }
                        }
                        if viewModel.userData is Error {
                            self.errorDonePublisher
                                .send(BaseStage.Models.Message.Request(actionCode: actionCode,
                                                                       cancelled: true,
                                                                       userData: viewModel.userData))
                        } else {
                            self.messageDonePublisher
                                .send(BaseStage.Models.Message.Request(actionCode: actionCode,
                                                                       cancelled: true,
                                                                       userData: viewModel.userData))
                        }
                    }
                }

                var actionOkay: [String: DNSStringBlock] = [:]
                var actionOkayStyle: [String: DNSThemeButtonStyle] = [:]
                if viewModel.actions.isEmpty {
                    actionOkay = [ okayText: actionOkayBlock ]
                    actionOkayStyle = [ okayText: okayStyle ]
                } else {
                    viewModel.actions.forEach { (_, value) in
                        actionOkay[value] = actionOkayBlock
                        actionOkayStyle[value] = okayStyle
                    }
                }
                var actionCancel: [String: DNSStringBlock] = [:]
                var actionCancelStyle: [String: DNSThemeButtonStyle] = [:]
                if viewModel.style == .popupAction {
                    actionCancel = [ cancelText: actionCancelBlock ]
                    actionCancelStyle = [ cancelText: cancelStyle ]
                }
                let actions = [
                    actionOkay,
                    actionCancel
                ]
                let actionsStyles = [
                    actionOkayStyle,
                    actionCancelStyle,
                ]

                if self.isOnTop || self.isViewLoaded {
                    self.updateBlurredViewDisplay(display: true)
                    self.showCustomAlertWith(nibName: nibName,
                                             nibBundle: nibBundle,
                                             tags: viewModel.tags,
                                             title: viewModel.title,
                                             subtitle: viewModel.subtitle,
                                             message: viewModel.message,
                                             disclaimer: viewModel.disclaimer,
                                             image: viewModel.image,
                                             imageUrl: viewModel.imageUrl,
                                             actions: actions,
                                             actionsStyles: actionsStyles)
                }
            case .toastError:
                self.updateToastDisplay(message: viewModel.message,
                                        state: .error,
                                        presentingDirection: viewModel.presentingDirection,
                                        dismissingDirection: viewModel.dismissingDirection,
                                        duration: viewModel.duration,
                                        location: viewModel.location)
            case .toastInfo:
                self.updateToastDisplay(message: viewModel.message,
                                        state: .info,
                                        presentingDirection: viewModel.presentingDirection,
                                        dismissingDirection: viewModel.dismissingDirection,
                                        duration: viewModel.duration,
                                        location: viewModel.location)
            case .toastSuccess:
                self.updateToastDisplay(message: viewModel.message,
                                        state: .success,
                                        presentingDirection: viewModel.presentingDirection,
                                        dismissingDirection: viewModel.dismissingDirection,
                                        duration: viewModel.duration,
                                        location: viewModel.location)
            case .toastWarning:
                self.updateToastDisplay(message: viewModel.message,
                                        state: .warning,
                                        presentingDirection: viewModel.presentingDirection,
                                        dismissingDirection: viewModel.dismissingDirection,
                                        duration: viewModel.duration,
                                        location: viewModel.location)
            }
        }
    }
    public func displaySpinner(_ viewModel: BaseStage.Models.Spinner.ViewModel) {
        self.utilityAutoTrack("\(#function)")
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            self.updateSpinnerDisplay(display: viewModel.show)
        }
    }
    public func displayTitle(_ viewModel: BaseStage.Models.Title.ViewModel) {
        self.utilityAutoTrack("\(#function)")
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            if viewModel.tabBarUnselectedImage != nil {
                self.tabBarItem.image = viewModel.tabBarUnselectedImage
                self.navigationController?.tabBarItem.image = viewModel.tabBarUnselectedImage
            }
            if viewModel.tabBarSelectedImage != nil {
                self.tabBarItem.selectedImage = viewModel.tabBarSelectedImage
                self.navigationController?.tabBarItem.selectedImage = viewModel.tabBarSelectedImage
            }
            // This need to be AFTER the tabBar image assignments above
            self.stageTitle = viewModel.title
        }
    }

    // MARK: - parent class methods -
    public func updateBlurredViewDisplay(display: Bool) {
        guard let blurredView = self.blurredView else {
            self.updateDisabledViewDisplay(display: display)
            return
        }
        let displayAlpha: CGFloat = display ? 1.0 : 0.0
        
        let headerHeight: CGFloat = (self.navigationController?.navigationBar.y ?? 0) +
        (self.navigationController?.navigationBar.height ?? 0)
        if headerHeight > 0 && (self.blurredViewTopConstraint?.constant ?? 0 >= CGFloat(0)) {
            self.blurredViewTopConstraint?.constant = 0 - headerHeight
        }
        let footerHeight: CGFloat = (self.tabBarController?.tabBar.height ?? 0)
        if footerHeight > 0 && (self.blurredViewBottomConstraint?.constant ?? 0 >= CGFloat(0)) {
            self.blurredViewBottomConstraint?.constant = 0 - footerHeight
        }
        if display {
            self.tabBarController?.tabBar.layer.zPosition = -1
        }
        self.tabBarController?.tabBar.items?.forEach { $0.isEnabled = !display }
        self.view.addSubview(blurredView)
        if display {
            self.intBlurView.set(style: .systemUltraThinMaterialDark).show()
        }
        if displayAlpha > 0.0 {
            dnsLog.debug("***** Showing Blur ***** (currently \(blurredView.alpha))")
        } else {
            dnsLog.debug("***** Hiding Blur ***** (currently \(blurredView.alpha))")
        }
        UIView.animate(withDuration: 0.3,
                       animations: {
            blurredView.alpha = displayAlpha
        },
                       completion: { (_) in
            if !display {
                self.tabBarController?.tabBar.layer.zPosition = 0
            }
        })
    }
    public func updateDisabledViewDisplay(display: Bool) {
        guard self.disabledView != nil else { return }
        let disabledView = self.disabledView!
        let displayAlpha: CGFloat = display ? 1.0 : 0.0

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
            disabledView.alpha = displayAlpha
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
            _ = DNSUIThread.run(after: 2.5) { [weak self] in
                guard let self else { return }
                self.hud.dismiss(animated: true)
                self.updateDisabledViewDisplay(display: false)
            }
        }
    }
    public func updateSpinnerDisplay(display: Bool) {
        self.updateDisabledViewDisplay(display: display)
        if display {
            self.activityIndicator?.isHidden = false
            self.activityIndicator?.startAnimating()
        } else {
            self.activityIndicator?.isHidden = true
            self.activityIndicator?.stopAnimating()
        }
    }
    public func updateToastDisplay(message: String? = nil,
                                   state: ToastState = .success,
                                   presentingDirection: BaseStage.Models.Direction = .vertical,
                                   dismissingDirection: BaseStage.Models.Direction = .vertical,
                                   duration: BaseStage.Models.Duration = .average,
                                   location: BaseStage.Models.Location = .bottom) {
        let viewController = UIViewController.topController ?? self
        let loafState: Loaf.State
        switch state {
        case .error:
            loafState = .error
        case .info:
            loafState = .info
        case .success:
            loafState = .success
        case .warning:
            loafState = .warning
        }
        let loafLocation: Loaf.Location
        switch location {
        case .top:
            loafLocation = .top
        case .bottom, .default:
            loafLocation = .bottom
        }
        let loafPresentingDirection: Loaf.Direction
        switch presentingDirection {
        case .left:
            loafPresentingDirection = .left
        case .right:
            loafPresentingDirection = .right
        case .vertical, .default:
            loafPresentingDirection = .vertical
        }
        let loafDismissingDirection: Loaf.Direction
        switch dismissingDirection {
        case .left:
            loafDismissingDirection = .left
        case .right:
            loafDismissingDirection = .right
        case .vertical, .default:
            loafDismissingDirection = .vertical
        }
        let loaf = Loaf(message ?? "",
                        state: loafState,
                        location: loafLocation,
                        presentingDirection: loafPresentingDirection,
                        dismissingDirection: loafDismissingDirection,
                        sender: viewController)
        let loafDuration: Loaf.Duration
        switch duration {
        case .short:
            loafDuration = .short
        case .average, .default:
            loafDuration = .average
        case .long:
            loafDuration = .long
        case .custom(let timeInterval):
            loafDuration = .custom(timeInterval)
        }
        loaf.show(loafDuration) { _/*dismissalReason*/ in }
    }

    // MARK: - UIAdaptivePresentationControllerDelegate methods -
    open func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }
    open func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewDidAppear(false)
    }
}
