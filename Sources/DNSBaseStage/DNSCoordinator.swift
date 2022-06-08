//
//  DNSCoordinator.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import AtomicSwift
import DNSCore
import DNSCoreThreading
import DNSDataObjects
import FTLinearActivityIndicator
import UIKit

public typealias DNSCoordinatorBlock = () -> Void
public typealias DNSCoordinatorBoolBlock = (Bool) -> Void
public typealias DNSCoordinatorChildBlock = (DNSCoordinator?) -> Void
public typealias DNSCoordinatorChildBoolBlock = (DNSCoordinator?, Bool) -> Void
public typealias DNSCoordinatorResultsBlock = (DNSBaseStageBaseResults?) -> Void

open class DNSCoordinator: NSObject {
    public enum RunState {
        case notStarted
        case started
        case terminated
    }

    public var defaultRootViewController: DNSBaseStageViewController?
    public var parent: DNSCoordinator? {
        willSet {
            parent?.children.removeAll(where: { $0 == self })
        }
        didSet {
            parent?.children.append(self)
        }
    }

    var completionBlock: DNSCoordinatorBoolBlock?
    var completionResultsBlock: DNSCoordinatorResultsBlock?

    @Atomic public var children: [DNSCoordinator] = []
    @Atomic public var runState: RunState = .notStarted
    @Atomic public var latestConfigurator: DNSBaseStageConfigurator?

    public var isRunning: Bool {
        return self.runState == .started
    }
    public var runningChildren: [DNSCoordinator] {
        return self.children.filter { $0.isRunning }
    }
    open func cancelRunningChildren() {
        self.runningChildren.forEach { $0.cancel() }
    }

    // MARK: - Object lifecycle

    public init(with parent: DNSCoordinator? = nil) {
        self.parent = parent

        DNSUIThread.run {
            UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
        }
    }
    open func commonStart() {
        switch self.runState {
        case .started, .terminated:
            self.reset()
        //case .notStarted:
        default:
            self.runState = .started
        }
    }

    // MARK: - Coordinator lifecycle

    open func start(then completionBlock: DNSCoordinatorBoolBlock?) {
        self.completionBlock = completionBlock
        self.completionResultsBlock = nil
        self.commonStart()
    }
    open func start(with connectionOptions: UIScene.ConnectionOptions,
                    then completionBlock: DNSCoordinatorBoolBlock?) {
        self.start(then: completionBlock)
    }
    open func start(with notification: DAONotification,
                    then completionBlock: DNSCoordinatorBoolBlock?) {
        self.start(then: completionBlock)
    }
    open func start(with openURLContexts: Set<UIOpenURLContext>,
                    then completionBlock: DNSCoordinatorBoolBlock?) {
        self.start(then: completionBlock)
    }
    open func start(with userActivity: NSUserActivity,
                    then completionBlock: DNSCoordinatorBoolBlock?) {
        self.start(then: completionBlock)
    }
    
    open func start(then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        self.completionBlock = nil
        self.completionResultsBlock = completionResultsBlock
        self.commonStart()
    }
    open func start(with connectionOptions: UIScene.ConnectionOptions,
                    then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        self.start(then: completionResultsBlock)
    }
    open func start(with notification: DAONotification,
                    then completionBlock: DNSCoordinatorResultsBlock?) {
        self.start(then: completionBlock)
    }
    open func start(with openURLContexts: Set<UIOpenURLContext>,
                    then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        self.start(then: completionResultsBlock)
    }
    open func start(with userActivity: NSUserActivity,
                    then completionResultsBlock: DNSCoordinatorResultsBlock?) {
        self.start(then: completionResultsBlock)
    }

    open func continueRunning() {
    }
    open func continueRunning(with connectionOptions: UIScene.ConnectionOptions) {
        self.continueRunning()
    }
    open func continueRunning(with notification: DAONotification) {
        self.continueRunning()
    }
    open func continueRunning(with openURLContexts: Set<UIOpenURLContext>) {
        self.continueRunning()
    }
    open func continueRunning(with userActivity: NSUserActivity) {
        self.continueRunning()
    }
    
    open func reset() {
        self.runState = .notStarted

        for child: DNSCoordinator in self.children {
            child.reset()
        }

        self.children = []
    }
    open func stop(with results: DNSBaseStageBaseResults? = nil) {
        guard self.runState != .terminated else { return }

        self.runState = .terminated

        completionBlock?(true)
        completionResultsBlock?(results)
    }
    open func stopAndCancel() {
        guard self.runState != .terminated else { return }

        self.runState = .terminated

        completionBlock?(false)
        completionResultsBlock?(nil)
    }
    open func cancel() {
        guard self.runState != .terminated else { return }

        self.runState = .terminated

        completionBlock?(false)
        completionResultsBlock?(nil)
    }
    open func update(from sender: DNSCoordinator? = nil) {
        guard self.runState != .terminated else { return }
        
        for child in children {
            if child != sender {
                child.update()
            }
        }
    }
    
    // MARK: - Intent processing

    open func run(actions: [String: DNSCoordinatorResultsBlock],
                  for intent: String,
                  with results: DNSBaseStageBaseResults?,
                  onBlank: DNSCoordinatorResultsBlock = { _ in },
                  onClose: DNSCoordinatorResultsBlock = { _ in },
                  orNoMatch: DNSCoordinatorResultsBlock = { _ in }) {
        if intent.isEmpty {
            onBlank(results)
            return
        }
        if intent == DNSBaseStage.BaseIntents.close {
            onClose(results)
            return
        }

        var matchFound: Bool = false
        actions.forEach { (key, value) in
            if key == intent {
                matchFound = true
                value(results)
            }
        }
        if !matchFound {
            orNoMatch(results)
        }
    }

    public func startStage(_ configurator: DNSBaseStageConfigurator,
                           and displayMode: DNSBaseStage.Display.Mode,
                           with displayOptions: DNSBaseStage.Display.Options = [],
                           and initializationObject: DNSBaseStageBaseInitialization,
                           thenRunActions actions: [String: DNSCoordinatorResultsBlock]) {
        var lastCoordinator: DNSCoordinator? = self
        configurator.parentConfigurator = lastCoordinator?.latestConfigurator
        while (lastCoordinator != nil) &&
            (configurator.parentConfigurator == nil) {
                lastCoordinator = lastCoordinator?.parent
                configurator.parentConfigurator = lastCoordinator?.latestConfigurator
        }

        _ = configurator.runStage(with: self,
                                  and: displayMode,
                                  with: displayOptions,
                                  and: initializationObject) { (_, intent, _, results) in
                                    self.latestConfigurator = configurator
                                    self.run(actions: actions,
                                             for: intent,
                                             with: results,
                                             onBlank: actions[DNSBaseStage.C.onBlank] ?? { _ in },
                                             onClose: actions[DNSBaseStage.C.onClose] ?? { _ in },
                                             orNoMatch: actions[DNSBaseStage.C.orNoMatch] ?? { _ in })
                                    self.latestConfigurator = nil
        }
    }

    public func updateStage(_ configurator: DNSBaseStageConfigurator,
                            with initializationObject: DNSBaseStageBaseInitialization) {
        configurator.updateStage(with: initializationObject)
    }

    // MARK: - Utility methods

    public func utilityShowSectionStatusMessage(with title: String,
                                                and message: String,
                                                continueBlock: DNSBlock? = nil,
                                                cancelBlock: @escaping DNSBlock = { }) {
        if title.isEmpty {
            continueBlock?() ?? cancelBlock()
            return
        }

        DNSUIThread.run {
            let alertController = UIAlertController.init(title: title,
                                                         message: message,
                                                         preferredStyle: UIAlertController.Style.alert)
            if continueBlock != nil {
                alertController.addAction(UIAlertAction.init(title: "Continue",
                                                             style: UIAlertAction.Style.default) { (_: UIAlertAction) in
                    continueBlock?()
                })
            }

            alertController.addAction(UIAlertAction.init(title: "Cancel",
                                                         style: UIAlertAction.Style.cancel) { (_: UIAlertAction) in
                cancelBlock()
            })

            DNSCore.appDelegate?.rootViewController().present(alertController,
                                                              animated: true,
                                                              completion: nil)

        }
    }

    public func utilityShouldAllowSectionStatus(for status: DNSAppSystem.Status,
                                                with title: String,
                                                and message: String,
                                                continueBlock: @escaping DNSBlock = { },
                                                cancelBlock: @escaping DNSBlock = { },
                                                buildType: DNSAppConstants.BuildType) {
        switch status {
        case .yellow:
            var displayMessage: String = message
            if displayMessage.isEmpty {
                // swiftlint:disable:next line_length
                displayMessage = "We apologize, but our \(title) is currently experiencing occasional issues.  We are working quickly to find and correct the problem.\n\nYou can continue, or check back later."
            }
            self.utilityShowSectionStatusMessage(with: title,
                                                 and: displayMessage,
                                                 continueBlock: continueBlock,
                                                 cancelBlock: cancelBlock)

        case .red:
            var displayMessage: String = message
            if displayMessage.isEmpty {
                // swiftlint:disable:next line_length
                displayMessage = "We apologize, but our \(title) is temporarily down.  We are working quickly to find and correct the problem.\n\nPlease check back later."
            }

            var actualContinueBlock: DNSBlock? = { }
            if buildType == .dev {
                actualContinueBlock = continueBlock
            }
            self.utilityShowSectionStatusMessage(with: title,
                                                 and: displayMessage,
                                                 continueBlock: actualContinueBlock,
                                                 cancelBlock: cancelBlock)

        //case .green:
        //case .unknown:
        default:
            continueBlock()
        }
    }
}
