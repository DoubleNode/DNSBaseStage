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
                                    tags: [String],
                                    title: String,
                                    subTitle: String,
                                    message: String,
                                    disclaimer: String,
                                    image: UIImage?,
                                    imageUrl: URL?,
                                    actions: [[String: () -> Void]]?) {
        let alertVC = CommonAlertVC.init(nibName: nibName,
                                         bundle: Bundle.dnsLookupBundle(for: CommonAlertVC.self))
        alertVC.tags = tags
        alertVC.title = title
        alertVC.message = message
        alertVC.disclaimer = disclaimer
        alertVC.arrayAction = actions
        alertVC.subTitle = subTitle
        alertVC.imageItem = image
        alertVC.imageUrl = imageUrl
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
