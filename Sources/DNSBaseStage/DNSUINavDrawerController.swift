//
//  DNSUINavDrawerController.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import DNSError
import JKDrawer
import UIKit

public typealias DNSUINavDrawerController = DrawerNavigationController

extension DNSUINavDrawerController: DrawerPresenting {
    // MARK: - DrawerPresenting protocols
    open func willOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavDrawerController::willOpenDrawer()")
    }
    open func didOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavDrawerController::didOpenDrawer()")
    }
    open func willCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavDrawerController::willCloseDrawer()")
    }
    open func didCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavDrawerController::didCloseDrawer()")
    }
    open func didChangeSizeOfDrawer(_ drawer: DrawerPresentable,
                                    to size: CGFloat) {
        dnsLog.debug("DNSUINavDrawerController::didChangeSizeOfDrawer(to: \(size))")
    }
}
