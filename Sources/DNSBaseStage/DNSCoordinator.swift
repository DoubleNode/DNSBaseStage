//
//  DNSCoordinator.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import DNSCore
import DNSCoreThreading
import FTLinearActivityIndicator
import UIKit

public typealias DNSCoordinatorBlock = () -> Void
public typealias DNSCoordinatorChildBlock = (DNSCoordinator?) -> Void

open class DNSCoordinator: NSObject {
    public enum RunState {
        case notStarted
        case started
        case terminated
    }

    public var parent: DNSCoordinator? {
        willSet {
            parent?.children.removeAll(where: { $0 == self })
        }
        didSet {
            parent?.children.append(self)
        }
    }
    var completionBlock: DNSBlock?

    public var children: [DNSCoordinator] = []
    public var runState: RunState = .notStarted
    public var latestConfigurator: DNSBaseStageConfigurator?

    // MARK: - Object lifecycle

    public init(with parent: DNSCoordinator? = nil) {
        self.parent = parent
        
        _ = DNSUIThread.run {
            UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
        }
    }

    // MARK: - Coordinator lifecycle

    open func start(then completionBlock: DNSBlock?) {
        self.completionBlock = completionBlock
        
        switch self.runState {
        case .started, .terminated:
            self.reset()

        //case .notStarted:
        default:
            self.runState = .started
        }
    }
    open func start(with openURLContexts: Set<UIOpenURLContext>,
                    then completionBlock: DNSBlock?) {
        self.completionBlock = completionBlock
        
        switch self.runState {
        case .started, .terminated:
            self.reset()

        //case .notStarted:
        default:
            self.runState = .started
        }
    }
    open func start(with userActivity: NSUserActivity,
                    then completionBlock: DNSBlock?) {
        self.completionBlock = completionBlock
        
        switch self.runState {
        case .started, .terminated:
            self.reset()

        //case .notStarted:
        default:
            self.runState = .started
        }
    }
    open func reset() {
        self.runState = .notStarted

        for child: DNSCoordinator in self.children {
            child.reset()
        }

        self.children = []
    }
    open func stop() {
        self.runState = .notStarted
        
        completionBlock?()
    }

    // MARK: - Intent processing

    open func run(actions: [String: DNSCoordinatorBlock],
                  for intent: String,
                  onBlank: DNSCoordinatorBlock = { },
                  orNoMatch: DNSCoordinatorBlock = { }) {
        if intent.isEmpty {
            onBlank()
            return
        }

        var matchFound: Bool = false

        actions.forEach { (key, value) in
            if key == intent {
                matchFound = true
                value()
            }
        }

        if !matchFound {
            orNoMatch()
        }
    }

    public func startStage(_ configurator: DNSBaseStageConfigurator,
                           and displayType: DNSBaseStageDisplayType,
                           with displayOptions: DNSBaseStageDisplayOptions? = nil,
                           and initializationObject: DNSBaseStageBaseInitialization,
                           thenRunActions actions: [String: DNSCoordinatorBlock]) {
        configurator.parentConfigurator = self.latestConfigurator
        _ = configurator.runStage(with: self,
                                  and: displayType,
                                  with: displayOptions,
                                  and: initializationObject) { (_, intent, _, _) in
                                    self.latestConfigurator = configurator
                                    self.run(actions: actions, for: intent)
        }
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

            DNSCore.appDelegate.rootViewController().present(alertController,
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
