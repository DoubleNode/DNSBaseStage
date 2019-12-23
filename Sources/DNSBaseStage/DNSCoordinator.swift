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

public typealias DNSCoordinatorChildBlock = (DNSCoordinator?) -> Void

open class DNSCoordinator {
    public enum RunState {
        case notStarted
        case started
        case terminated
    }

    public var delegate: Any?   // swiftlint:disable:this weak_delegate

    public var children: [DNSCoordinator] = []
    public var runState: RunState = .notStarted

    // MARK: - Object lifecycle

    public init() {
        UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
    }

    // MARK: - Coordinator lifecycle

    open func start() {
        switch self.runState {
        case .started, .terminated:
            self.reset()

        //case .notStarted:
        default:
            self.runState = .started
        }
    }
    open func start(with openURLContexts: Set<UIOpenURLContext> = nil) {
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
    }

    // MARK: - Intent processing

    open func run(actions: [String: DNSBlock],
                  for intent: String,
                  onBlank: DNSBlock = { },
                  orNoMatch: DNSBlock = { }) {
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
