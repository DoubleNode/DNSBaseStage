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
    public func willOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavDrawerController::willOpenDrawer()")
    }
    public func didOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavDrawerController::didOpenDrawer()")
    }
    public func willCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavDrawerController::willCloseDrawer()")
    }
    public func didCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUINavDrawerController::didCloseDrawer()")
    }
    public func didChangeSizeOfDrawer(_ drawer: DrawerPresentable,
                                      to size: CGFloat) {
        dnsLog.debug("DNSUINavDrawerController::didChangeSizeOfDrawer(to: \(size))")
    }
}
