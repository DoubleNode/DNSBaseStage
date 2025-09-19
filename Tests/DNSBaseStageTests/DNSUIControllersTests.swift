//
//  DNSUIControllersTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import UIKit
@testable import DNSBaseStage
@testable import DNSCore
@testable import JKDrawer

class DNSUIControllersTests: XCTestCase {

    // MARK: - DNSUINavigationController Tests

    func test_DNSUINavigationController_is_UINavigationController() {
        let navigationController = DNSUINavigationController()

        XCTAssertTrue(navigationController is UINavigationController)
        XCTAssertTrue(navigationController is DNSAppConstantsRootProtocol)
        XCTAssertTrue(navigationController is UITextFieldDelegate)
    }

    func test_navigationController_checkBoxPressed_toggles_selection() {
        let navigationController = DNSUINavigationController()
        let button = UIButton()

        XCTAssertFalse(button.isSelected)

        navigationController.checkBoxPressed(sender: button)
        XCTAssertTrue(button.isSelected)

        navigationController.checkBoxPressed(sender: button)
        XCTAssertFalse(button.isSelected)
    }

    func test_navigationController_textFieldShouldBeginEditing_with_positive_tag() {
        let navigationController = DNSUINavigationController()
        let textField = UITextField()
        textField.tag = 1

        let shouldBeginEditing = navigationController.textFieldShouldBeginEditing(textField)

        XCTAssertTrue(shouldBeginEditing)
    }

    func test_navigationController_textFieldShouldBeginEditing_with_zero_tag() {
        let navigationController = DNSUINavigationController()
        let textField = UITextField()
        textField.tag = 0

        let shouldBeginEditing = navigationController.textFieldShouldBeginEditing(textField)

        XCTAssertTrue(shouldBeginEditing)
    }

    func test_navigationController_textFieldShouldBeginEditing_with_negative_tag() {
        let navigationController = DNSUINavigationController()
        let textField = UITextField()
        textField.tag = -1

        let shouldBeginEditing = navigationController.textFieldShouldBeginEditing(textField)

        XCTAssertFalse(shouldBeginEditing)
    }

    // MARK: - DNSUITabBarController Tests

    func test_DNSUITabBarController_is_UITabBarController() {
        let tabBarController = DNSUITabBarController()

        XCTAssertTrue(tabBarController is UITabBarController)
        XCTAssertTrue(tabBarController is DNSAppConstantsRootProtocol)
        XCTAssertTrue(tabBarController is DrawerPresenting)
        XCTAssertTrue(tabBarController is UITextFieldDelegate)
    }

    func test_tabBarController_checkBoxPressed_toggles_selection() {
        let tabBarController = DNSUITabBarController()
        let button = UIButton()

        XCTAssertFalse(button.isSelected)

        tabBarController.checkBoxPressed(sender: button)
        XCTAssertTrue(button.isSelected)

        tabBarController.checkBoxPressed(sender: button)
        XCTAssertFalse(button.isSelected)
    }

    func test_tabBarController_textFieldShouldBeginEditing_with_positive_tag() {
        let tabBarController = DNSUITabBarController()
        let textField = UITextField()
        textField.tag = 5

        let shouldBeginEditing = tabBarController.textFieldShouldBeginEditing(textField)

        XCTAssertTrue(shouldBeginEditing)
    }

    func test_tabBarController_textFieldShouldBeginEditing_with_negative_tag() {
        let tabBarController = DNSUITabBarController()
        let textField = UITextField()
        textField.tag = -1

        let shouldBeginEditing = tabBarController.textFieldShouldBeginEditing(textField)

        XCTAssertFalse(shouldBeginEditing)
    }

    func test_tabBarController_cleanupBuggyDisplay_with_excess_subviews() {
        let tabBarController = DNSUITabBarController()
        let tabBar = tabBarController.tabBar

        // Add some extra subviews to simulate the bug
        for i in 0..<5 {
            let extraView = UIView()
            extraView.tag = 1000 + i // Tag to identify test views
            tabBar.addSubview(extraView)
        }

        let initialSubviewCount = tabBar.subviews.count
        XCTAssertGreaterThan(initialSubviewCount, 3)

        tabBarController.cleanupBuggyDisplay(for: 2)

        let finalSubviewCount = tabBar.subviews.count
        XCTAssertLessThanOrEqual(finalSubviewCount, 3) // Should have at most 3 subviews (2 tabs + 1)
    }

    func test_tabBarController_cleanupBuggyDisplay_with_normal_subviews() {
        let tabBarController = DNSUITabBarController()
        let tabBar = tabBarController.tabBar

        let initialSubviewCount = tabBar.subviews.count

        tabBarController.cleanupBuggyDisplay(for: 3)

        let finalSubviewCount = tabBar.subviews.count
        XCTAssertEqual(finalSubviewCount, initialSubviewCount) // Should not remove any subviews
    }

    // MARK: - DrawerPresenting Protocol Tests

    func test_tabBarController_drawer_protocols_complete_without_error() {
        let tabBarController = DNSUITabBarController()
        let mockDrawer = MockDrawerPresentable()

        // These methods should complete without errors
        tabBarController.willOpenDrawer(mockDrawer)
        tabBarController.didOpenDrawer(mockDrawer)
        tabBarController.willCloseDrawer(mockDrawer)
        tabBarController.didCloseDrawer(mockDrawer)
        tabBarController.didChangeSizeOfDrawer(mockDrawer, to: 100.0)

        XCTAssertTrue(true) // If we reach here, all methods completed successfully
    }

    // MARK: - Edge Cases

    func test_navigationController_multiple_checkBox_presses() {
        let navigationController = DNSUINavigationController()
        let button = UIButton()

        // Rapid multiple presses
        for i in 0..<10 {
            navigationController.checkBoxPressed(sender: button)
            XCTAssertEqual(button.isSelected, i % 2 == 0) // Should alternate
        }
    }

    func test_tabBarController_cleanupBuggyDisplay_edge_cases() {
        let tabBarController = DNSUITabBarController()

        // Test with zero tabs
        tabBarController.cleanupBuggyDisplay(for: 0)

        // Test with negative tabs (edge case)
        tabBarController.cleanupBuggyDisplay(for: -1)

        // Test with very large number of tabs
        tabBarController.cleanupBuggyDisplay(for: 100)

        XCTAssertTrue(true) // Methods should complete without crashing
    }

    func test_controllers_respond_to_protocol_methods() {
        let navigationController = DNSUINavigationController()
        let tabBarController = DNSUITabBarController()

        // Test that controllers respond to protocol methods
        XCTAssertTrue(navigationController.responds(to: #selector(DNSUINavigationController.checkBoxPressed(sender:))))
        XCTAssertTrue(navigationController.responds(to: #selector(DNSUINavigationController.textFieldShouldBeginEditing(_:))))

        XCTAssertTrue(tabBarController.responds(to: #selector(DNSUITabBarController.checkBoxPressed(sender:))))
        XCTAssertTrue(tabBarController.responds(to: #selector(DNSUITabBarController.textFieldShouldBeginEditing(_:))))
    }

    // MARK: - Type Alias Tests

    func test_type_aliases_are_correct() {
        // Test that type aliases point to the correct classes
        let navigationController: DNSUINavigationController = UINavigationController()
        let tabBarController: DNSUITabBarController = UITabBarController()

        XCTAssertTrue(navigationController is UINavigationController)
        XCTAssertTrue(tabBarController is UITabBarController)
    }

    // MARK: - Memory Management Tests

    func test_controllers_can_be_deallocated() {
        weak var weakNavigationController: DNSUINavigationController?
        weak var weakTabBarController: DNSUITabBarController?

        autoreleasepool {
            let navigationController = DNSUINavigationController()
            let tabBarController = DNSUITabBarController()

            weakNavigationController = navigationController
            weakTabBarController = tabBarController

            XCTAssertNotNil(weakNavigationController)
            XCTAssertNotNil(weakTabBarController)
        }

        // After the autoreleasepool, controllers should be deallocated
        XCTAssertNil(weakNavigationController)
        XCTAssertNil(weakTabBarController)
    }
}

// MARK: - Mock Classes

class MockDrawerPresentable: DrawerPresentable {
    var configuration: DrawerConfiguration = DrawerConfiguration(gravity: .bottom, offset: 100)
}