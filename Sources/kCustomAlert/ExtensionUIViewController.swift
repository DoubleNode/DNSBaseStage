//
//  ExtensionUIViewController.swift
//
//
//  Created by Krishna on 21/05/19.
//  Copyright © 2019 Krishna All rights reserved.
//

import DNSBaseTheme
import DNSCore
import DNSCoreThreading
import UIKit

extension UIViewController {
    public func showCustomAlertWith(nibName: String = "CommonAlertVC",
                                    nibBundle: Bundle? = nil,
                                    okButtonAction: (DNSStringBlock)? = { _ in },
                                    tags: [String],
                                    title: String,
                                    subtitle: String,
                                    message: String,
                                    disclaimer: String,
                                    image: UIImage?,
                                    imageUrl: URL?,
                                    actions: [[String: DNSStringBlock]]?,
                                    actionsStyles: [[String: DNSThemeButtonStyle]]?) {
        let nibBundle = nibBundle ?? Bundle.dnsLookupBundle(for: CommonAlertVC.self)
        let alertVC = CommonAlertVC.init(nibName: nibName,
                                         bundle: nibBundle)
        alertVC.tags = tags
        alertVC.title = title
        alertVC.message = message
        alertVC.disclaimer = disclaimer
        alertVC.arrayAction = actions
        alertVC.arrayActionStyles = actionsStyles
        alertVC.subtitle = subtitle
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
