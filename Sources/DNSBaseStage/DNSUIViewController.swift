//
//  DNSUIViewController.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import DNSError
import JKDrawer
import UIKit

open class DNSUIViewController: UIViewController, DrawerPresentable, DrawerPresenting {
    // MARK: - DrawerPresentable protocol
    public var configuration = DrawerConfiguration(offset: DNSDevice.screenHeightUnits,
                                                   isDraggable: true,
                                                   isClosable: true)

    // MARK: - DrawerPresenting protocols
    open func willOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUIViewController::willOpenDrawer()")
    }
    open func didOpenDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUIViewController::didOpenDrawer()")
    }
    open func willCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUIViewController::willCloseDrawer()")
    }
    open func didCloseDrawer(_ drawer: DrawerPresentable) {
        dnsLog.debug("DNSUIViewController::didCloseDrawer()")
    }
    open func didChangeSizeOfDrawer(_ drawer: DrawerPresentable,
                                    to size: CGFloat) {
        dnsLog.debug("DNSUIViewController::didChangeSizeOfDrawer(to: \(size))")
    }
}
extension DNSUIViewController: DNSAppConstantsRootProtocol, UITextFieldDelegate {
    @objc
    open func checkBoxPressed(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textField.tag != -1
    }
}
