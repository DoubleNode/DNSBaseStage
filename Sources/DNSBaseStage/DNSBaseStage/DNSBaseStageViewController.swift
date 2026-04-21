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
import DNSCrashWorkers
import DNSProtocols
import GTBlurView
import IQKeyboardManagerSwift
import JKDrawer
import UIKit

public protocol DNSBaseStageDisplayLogic: AnyObject {
    typealias BaseStage = DNSBaseStage
    
   // MARK: - Outgoing Pipelines
    var stageDidAppearPublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }
    var stageDidClosePublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }
    var stageDidDisappearPublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }
    var stageDidHidePublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }
    var stageDidLoadPublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }
    var stageWillAppearPublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }
    var stageWillDisappearPublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }
    var stageWillHidePublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }

    var closeActionPublisher: PassthroughSubject<BaseStage.Models.Base.Request, Never> { get }
    var confirmationPublisher: PassthroughSubject<BaseStage.Models.Confirmation.Request, Never> { get }
    var errorDonePublisher: PassthroughSubject<BaseStage.Models.Message.Request, Never> { get }
    var errorOccurredPublisher: PassthroughSubject<BaseStage.Models.ErrorMessage.Request, Never> { get }
    var messageDonePublisher: PassthroughSubject<BaseStage.Models.Message.Request, Never> { get }
    var webStartNavigationPublisher: PassthroughSubject<BaseStage.Models.Webpage.Request, Never> { get }
    var webFinishNavigationPublisher: PassthroughSubject<BaseStage.Models.Webpage.Request, Never> { get }
    var webErrorNavigationPublisher: PassthroughSubject<BaseStage.Models.WebpageError.Request, Never> { get }
    var webLoadProgressPublisher: PassthroughSubject<BaseStage.Models.WebpageProgress.Request, Never> { get }
}

extension DNSBaseStageViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

open class DNSBaseStageViewController: DNSUIViewController, DNSBaseStageDisplayLogic {
    public typealias BaseStage = DNSBaseStage
    
    // MARK: - Public Associated Type Properties -
    open lazy var analyticsClassTitle: String = {
        String(describing: self.classForCoder)
    }()
    open lazy var analyticsStageTitle: String = {
        self.baseConfigurator?.analyticsStageTitle ?? String(describing: self.classForCoder)
    }()
    public var baseConfigurator: BaseStage.Configurator? {
        didSet {
            self.baseConfigurator?.configureStage()
        }
    }
    public lazy var intBlurView: GTBlurView = {
        GTBlurView.addBlur(to: self.blurredView!)
    }();

    // MARK: - Outgoing Pipelines -
    public let stageDidAppearPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    public let stageDidClosePublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    public let stageDidDisappearPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    public let stageDidHidePublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    public let stageDidLoadPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    public let stageWillAppearPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    public let stageWillDisappearPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    public let stageWillHidePublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()

    public let closeActionPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    public let confirmationPublisher = PassthroughSubject<BaseStage.Models.Confirmation.Request, Never>()
    public let errorDonePublisher = PassthroughSubject<BaseStage.Models.Message.Request, Never>()
    public let errorOccurredPublisher = PassthroughSubject<BaseStage.Models.ErrorMessage.Request, Never>()
    public let messageDonePublisher = PassthroughSubject<BaseStage.Models.Message.Request, Never>()
    public let webStartNavigationPublisher = PassthroughSubject<BaseStage.Models.Webpage.Request, Never>()
    public let webFinishNavigationPublisher = PassthroughSubject<BaseStage.Models.Webpage.Request, Never>()
    public let webErrorNavigationPublisher = PassthroughSubject<BaseStage.Models.WebpageError.Request, Never>()
    public var webLoadProgressPublisher = PassthroughSubject<BaseStage.Models.WebpageProgress.Request, Never>()

    // MARK: - Incoming Pipelines -
    var stageStartSubscriber: AnyCancellable?
    var stageEndSubscriber: AnyCancellable?

    var confirmationSubscriber: AnyCancellable?
    var disabledSubscriber: AnyCancellable?
    var dismissSubscriber: AnyCancellable?
    var messageSubscriber: AnyCancellable?
    var resetSubscriber: AnyCancellable?
    var spinnerSubscriber: AnyCancellable?
    var titleSubscriber: AnyCancellable?

    open var subscribers: [AnyCancellable] = []
    open func subscribe(to basePresenter: BaseStage.Logic.Presentation) {
        subscribers.removeAll()
        stageStartSubscriber = basePresenter.stageStartPublisher
            .sink { [weak self] viewModel in self?.startStage(viewModel) }
        stageEndSubscriber = basePresenter.stageEndPublisher
            .sink { [weak self] viewModel in self?.endStage(viewModel) }

        confirmationSubscriber = basePresenter.confirmationPublisher
            .sink { [weak self] viewModel in self?.displayConfirmation(viewModel) }
        disabledSubscriber = basePresenter.disabledPublisher
            .sink { [weak self] viewModel in self?.displayDisabled(viewModel) }
        dismissSubscriber = basePresenter.dismissPublisher
            .sink { [weak self] viewModel in self?.displayDismiss(viewModel) }
        messageSubscriber = basePresenter.messagePublisher
            .sink { [weak self] viewModel in self?.displayMessage(viewModel) }
        resetSubscriber = basePresenter.resetPublisher
            .sink { [weak self] viewModel in self?.displayReset(viewModel) }
        spinnerSubscriber = basePresenter.spinnerPublisher
            .sink { [weak self] viewModel in self?.displaySpinner(viewModel) }
        titleSubscriber = basePresenter.titlePublisher
            .sink { [weak self] viewModel in self?.displayTitle(viewModel) }
    }

    // MARK: - Private Properties -
    var stageBackTitle: String = ""
    var spinnerCount: Int = 0

    // MARK: - Public Properties -
    public var displayMode: BaseStage.Display.Mode?
    public var displayOptions: BaseStage.Display.Options = []

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
    @IBOutlet public weak var closeButton: UIButton?
    @IBOutlet public weak var disabledView: UIView?
    @IBOutlet public weak var disabledViewTopConstraint: NSLayoutConstraint?
    @IBOutlet public weak var tapToDismissView: UIView?
    @IBOutlet public weak var titleLabel: UILabel?

    // MARK: - Workers -
    public var wkrAnalytics: WKRPTCLAnalytics = WKRCrashAnalytics()

    // MARK: - Object settings -
    open func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    func updateStageTitle() {
        guard self.stageTitle != "" else {  return }
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            self.title = self.stageTitle
            self.titleLabel?.text = self.stageTitle
            self.navigationItem.title = self.stageTitle
            self.tabBarItem.title = self.stageTitle
        }
    }
    func updateStageBackTitle() {
        guard self.stageBackTitle != "" else {  return }
        DNSUIThread.run { [weak self] in
            guard let self else { return }
            self.navigationItem.title = self.stageBackTitle
        }
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
        self.implementDisplayOptionsPostStart()
        self.closeButton?.isEnabled = true
        stageWillAppearPublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageWillDisappear() {
        stageWillDisappearPublisher.send(BaseStage.Models.Base.Request())
    }
    open func stageWillHide() {
        stageWillHidePublisher.send(BaseStage.Models.Base.Request())
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
        self.updateSpinnerDisplay(display: false)
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

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(viewOrientationDidChange),
                         name: UIDevice.orientationDidChangeNotification,
                         object: nil)

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.updateStageTitle()
        self.setNeedsStatusBarAppearanceUpdate()
        self.stageWillAppear()
    }
    @objc
    open func viewOrientationDidChange(notification: Notification) {
    }
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.wkrAnalytics.doScreen(screenTitle: self.analyticsStageTitle)
        self.stageDidAppear()
    }
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default
            .removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
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
        if self.isModal && !self.isBeingDismissed {
            self.stageDidHide()
            return
        }
        self.stageDidDisappear()
        self.stageDidClose()
    }

    // MARK: - Display Logic (Open for Override) -
    //
    // Methods in this section are declared open to permit cross-module
    // subclass overrides. Adding a method here is an API promise — consumers
    // may rely on override semantics. Prefer keeping display logic in
    // +DisplayLogic.swift (public, non-overridable) unless a ticket documents
    // concrete consumer need for override.

    /// Resets the stage's close button to enabled state on the main thread.
    open func displayReset(_ viewModel: BaseStage.Models.Base.ViewModel) {
        self.utilityAutoTrack("\(#function)")
        DNSUIThread.run {
            self.closeButton?.isEnabled = true
        }
    }

    /// Applies the given title view-model to the stage's navigation bar and tab bar.
    ///
    /// Updates `self.title`, `self.stageTitle`, and the tab-bar item's image and title
    /// state based on the values carried in `viewModel`. All mutations are dispatched to
    /// the main thread via `DNSUIThread.run`, so the method is safe to call from any
    /// thread. When `viewModel.tabBarHide` is true, the method additionally clears
    /// tab-bar image and title entries across the tab-bar controller's view controllers
    /// whose title matches the incoming title, effectively hiding this stage from
    /// the tab bar.
    ///
    /// - Parameter viewModel: A view-model carrying the new `title` string, optional
    ///   `tabBarUnselectedImage` and `tabBarSelectedImage` assets, and a `tabBarHide`
    ///   flag that, when true, removes this stage's presence from the tab bar.
    ///
    /// - Important: Subclasses MAY override this method to customize title display.
    ///   Overrides SHOULD call `super.displayTitle(viewModel)` unless they are
    ///   intentionally replacing the default behavior entirely. The method is guaranteed
    ///   to execute its UIKit mutations on the main thread (via `DNSUIThread.run`), so
    ///   override implementations can interact with UIKit directly without additional
    ///   dispatch. This contract is enforced by the `open` access modifier and the
    ///   declaration's location in the class body rather than an extension — moving it
    ///   back to an extension would silently break all consumer overrides through static
    ///   dispatch.
    ///
    /// - Note: This method is invoked internally via a `.sink` subscription to
    ///   `basePresenter.titlePublisher` (see `stageDidLoad`). Consumers should emit
    ///   on the title publisher rather than calling `displayTitle(_:)` directly.
    ///
    /// - SeeAlso: XDNS-0009 for history on the open-for-override change.
    open func displayTitle(_ viewModel: BaseStage.Models.Title.ViewModel) {
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
            self.title = viewModel.title
            self.stageTitle = viewModel.title

            if viewModel.tabBarHide {
                self.navigationController?.tabBarItem.image = nil
                self.navigationController?.tabBarItem.selectedImage = nil
                self.navigationController?.title = ""

                self.tabBarItem.image = nil
                self.tabBarItem.selectedImage = nil
                self.tabBarItem.title = ""

                var newViewControllers: [UIViewController] = []
                self.tabBarController?.viewControllers?.forEach { viewController in
                    if viewController.title == viewModel.title {
                        viewController.title = ""
                    }
                    newViewControllers.append(viewController)
                }
                self.tabBarController?.setViewControllers(newViewControllers,
                                                          animated: true)
            }
        }
    }

    // MARK: - Gesture Recognizer methods -
    @objc
    open func tapToDismiss(recognizer: UITapGestureRecognizer) {
        self.utilityAutoTrack("\(#function)")
        view.endEditing(true)
    }

    // MARK: - Action methods -
    @IBAction func closeButtonAction(sender: UIButton) {
        self.utilityAutoTrack("\(#function)")
        if sender == self.closeButton {
            self.closeButton?.isEnabled = false
        }
        closeActionPublisher.send(BaseStage.Models.Base.Request())
    }

    // MARK: - Utility methods -
    open func utilityAutoTrack(_ method: String) {
        self.wkrAnalytics.doAutoTrack(class: self.analyticsClassTitle, method: method)
    }
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
extension DNSBaseStageViewController {
    // returns true only if the viewcontroller is presented.
    var isModal: Bool {
        var retval = false
        DNSUIThread.run { [weak self] in
            guard let self else { return }
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
        return UIViewController.topController == self
    }
}
