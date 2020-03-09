//
//  DNSBaseStageViewController.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import Combine
import DNSCore
import DNSCoreThreading
import DNSProtocols
import IQKeyboardManagerSwift
import UIKit

public protocol DNSBaseStageDisplayLogic: class {
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
    var webStartNavigationPublisher: PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never> { get }
    var webFinishNavigationPublisher: PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never> { get }
    var webErrorNavigationPublisher: PassthroughSubject<DNSBaseStageModels.WebpageError.Request, Never> { get }
}

open class DNSBaseStageViewController: UIViewController, DNSBaseStageDisplayLogic {
    // MARK: - Public Associated Type Properties -
    public var baseConfigurator: DNSBaseStageConfigurator? {
        didSet {
            self.baseConfigurator?.configureStage()
        }
    }

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
    public let webStartNavigationPublisher = PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never>()
    public let webFinishNavigationPublisher = PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never>()
    public let webErrorNavigationPublisher = PassthroughSubject<DNSBaseStageModels.WebpageError.Request, Never>()

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

        self.updateStageTitle()
        self.setNeedsStatusBarAppearanceUpdate()
        self.stageWillAppear()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        do { try self.analyticsWorker?.doScreen(screenTitle: String(describing: type(of: self))) } catch { }
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
        view.endEditing(true)
    }

    // MARK: - Action methods -

    @IBAction func closeNavBarButtonAction(sender: UIBarButtonItem) {
        try? self.analyticsWorker?.doTrack(event: "\(#function)")

        closeNavBarButtonPublisher.send(DNSBaseStageModels.Base.Request())
    }
}
