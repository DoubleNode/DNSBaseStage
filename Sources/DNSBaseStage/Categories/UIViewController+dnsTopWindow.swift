//
//  UIViewController+dnsTopWindow.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2025 - 2016 DoubleNode.com. All rights reserved.
//

#if !os(macOS)
import DNSCoreThreading
import JKDrawer
import UIKit

public extension UIViewController {
    static var topController: UIViewController? {
        var topController: UIViewController?
        DNSUIThread.run {
            topController = (UIApplication.dnsCurrentScene() as? UIWindowScene)?.windows
                .filter {$0.isKeyWindow}
                .first?.rootViewController
            guard topController != nil else { return }

            var presentedViewController = topController
            while presentedViewController != nil {
                topController = presentedViewController
                presentedViewController = topController?.presentedViewController
                if presentedViewController == nil {
                    if let drawerController = topController as? JKDrawer.DrawerNavigationController {
                        presentedViewController = drawerController.children.last
                    }
                    if let navBarController = topController as? UINavigationController {
                        presentedViewController = navBarController.children.last
                    }
                    if let tabBarController = topController as? UITabBarController {
                        if tabBarController.selectedIndex < tabBarController.children.count {
                            var index = tabBarController.selectedIndex
                            presentedViewController = tabBarController.children[index]
                            while let drawerController = presentedViewController as? JKDrawer.DrawerNavigationController {
                                presentedViewController = drawerController.children.last
                                if presentedViewController as? JKDrawer.DrawerNavigationController == nil {
                                    break
                                }
                                index += 1
                                if index >= tabBarController.children.count {
                                    index = tabBarController.selectedIndex
                                    presentedViewController = tabBarController.children[index]
                                    break
                                }
                                presentedViewController = tabBarController.children[index]
                            }
                        }
                    }
                }
            }
        }
        return topController
    }
}
#endif
