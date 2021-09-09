//
//  DNSBaseStageViewController.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Combine
import DNSCore
import DNSCoreThreading
import DNSProtocols
import GTBlurView
import IQKeyboardManagerSwift
import UIKit

public protocol DNSBaseStageDisplayLogic: AnyObject {
   // MARK: - Outgoing Pipelines
    var stageDidAppearPublisher: PassthroughSubject<DNSBaseStageBaseRequest, Never> { get }
    var stageDidClosePublisher: PassthroughSubject<DNSBaseStageBaseRequest, Never> { get }
    var stageDidDisappearPublisher: PassthroughSubject<DNSBaseStageBaseRequest, Never> { get }
    var stageDidHidePublisher: PassthroughSubject<DNSBaseStageBaseRequest, Never> { get }
    var stageDidLoadPublisher: PassthroughSubject<DNSBaseStageBaseRequest, Never> { get }
    var stageWillAppearPublisher: PassthroughSubject<DNSBaseStageBaseRequest, Never> { get }
    var stageWillDisappearPublisher: PassthroughSubject<DNSBaseStageBaseRequest, Never> { get }
    var stageWillHidePublisher: PassthroughSubject<DNSBaseStageBaseRequest, Never> { get }

    var closeNavBarButtonPublisher: PassthroughSubject<DNSBaseStageModels.Base.Request, Never> { get }
    var confirmationPublisher: PassthroughSubject<DNSBaseStageModels.Confirmation.Request, Never> { get }
    var errorOccurredPublisher: PassthroughSubject<DNSBaseStageModels.Error.Request, Never> { get }
    var messageDonePublisher: PassthroughSubject<DNSBaseStageModels.Message.Request, Never> { get }
    var webStartNavigationPublisher: PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never> { get }
    var webFinishNavigationPublisher: PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never> { get }
    var webErrorNavigationPublisher: PassthroughSubject<DNSBaseStageModels.WebpageError.Request, Never> { get }
    var webLoadProgressPublisher: PassthroughSubject<DNSBaseStageModels.WebpageProgress.Request, Never> { get }
}

extension DNSBaseStageViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

open class DNSBaseStageViewController: UIViewController, DNSBaseStageDisplayLogic {
    // MARK: - Public Associated Type Properties -
    public var baseConfigurator: DNSBaseStageConfigurator? {
        didSet {
            self.baseConfigurator?.configureStage()
        }
    }
    public lazy var intBlurView: GTBlurView = {
        GTBlurView.addBlur(to: self.blurredView!)
    }();

    // MARK: - Outgoing Pipelines -
    public let stageDidAppearPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageDidClosePublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageDidDisappearPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageDidHidePublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageDidLoadPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageWillAppearPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageWillDisappearPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageWillHidePublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()

    public let closeNavBarButtonPublisher = PassthroughSubject<DNSBaseStageModels.Base.Request, Never>()
    public let confirmationPublisher = PassthroughSubject<DNSBaseStageModels.Confirmation.Request, Never>()
    public let errorOccurredPublisher = PassthroughSubject<DNSBaseStageModels.Error.Request, Never>()
    public let messageDonePublisher = PassthroughSubject<DNSBaseStageModels.Message.Request, Never>()
    public let webStartNavigationPublisher = PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never>()
    public let webFinishNavigationPublisher = PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never>()
    public let webErrorNavigationPublisher = PassthroughSubject<DNSBaseStageModels.WebpageError.Request, Never>()
    public var webLoadProgressPublisher = PassthroughSubject<DNSBaseStageModels.WebpageProgress.Request, Never>()

    // MARK: - Incoming Pipelines -
    var stageStartSubscriber: AnyCancellable?
    var stageEndSubscriber: AnyCancellable?

    var confirmationSubscriber: AnyCancellable?
    var dismissSubscriber: AnyCancellable?
    var messageSubscriber: AnyCancellable?
    var spinnerSubscriber: AnyCancellable?
    var titleSubscriber: AnyCancellable?

    open func subscribe(to basePresenter: DNSBaseStagePresentationLogic) {
        stageStartSubscriber = basePresenter.stageStartPublisher
            .sink { viewModel in self.startStage(viewModel) }
        stageEndSubscriber = basePresenter.stageEndPublisher
            .sink { viewModel in self.endStage(viewModel) }

        confirmationSubscriber = basePresenter.confirmationPublisher
            .sink { viewModel in self.displayConfirmation(viewModel) }
        dismissSubscriber = basePresenter.dismissPublisher
            .sink { viewModel in self.displayDismiss(viewModel) }
        messageSubscriber = basePresenter.messagePublisher
            .sink { viewModel in self.displayMessage(viewModel) }
        spinnerSubscriber = basePresenter.spinnerPublisher
            .sink { viewModel in self.displaySpinner(viewModel) }
        titleSubscriber = basePresenter.titlePublisher
            .sink { viewModel in self.displayTitle(viewModel) }
    }

    // MARK: - Private Properties -
    var stageBackTitle: String = ""
    var spinnerCount: Int = 0

    // MARK: - Public Properties -
    public var displayType: DNSBaseStage.DisplayType?
    public var displayOptions: DNSBaseStageDisplayOptions = []

    public var stageTitle: String = "" {
        willSet(newStageTitle) {
            if stageBackTitle == stageTitle || stageBackTitle == "" {
                stageBackTitle = newStageTitle
            }
        }
        didSet {
            self.updateStageTitle()
        }
    }

    @IBOutlet public weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet public weak var blurredView: UIView?
    @IBOutlet public weak var blurredViewBottomConstraint: NSLayoutConstraint?
    @IBOutlet public weak var blurredViewTopConstraint: NSLayoutConstraint?
    @IBOutlet public weak var disabledView: UIView?
    @IBOutlet public weak var disabledViewTopConstraint: NSLayoutConstraint?
    @IBOutlet public weak var tapToDismissView: UIView?
    @IBOutlet public weak var titleLabel: UILabel?

    // MARK: - Workers -
    public var analyticsWorker: PTCLAnalytics_Protocol?

    // MARK: - Object settings -

    open func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    func updateStageTitle() {
        guard self.stageTitle != "" else {  return }

        DNSUIThread.run {
            self.title                  = self.stageTitle
            self.navigationItem.title   = self.stageTitle
            self.tabBarItem.title       = self.stageTitle
            self.titleLabel?.text       = self.stageTitle
        }
    }

    func updateStageBackTitle() {
        guard self.stageBackTitle != "" else {  return }

        DNSUIThread.run {
            self.navigationItem.title   = self.stageBackTitle
        }
    }

    // MARK: - Object lifecycle -

    required public override init(nibName nibNameOrNil: String? = nil,
                                  bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - View lifecycle -

    override open func viewDidLoad() {
        super.viewDidLoad()
        if let identifier = "\(type(of: self))".split(separator: ".").last {
            self.view.accessibilityIdentifier = String(identifier)
        }

        if self.tapToDismissView != nil {
            let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapToDismiss))
            tapRecognizer.cancelsTouchesInView = false
            self.tapToDismissView?.addGestureRecognizer(tapRecognizer)
        }

        self.updateStageTitle()
        self.stageDidLoad()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarManageBehaviour = .bySubviews
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.append(DNSBaseStageFormView.self)

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.updateStageTitle()
        self.setNeedsStatusBarAppearanceUpdate()
        self.stageWillAppear()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        try? self.analyticsWorker?.doScreen(screenTitle: String(describing: self.baseConfigurator!))

        self.stageDidAppear()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.stageWillDisappear()
        self.updateStageBackTitle()
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if (self.navigationController != nil) &&
            self.navigationController?.viewControllers.contains(self) ?? false {
            self.stageDidHide()
            return
        }
        if (self.tabBarController != nil) &&
            self.tabBarController?.viewControllers?.contains(self) ?? false {
            self.stageDidHide()
            return
        }

        self.stageDidDisappear()
        self.stageDidClose()
    }

    // MARK: - Gesture Recognizer methods -
    @objc
    open func tapToDismiss(recognizer: UITapGestureRecognizer) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")
        view.endEditing(true)
    }

    // MARK: - Action methods -

    @IBAction func closeNavBarButtonAction(sender: UIBarButtonItem) {
        try? self.analyticsWorker?.doAutoTrack(class: String(describing: self), method: "\(#function)")

        closeNavBarButtonPublisher.send(DNSBaseStageModels.Base.Request())
    }
}
extension DNSBaseStageViewController {
    // returns true only if the viewcontroller is presented.
    var isModal: Bool {
        var retval = false
        DNSUIThread.run {
            if let index = self.navigationController?.viewControllers.firstIndex(of: self), index > 0 {
                retval = false
            } else if self.presentingViewController != nil {
                if let parent = self.parent,
                   !(parent is UINavigationController || parent is UITabBarController) {
                    retval = false
                } else {
                    retval = true
                }
            } else if let navController = self.navigationController,
                      navController.presentingViewController?.presentedViewController == navController {
                retval = true
            } else if self.tabBarController?.presentingViewController is UITabBarController {
                retval = true
            }
        }
        return retval
    }
    var isOnTop: Bool {
        return topController == self
    }
    var topController: UIViewController? {
        var topController: UIViewController?
        DNSUIThread.run {
            topController = UIApplication.shared.windows
                .filter {$0.isKeyWindow}
                .first?.rootViewController
            guard topController != nil else { return }

            var presentedViewController = topController
            while presentedViewController != nil {
                topController = presentedViewController
                presentedViewController = topController?.presentedViewController
                if presentedViewController == nil {
                    let navBarController = topController as? UINavigationController
                    let tabBarController = topController as? UITabBarController
                    if navBarController != nil {
                        presentedViewController = navBarController!.children.last
                    } else if tabBarController != nil {
                        if tabBarController!.selectedIndex < tabBarController!.children.count {
                            presentedViewController = tabBarController!.children[tabBarController!.selectedIndex]
                        }
                    }
                }
            }
        }
        return topController
    }
}
