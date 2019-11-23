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

    var confirmationPublisher: PassthroughSubject<DNSBaseStageModels.Confirmation.Request, Never> { get }
    var errorOccurredPublisher: PassthroughSubject<DNSBaseStageModels.Error.Request, Never> { get }
    var webStartNavigationPublisher: PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never> { get }
    var webFinishNavigationPublisher: PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never> { get }
    var webErrorNavigationPublisher: PassthroughSubject<DNSBaseStageModels.WebpageError.Request, Never> { get }
}

open class DNSBaseStageViewController: UIViewController, DNSBaseStageDisplayLogic, UITextFieldDelegate, UITextViewDelegate {
    // MARK: - Outgoing Pipelines
    public let stageDidAppearPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageDidClosePublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageDidDisappearPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageDidHidePublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageDidLoadPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageWillAppearPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()
    public let stageWillDisappearPublisher = PassthroughSubject<DNSBaseStageBaseRequest, Never>()

    public let confirmationPublisher = PassthroughSubject<DNSBaseStageModels.Confirmation.Request, Never>()
    public let errorOccurredPublisher = PassthroughSubject<DNSBaseStageModels.Error.Request, Never>()
    public let webStartNavigationPublisher = PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never>()
    public let webFinishNavigationPublisher = PassthroughSubject<DNSBaseStageModels.Webpage.Request, Never>()
    public let webErrorNavigationPublisher = PassthroughSubject<DNSBaseStageModels.WebpageError.Request, Never>()

    // MARK: - Incoming Pipelines
    var stageStartSubscriber: AnyCancellable?
    var stageEndSubscriber: AnyCancellable?

    var confirmationSubscriber: AnyCancellable?
    var dismissSubscriber: AnyCancellable?
    var messageSubscriber: AnyCancellable?
    var spinnerSubscriber: AnyCancellable?
    var titleSubscriber: AnyCancellable?
    
    open func subscribe(to presenter: DNSBaseStagePresentationLogic) {
        stageStartSubscriber = presenter.stageStartPublisher
            .sink { viewModel in self.startStage(viewModel) }
        stageEndSubscriber = presenter.stageEndPublisher
            .sink { viewModel in self.endStage(viewModel) }
        
        confirmationSubscriber = presenter.confirmationPublisher
            .sink { viewModel in self.displayConfirmation(viewModel) }
        dismissSubscriber = presenter.dismissPublisher
            .sink { viewModel in self.displayDismiss(viewModel) }
        messageSubscriber = presenter.messagePublisher
            .sink { viewModel in self.displayMessage(viewModel) }
        spinnerSubscriber = presenter.spinnerPublisher
            .sink { viewModel in self.displaySpinner(viewModel) }
        titleSubscriber = presenter.titlePublisher
            .sink { viewModel in self.displayTitle(viewModel) }
    }
    
    // MARK: - Private Properties
    var stageBackTitle: String = ""
    var spinnerCount:   Int = 0

    // MARK: - Public Properties
    public var configurator: DNSBaseStageConfigurator? {
        didSet {
            self.configure()
        }
    }

    public var displayType:     DNSBaseStageDisplayType?
    public var keyboardBounds:  CGRect = CGRect.zero
    public var visibleMargin:   CGFloat = 0.0

    private var keyboardShowing:    Bool = false
    private var visibleOffset:      CGFloat = 0.0

    public var lastVisibleView: UIView? {
        willSet(newLastVisibleView) {
            if lastVisibleView == nil {
                self.keyboardBounds = CGRect.zero
            }

            if self.keyboardShowing {
                self.animateViewToAvoid(rect: self.keyboardBounds,
                    with: 0.2,
                    and: UIView.AnimationOptions.curveEaseInOut)
            }
        }
    }
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

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var disabledView: UIView?
    @IBOutlet weak var disabledViewTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var tapToDismissView: UIView?
    @IBOutlet weak var titleLabel: UILabel?

    // MARK: - Workers
    public var analyticsWorker: PTCLAnalytics_Protocol?

    // MARK: - Object settings

    public func configure() {
        self.configurator?.configureStage(self)
    }

    open func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    func updateStageTitle() {
        guard self.stageTitle != "" else {  return }

        DNSUIThread.run {
            self.title                  = self.stageTitle
            self.navigationItem.title   = self.stageTitle
            self.titleLabel?.text       = self.stageTitle
        }
    }

    func updateStageBackTitle() {
        guard self.stageBackTitle != "" else {  return }

        DNSUIThread.run {
            self.navigationItem.title   = self.stageBackTitle
        }
    }

    // MARK: - Object lifecycle

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

    // MARK: - View lifecycle

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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        self.visibleMargin = 10.0

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

        self.stageDidDisappear()
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

        self.stageDidClose()
    }

    // MARK: - Notification Observer methods

    @objc
    open func keyboardWillShow(notification: Notification) {
        guard !self.keyboardShowing else { return }
        guard self.lastVisibleView != nil else { return }

        self.keyboardShowing = true

        let keyboardBounds: CGRect? = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        guard keyboardBounds != nil else { return }

        let duration: TimeInterval =
            notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.2
        let curve: UIView.AnimationOptions =
            notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationOptions ??
                UIView.AnimationOptions.curveEaseInOut

        self.animateViewToAvoid(rect: keyboardBounds!,
            with: duration,
            and: curve)
    }

    @objc
    open func keyboardWillHide(notification: Notification) {
        guard self.keyboardShowing else { return }
        guard self.lastVisibleView != nil else { return }

        self.keyboardShowing = false

        let duration: TimeInterval =
            notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.2
        let curve: UIView.AnimationOptions =
            notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationOptions ??
                UIView.AnimationOptions.curveEaseInOut

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [curve, UIView.AnimationOptions.beginFromCurrentState],
                       animations: {
                        self.view.y += self.visibleOffset
                        self.visibleOffset = 0
        }, completion: { (_) in
            self.keyboardBounds = CGRect.zero
        })
    }

    func animateViewToAvoid(rect: CGRect, with duration: TimeInterval, and curve: UIView.AnimationOptions) {
        guard self.view.visible else { return }

        let lastVisibleBounds = self.lastVisibleView?.superview?.convert(self.lastVisibleView!.frame,
                                                                         to: self.view)
        guard lastVisibleBounds != nil else { return }

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [curve, UIView.AnimationOptions.beginFromCurrentState],
                       animations: {
            let visibleHeight = self.view.height - rect.height
            let lastVisiblePointY = lastVisibleBounds!.origin.y + lastVisibleBounds!.size.height + 14.0

            if self.visibleOffset != 0 {
                self.view.y += self.visibleOffset
                self.visibleOffset = 0
            }

            if (self.lastVisibleView != nil) && (self.visibleOffset == 0) &&
                (visibleHeight < (lastVisiblePointY + self.visibleMargin)) {
                self.visibleOffset = lastVisiblePointY - visibleHeight + self.visibleMargin
                self.view.y -= self.visibleOffset
            }
        }, completion: { (_) in
            self.keyboardBounds = rect
        })
    }

    // MARK: - UITextFieldDelegate methods

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        self.lastVisibleView = textField
    }
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }

    // MARK: - UITextViewDelegate methods

    open func textViewDidBeginEditing(_ textView: UITextView) {
        self.lastVisibleView = textView
    }

    // MARK: - Gesture Recognizer methods
    @objc
    open func tapToDismiss(recognizer: UITapGestureRecognizer) {
        self.lastVisibleView?.resignFirstResponder()
    }
}
