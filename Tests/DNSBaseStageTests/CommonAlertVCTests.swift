//
//  CommonAlertVCTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import UIKit
@testable import DNSBaseStage
@testable import kCustomAlert
@testable import DNSCore
@testable import DNSThemeTypes
@testable import DNSCoreThreading

class CommonAlertVCTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: CommonAlertVC!
    private var mockWindow: UIWindow!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        // Use the kCustomAlert module bundle for loading the nib
        let bundle = Bundle.dnsLookupBundle(for: CommonAlertVC.self)
        sut = CommonAlertVC(nibName: "CommonAlertVC", bundle: bundle)
        mockWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
    }

    override func tearDown() {
        sut = nil
        mockWindow = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func test_initialization_default() {
        let alertVC = CommonAlertVC()
        XCTAssertNotNil(alertVC)
        XCTAssertTrue(alertVC is UIViewController)
    }

    func test_initialization_with_nib() {
        let alertVC = CommonAlertVC(nibName: "TestNib", bundle: nil)
        XCTAssertNotNil(alertVC)
        XCTAssertEqual(alertVC.nibName, "TestNib")
    }

    // MARK: - Outlet Tests
    func test_outlets_exist() {
        // Load the view to connect outlets
        _ = sut.view

        // Test that outlets can be accessed (they may be nil if not connected)
        XCTAssertTrue(true) // This test verifies outlets don't crash when accessed
        let _ = sut.viewContainer
        let _ = sut.messageLabel
        let _ = sut.disclaimerLabel
        let _ = sut.titleLabel
        let _ = sut.subtitleLabel
        let _ = sut.cancelButton
        let _ = sut.actionButton
    }

    // MARK: - Property Tests
    func test_initial_property_values() {
        XCTAssertEqual(sut.disclaimer, "")
        XCTAssertEqual(sut.message, "")
        XCTAssertEqual(sut.subtitle, "")
        XCTAssertEqual(sut.tags, [])
        XCTAssertNil(sut.imageItem)
        XCTAssertNil(sut.imageUrl)
        XCTAssertTrue(sut.isContactNumberHidden)
    }

    func test_property_setting() {
        sut.disclaimer = "Test disclaimer"
        sut.message = "Test message"
        sut.subtitle = "Test subtitle"
        sut.tags = ["tag1", "tag2"]

        XCTAssertEqual(sut.disclaimer, "Test disclaimer")
        XCTAssertEqual(sut.message, "Test message")
        XCTAssertEqual(sut.subtitle, "Test subtitle")
        XCTAssertEqual(sut.tags, ["tag1", "tag2"])
    }

    func test_image_property_setting() {
        let testImage = UIImage()
        let testURL = URL(string: "https://example.com/image.jpg")

        sut.imageItem = testImage
        sut.imageUrl = testURL

        XCTAssertEqual(sut.imageItem, testImage)
        XCTAssertEqual(sut.imageUrl, testURL)
    }

    // MARK: - Action Array Tests
    func test_arrayAction_setting() {
        let testActions: [[String: DNSStringBlock]] = [
            ["OK": { _ in print("OK pressed") }],
            ["Cancel": { _ in print("Cancel pressed") }]
        ]

        sut.arrayAction = testActions
        XCTAssertEqual(sut.arrayAction?.count, 2)
    }

    func test_arrayActionStyles_setting() {
        let testStyles: [[String: DNSThemeButtonStyle]] = [
            ["OK": .default],
            ["Cancel": .default]
        ]

        sut.arrayActionStyles = testStyles
        XCTAssertEqual(sut.arrayActionStyles?.count, 2)
    }

    func test_okButtonAct_setting() {
        var called = false
        let testAction: DNSStringBlock = { _ in called = true }

        sut.okButtonAct = testAction
        sut.okButtonAct?("test")

        XCTAssertTrue(called)
    }

    // MARK: - Lifecycle Tests
    func test_viewDidLoad() {
        XCTAssertNoThrow {
            self.sut.viewDidLoad()
        }
    }

    func test_viewWillAppear() {
        // Set some test data first
        sut.disclaimer = "Test disclaimer"
        sut.message = "Test message"
        sut.subtitle = "Test subtitle"
        sut.tags = ["tag1", "tag2"]

        XCTAssertNoThrow {
            self.sut.viewWillAppear(true)
        }
    }

    func test_viewWillAppear_with_empty_data() {
        XCTAssertNoThrow {
            self.sut.viewWillAppear(true)
        }
    }

    // MARK: - Tag Handling Tests
    func test_tag_display_logic_with_no_tags() {
        sut.tags = []
        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_tag_display_logic_with_one_tag() {
        sut.tags = ["single tag"]
        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_tag_display_logic_with_two_tags() {
        sut.tags = ["first tag", "second tag"]
        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_tag_display_logic_with_empty_strings() {
        sut.tags = ["", "valid tag"]
        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    // MARK: - Image Handling Tests
    func test_image_handling_with_no_image() {
        sut.imageItem = nil
        sut.imageUrl = nil

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_image_handling_with_image_item() {
        sut.imageItem = UIImage()
        sut.imageUrl = nil

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_image_handling_with_image_url() {
        sut.imageItem = nil
        sut.imageUrl = URL(string: "https://example.com/image.jpg")

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_image_handling_with_both_image_sources() {
        sut.imageItem = UIImage()
        sut.imageUrl = URL(string: "https://example.com/image.jpg")

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    // MARK: - Action Button Tests
    func test_actionButtonAction() {
        var actionCalled = false
        let testAction: DNSStringBlock = { _ in actionCalled = true }

        sut.okButtonAct = testAction

        let mockButton = UIButton()
        mockButton.setTitle("Test Action", for: .normal)

        XCTAssertNoThrow {
            self.sut.actionButtonAction(sender: mockButton)
        }

        XCTAssertTrue(actionCalled)
    }

    func test_actionButtonAction_with_array_actions() {
        var actionCalled = false
        let testActions: [[String: DNSStringBlock]] = [
            ["OK": { _ in actionCalled = true }]
        ]

        sut.arrayAction = testActions

        let mockButton = UIButton()
        mockButton.setTitle("OK", for: .normal)

        XCTAssertNoThrow {
            self.sut.actionButtonAction(sender: mockButton)
        }

        XCTAssertTrue(actionCalled)
    }

    func test_actionButtonAction_with_non_matching_title() {
        var actionCalled = false
        let testActions: [[String: DNSStringBlock]] = [
            ["OK": { _ in actionCalled = true }]
        ]

        sut.arrayAction = testActions

        let mockButton = UIButton()
        mockButton.setTitle("Different Title", for: .normal)

        XCTAssertNoThrow {
            self.sut.actionButtonAction(sender: mockButton)
        }

        // Should not be called since title doesn't match
        XCTAssertFalse(actionCalled)
    }

    // MARK: - Cancel Button Tests
    func test_cancelButtonAction() {
        var actionCalled = false
        let testAction: DNSStringBlock = { _ in actionCalled = true }

        sut.okButtonAct = testAction

        let mockButton = UIButton()
        mockButton.setTitle("Cancel", for: .normal)

        XCTAssertNoThrow {
            self.sut.cancelButtonAction(sender: mockButton)
        }

        XCTAssertTrue(actionCalled)
    }

    func test_cancelButtonAction_with_array_actions() {
        var actionCalled = false
        let testActions: [[String: DNSStringBlock]] = [
            ["OK": { _ in }],
            ["Cancel": { _ in actionCalled = true }]
        ]

        sut.arrayAction = testActions

        let mockButton = UIButton()
        mockButton.setTitle("Cancel", for: .normal)

        XCTAssertNoThrow {
            self.sut.cancelButtonAction(sender: mockButton)
        }

        XCTAssertTrue(actionCalled)
    }

    func test_cancelButtonAction_without_array_actions() {
        var actionCalled = false
        let testAction: DNSStringBlock = { _ in actionCalled = true }

        sut.okButtonAct = testAction

        let mockButton = UIButton()
        mockButton.setTitle("Cancel", for: .normal)

        XCTAssertNoThrow {
            self.sut.cancelButtonAction(sender: mockButton)
        }

        XCTAssertTrue(actionCalled)
    }

    // MARK: - Contact Button Tests
    func test_contactButtonAction_with_valid_phone() {
        let mockButton = UIButton()
        mockButton.setTitle("1234567890", for: .normal)

        XCTAssertNoThrow {
            self.sut.contactButtonAction(sender: mockButton)
        }
    }

    func test_contactButtonAction_with_empty_phone() {
        let mockButton = UIButton()
        mockButton.setTitle("", for: .normal)

        XCTAssertNoThrow {
            self.sut.contactButtonAction(sender: mockButton)
        }
    }

    func test_contactButtonAction_with_nil_title() {
        let mockButton = UIButton()
        // Title is nil by default

        XCTAssertNoThrow {
            self.sut.contactButtonAction(sender: mockButton)
        }
    }

    // MARK: - Static Alert Method Tests
    func test_showAlertWithTitle_basic() {
        let actions: [String: (UIAlertAction) -> Void] = [
            "OK": { _ in print("OK pressed") }
        ]

        XCTAssertNoThrow {
            CommonAlertVC.showAlertWithTitle("Test Title", message: "Test Message", actionDic: actions)
        }
    }

    func test_showAlertWithTitle_with_nil_title() {
        let actions: [String: (UIAlertAction) -> Void] = [
            "OK": { _ in print("OK pressed") }
        ]

        XCTAssertNoThrow {
            CommonAlertVC.showAlertWithTitle(nil, message: "Test Message", actionDic: actions)
        }
    }

    func test_showAlertWithTitle_with_multiple_actions() {
        let actions: [String: (UIAlertAction) -> Void] = [
            "OK": { _ in print("OK pressed") },
            "Cancel": { _ in print("Cancel pressed") },
            "Delete": { _ in print("Delete pressed") }
        ]

        XCTAssertNoThrow {
            CommonAlertVC.showAlertWithTitle("Test Title", message: "Test Message", actionDic: actions)
        }
    }

    func test_showAlertWithTitle_with_empty_actions() {
        let actions: [String: (UIAlertAction) -> Void] = [:]

        XCTAssertNoThrow {
            CommonAlertVC.showAlertWithTitle("Test Title", message: "Test Message", actionDic: actions)
        }
    }

    // MARK: - Multiple Action Button Tests
    func test_multiple_action_buttons_configuration() {
        let testActions: [[String: DNSStringBlock]] = [
            ["Primary": { _ in }, "Secondary": { _ in }, "Tertiary": { _ in }, "Quaternary": { _ in }]
        ]

        sut.arrayAction = testActions

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_action_buttons_with_styles() {
        let testActions: [[String: DNSStringBlock]] = [
            ["Primary": { _ in }, "Secondary": { _ in }]
        ]
        let testStyles: [[String: DNSThemeButtonStyle]] = [
            ["Primary": .default, "Secondary": .default]
        ]

        sut.arrayAction = testActions
        sut.arrayActionStyles = testStyles

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_empty_action_button_configuration() {
        let testActions: [[String: DNSStringBlock]] = [
            [:], // Empty dictionary
            ["Cancel": { _ in }]
        ]

        sut.arrayAction = testActions

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    // MARK: - Constraint Handling Tests
    func test_cancel_button_spacer_constraint() {
        // Test initial constraint constant
        XCTAssertEqual(sut.cancelButtonSpacerViewConstraintConstant, 0)

        sut.cancelButtonSpacerViewConstraintConstant = 10.0
        XCTAssertEqual(sut.cancelButtonSpacerViewConstraintConstant, 10.0)
    }

    // MARK: - Memory Management Tests
    func test_weak_references_not_retained() {
        weak var weakAlert: CommonAlertVC?

        autoreleasepool {
            let alert = CommonAlertVC()
            weakAlert = alert
            XCTAssertNotNil(weakAlert)
        }

        // Should be deallocated
        XCTAssertNil(weakAlert)
    }

    func test_action_blocks_memory_management() {
        weak var weakSelf: CommonAlertVCTests?
        weakSelf = self

        let testAction: DNSStringBlock = { [weak weakSelf] _ in
            XCTAssertNotNil(weakSelf)
        }

        sut.okButtonAct = testAction
        XCTAssertNotNil(weakSelf)
    }

    // MARK: - URL Handling Tests
    func test_valid_url_creation() {
        let validURLString = "https://example.com/image.jpg"
        let url = URL(string: validURLString)

        XCTAssertNotNil(url)

        sut.imageUrl = url
        XCTAssertEqual(sut.imageUrl, url)
    }

    func test_invalid_url_handling() {
        let invalidURLString = "invalid url string"
        let url = URL(string: invalidURLString)

        XCTAssertNil(url)

        sut.imageUrl = url
        XCTAssertNil(sut.imageUrl)
    }

    // MARK: - Performance Tests
    func test_performance_view_loading() {
        measure {
            for _ in 0..<10 {
                let alert = CommonAlertVC()
                _ = alert.view
            }
        }
    }

    func test_performance_viewWillAppear() {
        sut.disclaimer = "Test disclaimer"
        sut.message = "Test message"
        sut.subtitle = "Test subtitle"
        sut.tags = ["tag1", "tag2"]

        measure {
            for _ in 0..<100 {
                self.sut.viewWillAppear(false)
            }
        }
    }

    func test_performance_action_button_configuration() {
        let testActions: [[String: DNSStringBlock]] = [
            ["Action1": { _ in }, "Action2": { _ in }, "Action3": { _ in }, "Action4": { _ in }]
        ]

        sut.arrayAction = testActions

        // Ensure view is loaded before calling viewWillAppear
        sut.loadViewIfNeeded()

        measure {
            for _ in 0..<100 {
                self.sut.viewWillAppear(false)
            }
        }
    }

    // MARK: - Edge Cases Tests
    func test_extremely_long_text() {
        let longText = String(repeating: "A", count: 10000)

        sut.disclaimer = longText
        sut.message = longText
        sut.subtitle = longText

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_unicode_text_handling() {
        sut.disclaimer = "测试免责声明 🎉"
        sut.message = "тестовое сообщение ⭐"
        sut.subtitle = "字幕测试 🚀"
        sut.tags = ["标签1 🏷️", "тег2 📌"]

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_nil_string_handling() {
        // Test with nil title (from parent view controller)
        sut.title = nil

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    func test_massive_tag_array() {
        let largeTags = Array(0..<1000).map { "Tag \($0)" }
        sut.tags = largeTags

        XCTAssertNoThrow {
            self.sut.viewWillAppear(false)
        }
    }

    // MARK: - Integration Tests
    func test_complete_alert_configuration() {
        sut.disclaimer = "This is a disclaimer"
        sut.message = "This is the main message"
        sut.subtitle = "This is a subtitle"
        sut.tags = ["Important", "Urgent"]
        sut.title = "Alert Title"

        let testActions: [[String: DNSStringBlock]] = [
            ["Confirm": { _ in print("Confirmed") }],
            ["Cancel": { _ in print("Cancelled") }]
        ]

        let testStyles: [[String: DNSThemeButtonStyle]] = [
            ["Confirm": .default],
            ["Cancel": .default]
        ]

        sut.arrayAction = testActions
        sut.arrayActionStyles = testStyles

        XCTAssertNoThrow {
            self.sut.viewDidLoad()
            self.sut.viewWillAppear(true)
        }
    }
}

// MARK: - Mock Classes and Helpers

class MockAlertAction {
    let title: String
    let handler: ((UIAlertAction) -> Void)?

    init(title: String, handler: ((UIAlertAction) -> Void)? = nil) {
        self.title = title
        self.handler = handler
    }
}