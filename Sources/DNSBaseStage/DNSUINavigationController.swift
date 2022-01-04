//
//  DNSUINavigationController.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import DNSError
import JKDrawer
import UIKit

public typealias DNSUINavigationController = DrawerNavigationController

extension DNSUINavigationController: DNSAppConstantsRootProtocol, DrawerPresenting, UITextFieldDelegate {
    @objc
    open func checkBoxPressed(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textField.tag != -1
    }

    // MARK: - DrawerPresenting protocols
    open func willOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavigationController::willOpenDrawer()")
    }
    open func didOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavigationController::didOpenDrawer()")
    }
    open func willCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavigationController::willCloseDrawer()")
    }
    open func didCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavigationController::didCloseDrawer()")
    }
    open func didChangeSizeOfDrawer(_ drawer: DrawerPresentable,
                                    to size: CGFloat) {
        dnsLog.debug("DNSUINavigationController::didChangeSizeOfDrawer(to: \(size))")
    }
}
