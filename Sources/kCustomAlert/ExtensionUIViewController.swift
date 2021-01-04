//
//  ExtensionUIViewController.swift
//
//
//  Created by Krishna on 21/05/19.
//  Copyright © 2019 Krishna All rights reserved.
//

import DNSCore
import UIKit

extension UIViewController {
    public func showCustomAlertWith(nibName: String = "CommonAlertVC",
                                    okButtonAction: (() -> Void)? = {},
                                    title: String,
                                    message: String,
                                    descMsg: String,
                                    itemimage: UIImage?,
                                    actions: [[String: () -> Void]]?) {
        let alertVC = CommonAlertVC.init(nibName: nibName,
                                         bundle: Bundle.dnsLookupBundle(for: CommonAlertVC.self))
        alertVC.title = title
        alertVC.message = message
        alertVC.arrayAction = actions
        alertVC.descriptionMessage = descMsg
        alertVC.imageItem = itemimage
        alertVC.okButtonAct = okButtonAction
        //Present
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overCurrentContext

        var presentingViewController: UIViewController = self
        if presentingViewController.view.superview == nil ||
            presentingViewController.isBeingDismissed {
            if presentingViewController.parent != nil {
                presentingViewController = presentingViewController.parent!
            }
        }
        presentingViewController.present(alertVC, animated: true)
    }
}
