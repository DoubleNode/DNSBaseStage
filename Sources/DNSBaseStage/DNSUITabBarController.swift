//
//  DNSUITabBarController.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
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

    // MARK: - DrawerPresenting protocols
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
