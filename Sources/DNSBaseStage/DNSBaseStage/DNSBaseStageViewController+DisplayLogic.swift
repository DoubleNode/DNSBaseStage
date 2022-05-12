//
//  DNSBaseStageViewController+DisplayLogic.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

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

    // MARK: - Stage Lifecycle Methods -
    open func stageDidAppear() {
        stageDidAppearPublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageDidClose() {
        stageDidClosePublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageDidDisappear() {
        stageDidDisappearPublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageDidHide() {
        stageDidHidePublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageDidLoad() {
        stageDidLoadPublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageWillAppear() {
        stageWillAppearPublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageWillDisappear() {
        stageWillDisappearPublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageWillHide() {
        stageWillHidePublisher.send(BaseStage.Models.Base.Request())
    }

    // MARK: - Lifecycle Methods -
    public func startStage(_ viewModel: BaseStage.Models.Start.ViewModel) {
        DNSUIThread.run {
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
//            } else if let navigationController = self.baseConfigurator?.navigationController {
//                viewControllerToPresent = navigationController
            }

            switch self.displayMode {
            case .drawer(let animated)?:
                self.startStageDrawer(animated: animated,
                                      presentingViewController: presentingViewController as! DrawerPresenting,
                                      viewControllerToPresent: viewControllerToPresent as! DrawerPresentable)
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
                viewControllerToPresent = self
                self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.pageSheet,
                                     animated: viewModel.animated,
                                     presentingViewController: presentingViewController,
                                     viewControllerToPresent: viewControllerToPresent)
            case .modalPopover?:
                self.startStageModal(modalPresentationStyle: UIModalPresentationStyle.popover,
                                     animated: viewModel.animated,
                                     presentingViewController: presentingViewController,
                                     viewControllerToPresent: viewControllerToPresent)
            case .navBarPush(let animated)?:
                if let navDrawerController = self.baseConfigurator?.navDrawerController {
                    self.startStageNavBarPush(navBarController: navDrawerController, viewModel, animated)
//                } else if let navigationController = self.baseConfigurator?.navigationController {
//                    self.startStageNavBarPush(navBarController: navigationController, viewModel, animated)
                }
            case .navBarRoot(let animated)?:
                var navController: UINavigationController?
                if let navDrawerController = self.baseConfigurator?.navDrawerController {
                    navController = navDrawerController
//                } else if let navigationController = self.baseConfigurator?.navigationController {
//                    navController = navigationController
                }
                guard let navController = navController else { return }
                guard let presentingViewController = presentingViewController else { return }
                DNSUIThread.run {
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
                }
            case .navBarRootReplace:
                var navController: UINavigationController?
                if let navDrawerController = self.baseConfigurator?.navDrawerController {
                    navController = navDrawerController
//                } else if let navigationController = self.baseConfigurator?.navigationController {
//                    navController = navigationController
                }
                guard let navController = navController else { return }
                DNSUIThread.run {
                    var viewControllers = navController.viewControllers
                    self.tabBarItem.image = navController.tabBarItem.image ??
                        viewControllers.first?.tabBarItem.image
                    self.tabBarItem.selectedImage = navController.tabBarItem.selectedImage ??
                        viewControllers.first?.tabBarItem.selectedImage
                    if viewControllers.contains(self) {
                        let index = viewControllers.firstIndex(of: self)
                        if index! > 0 {
                            viewControllers.remove(at: index!)
                        }
                    }
                    viewControllers[0] = self
                    navController.setViewControllers(viewControllers, animated: false)
                }
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
            if let topController = self.topController as? DNSBaseStageViewController {
                if topController.isModal {
                    presentingViewController = topController
                }
            }
            _ = DNSUIThread.run(after: 0.1) {
                self.presentationController?.delegate = presentingViewController as? UIAdaptivePresentationControllerDelegate
                self.definesPresentationContext = true
                self.modalPresentationStyle = modalPresentationStyle
                self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
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
        DNSUIThread.run {
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
            DNSUIThread.run {
                self.presentationController?.delegate = nil
                (presentingViewController as? DNSBaseStageViewController)?.stageWillAppear()
                self.dismiss(animated: viewModel.animated) {
                    (presentingViewController as? DNSBaseStageViewController)?.stageDidAppear()
                }
            }
        case .navBarPush(let animated)?:
            if let navDrawerController = self.baseConfigurator?.navDrawerController {
                self.endStageNavBarPush(navBarController: navDrawerController, viewModel, animated)
//            } else if let navigationController = self.baseConfigurator?.navigationController {
//                self.endStageNavBarPush(navBarController: navigationController, viewModel, animated)
            }
        case .navBarRoot(let animated)?:
            if let navDrawerController = self.baseConfigurator?.navDrawerController {
                DNSUIThread.run {
                    navDrawerController.dismiss(animated: viewModel.animated && animated) {
                        self.baseConfigurator?.navDrawerController = nil
                    }
                }
//            } else if let navigationController = self.baseConfigurator?.navigationController {
//                DNSUIThread.run {
//                    navigationController.dismiss(animated: viewModel.animated && animated) {
//                        self.baseConfigurator?.navigationController = nil
//                    }
//                }
            }
        case .navBarRootReplace?:
            if let navDrawerController = self.baseConfigurator?.navDrawerController {
                guard navDrawerController.viewControllers.contains(self) else { return }
                DNSUIThread.run {
                    navDrawerController.dismiss(animated: viewModel.animated) {
                        self.baseConfigurator?.navDrawerController = nil
                    }
                }
//            } else if let navigationController = self.baseConfigurator?.navigationController {
//                guard navigationController.viewControllers.contains(self) else { return }
//                DNSUIThread.run {
//                    navigationController.dismiss(animated: viewModel.animated) {
//                        self.baseConfigurator?.navigationController = nil
//                    }
//                }
            }
        case.tabBarAdd(let animated, _/*tabNdx*/)?:
            guard self.baseConfigurator?.tabBarController != nil else { return }
            let tabBarController = self.baseConfigurator!.tabBarController!
            guard tabBarController.viewControllers?.contains(self) ?? false else { return }
            DNSUIThread.run {
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
    private func implementDisplayOptionsPreStart() {
        weak var weakSelf = self
        DNSUIThread.run {
            guard weakSelf != nil else { return }
            var drawerClosable = false
            var drawerDraggable = false
            var drawerGravity = Gravity.bottom
            let weakSelf = weakSelf!
            weakSelf.displayOptions.forEach {
                switch $0 {
                case .drawerClosable:
                    drawerClosable = true
                case .drawerDraggable:
                    drawerDraggable = true
                case .drawerGravity(let gravity):
                    drawerGravity = gravity
                case .navDrawerController:
                    guard weakSelf.baseConfigurator?.navDrawerController == nil else { break }
                    weakSelf.baseConfigurator?
                        .navDrawerController = DNSUINavDrawerController(rootViewController: weakSelf,
                                                                        configuration: self.configuration)
                case .navController:
                    guard weakSelf.baseConfigurator?.navigationController == nil else { break }
                    weakSelf.baseConfigurator?
                        .navigationController = DNSUINavigationController(rootViewController: weakSelf)
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
    private func implementDisplayOptionsPostStart() {
        guard !displayOptions.isEmpty else { return }

        weak var weakSelf = self
        DNSUIThread.run {
            guard weakSelf != nil else { return }
            let weakSelf = weakSelf!

            var containsNavBarForced = false

            for displayOption in weakSelf.displayOptions {
                switch displayOption {
                case .navBarRightClose:
                    weakSelf.navigationItem.rightBarButtonItem =
                        UIBarButtonItem(title: "Close",
                                        style: .plain,
                                        target: weakSelf,
                                        action: #selector(weakSelf.closeNavBarButtonAction))
                    weakSelf.navigationItem.rightBarButtonItem?.image = UIImage(dnsSystemSymbol: SFSymbol.xmark)
                case .navBarHidden(let animated):
                    containsNavBarForced = true
                    weakSelf.navigationController?.setNavigationBarHidden(true, animated: animated)
                    _ = DNSUIThread.run(after:0.1) {
                        weakSelf.navigationController?.setNavigationBarHidden(true, animated: animated)
                    }
                case .navBarShown(let animated):
                    containsNavBarForced = true
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
    public func displayConfirmation(_ viewModel: BaseStage.Models.Confirmation.ViewModel) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        DNSUIThread.run {
            var alertStyle = viewModel.alertStyle
            if DNSDevice.iPad {
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

            if self.isOnTop {
                self.updateBlurredViewDisplay(display: true)
                self.utilityPresent(viewControllerToPresent: alertController,
                                    using: self,
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
    }
    public func displayDismiss(_ viewModel: BaseStage.Models.Dismiss.ViewModel) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
        self.endStage(BaseStage.Models.Finish.ViewModel(animated: viewModel.animated,
                                                        displayMode: self.displayMode!))
    }
    public func displayMessage(_ viewModel: BaseStage.Models.Message.ViewModel) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSUIThread.run {
            switch viewModel.style {
            case .none:
                break
            case .hudShow:
                self.updateHudDisplay(display: true, percent: viewModel.percentage, with: viewModel.title)
            case .hudHide:
                self.updateHudDisplay(display: false)
            case .popup, .popupAction:
                var actionText = "OK"
                var cancelText = "CANCEL"
                var nibName = "DNSBaseStagePopupViewController"
                if !viewModel.cancelText.isEmpty {
                    cancelText = viewModel.cancelText
                }
                if !viewModel.nibName.isEmpty {
                    nibName = viewModel.nibName
                }
                if !viewModel.actionText.isEmpty {
                    actionText = viewModel.actionText
                }
                let actionOkayBlock: DNSBlock = { () in
                    self.updateBlurredViewDisplay(display: false)
                    // if .popup, then only 'OK' button for standard "dismiss" (ie: cancelled = true)
                    self.messageDonePublisher
                        .send(BaseStage.Models.Message.Request(cancelled: viewModel.style == .popup,
                                                               userData: viewModel.userData))
                }
                let actionCancelBlock: DNSBlock = { () in
                    self.updateBlurredViewDisplay(display: false)
                    self.messageDonePublisher
                        .send(BaseStage.Models.Message.Request(cancelled: true,
                                                               userData: viewModel.userData))
                }

                var actionOkay: [String: DNSBlock] = [:]
                actionOkay = [ actionText: actionOkayBlock ]
                var actionCancel: [String: DNSBlock] = [:]
                if viewModel.style == .popupAction {
                    actionCancel = [ cancelText: actionCancelBlock ]
                }
                let actions = [
                    actionOkay,
                    actionCancel
                ]

                if self.isOnTop {
                    self.updateBlurredViewDisplay(display: true)
                    self.showCustomAlertWith(nibName: nibName,
                                             tags: viewModel.tags,
                                             title: viewModel.title,
                                             subTitle: viewModel.subTitle,
                                             message: viewModel.message,
                                             disclaimer: viewModel.disclaimer,
                                             image: viewModel.image,
                                             imageUrl: viewModel.imageUrl,
                                             actions: actions)
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
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSUIThread.run {
            self.updateSpinnerDisplay(display: viewModel.show)
        }
    }
    public func displayTitle(_ viewModel: BaseStage.Models.Title.ViewModel) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
        DNSUIThread.run {
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
        guard self.blurredView != nil else {
            self.updateDisabledViewDisplay(display: display)
            return
        }
        let blurredView = self.blurredView!
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
                                   state: ToastState = .success,
                                   presentingDirection: BaseStage.Models.Direction = .vertical,
                                   dismissingDirection: BaseStage.Models.Direction = .vertical,
                                   duration: BaseStage.Models.Duration = .average,
                                   location: BaseStage.Models.Location = .bottom) {
        let viewController = self.topController ?? self
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

    // MARK: - Utility methods -
    open func utilityPresent(viewControllerToPresent: UIViewController,
                             using presentingViewController: UIViewController,
                             animated: Bool,
                             completion: ((Bool) -> Void)? = nil) {
        if viewControllerToPresent.isBeingPresented {
            DNSCore.reportLog("cancel: presenting \(type(of: viewControllerToPresent))" +
                                " on \(type(of: presentingViewController))")
            completion?(false)
            return
        }
        DNSCore.reportLog("start: presenting \(type(of: viewControllerToPresent))" +
                            " on \(type(of: presentingViewController))")
        presentingViewController.present(viewControllerToPresent, animated: animated) {
            DNSCore.reportLog("stop: presenting \(type(of: viewControllerToPresent))" +
                                " on \(type(of: presentingViewController))")
            completion?(true)
        }
    }
}
