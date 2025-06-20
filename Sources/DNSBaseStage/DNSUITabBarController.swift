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

extension DNSUITabBarController: @retroactive DNSAppConstantsRootProtocol, @retroactive DrawerPresenting, @retroactive UITextFieldDelegate {
    @objc
    open func checkBoxPressed(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @objc
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textField.tag != -1
    }

    public func cleanupBuggyDisplay(for numberOfTabs: Int) {
        let subviews = tabBar.subviews
        let numSubview = subviews.count
        if numSubview > (numberOfTabs + 1) {
            for index in (numberOfTabs + 1) ..< numSubview {
                let view = subviews[index]
                view.removeFromSuperview()
            }
        }
    }

    // MARK: - DrawerPresenting protocols
    public func willOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUITabBarController::willOpenDrawer()")
    }
    public func didOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUITabBarController::didOpenDrawer()")
    }
    public func willCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUITabBarController::willCloseDrawer()")
    }
    public func didCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUITabBarController::didCloseDrawer()")
    }
    public func didChangeSizeOfDrawer(_ drawer: DrawerPresentable,
                                      to size: CGFloat) {
        dnsLog.debug("DNSUITabBarController::didChangeSizeOfDrawer(to: \(size))")
    }
}
