//
//  DNSUITabBarController.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import DNSError
import JKDrawer
import UIKit

public typealias DNSUITabBarController = UITabBarController

extension DNSUITabBarController: DNSAppConstantsRootProtocol, UITextFieldDelegate, DrawerPresenting {
    @objc
    open func checkBoxPressed(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @objc
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textField.tag != -1
    }

    public func cleanupBuggyDisplay(for numberOfTabs: Int) {
        if tabBar.subviews.count > (numberOfTabs + 1) {
            for index in (numberOfTabs + 1) ..< tabBar.subviews.count {
                let view = tabBar.subviews[index]
                view.removeFromSuperview()
            }
        }
    }

    // MARK: - DrawerPresenting protocols
    open func willOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUITabBarController::willOpenDrawer()")
    }
    open func didOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUITabBarController::didOpenDrawer()")
    }
    open func willCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUITabBarController::willCloseDrawer()")
    }
    open func didCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUITabBarController::didCloseDrawer()")
    }
    open func didChangeSizeOfDrawer(_ drawer: DrawerPresentable,
                                      to size: CGFloat) {
        dnsLog.debug("DNSUITabBarController::didChangeSizeOfDrawer(to: \(size))")
    }
}
