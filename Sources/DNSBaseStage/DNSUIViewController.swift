//
//  DNSUIViewController.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import JKDrawer
import UIKit

open class DNSUIViewController: UIViewController, DrawerPresentable, DrawerPresenting {
    // MARK: - DrawerPresentable protocol
    public var configuration = DrawerConfiguration(offset: DNSDevice.screenHeightUnits,
                                                   isDraggable: true,
                                                   isClosable: true)

    // MARK: - DrawerPresenting protocol
    open func willOpenDrawer(_ drawer: DrawerPresentable) {
    }
    open func didOpenDrawer(_ drawer: DrawerPresentable) {
    }
    open func willCloseDrawer(_ drawer: DrawerPresentable) {
    }
    open func didCloseDrawer(_ drawer: DrawerPresentable) {
    }
    open func didChangeSizeOfDrawer(_ drawer: DrawerPresentable,
                                    to size: CGFloat) {
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
