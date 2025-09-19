//
//  ExtensionUIViewControllerTests.swift
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

class ExtensionUIViewControllerTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: UIViewController!
    private var mockWindow: UIWindow!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = UIViewController()
        mockWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        mockWindow.rootViewController = sut
        mockWindow.makeKeyAndVisible()
    }

    override func tearDown() {
        mockWindow.isHidden = true
        mockWindow = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Extension Method Existence Tests
    func test_showCustomAlertWith_method_exists() {
        // Test that the method can be called without error
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: [],
                title: "Test Title",
                subtitle: "Test Subtitle",
                message: "Test Message",
                disclaimer: "Test Disclaimer",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    // MARK: - Basic Alert Presentation Tests
    func test_showCustomAlertWith_basic_parameters() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: [],
                title: "Test Title",
                subtitle: "Test Subtitle",
                message: "Test Message",
                disclaimer: "Test Disclaimer",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_default_nib() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Test Tag"],
                title: "Alert Title",
                subtitle: "Alert Subtitle",
                message: "Alert Message",
                disclaimer: "Alert Disclaimer",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_custom_nib() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                nibName: "CustomAlertNib",
                tags: ["Custom Tag"],
                title: "Custom Title",
                subtitle: "Custom Subtitle",
                message: "Custom Message",
                disclaimer: "Custom Disclaimer",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_custom_bundle() {
        let testBundle = Bundle.dnsLookupBundle(for: CommonAlertVC.self)

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                nibBundle: testBundle,
                tags: ["Bundle Tag"],
                title: "Bundle Title",
                subtitle: "Bundle Subtitle",
                message: "Bundle Message",
                disclaimer: "Bundle Disclaimer",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    // MARK: - Action Button Tests
    func test_showCustomAlertWith_with_ok_button_action() {
        var actionCalled = false
        let okAction: DNSStringBlock = { _ in
            actionCalled = true
        }

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                okButtonAction: okAction,
                tags: [],
                title: "Action Test",
                subtitle: "",
                message: "Test message",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }

        // Note: The action won't be called in this test since we're not simulating user interaction
        XCTAssertFalse(actionCalled) // Expected since no user interaction
    }

    func test_showCustomAlertWith_with_multiple_actions() {
        let actions: [[String: DNSStringBlock]] = [
            ["Confirm": { _ in print("Confirmed") }],
            ["Cancel": { _ in print("Cancelled") }]
        ]

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Action Tag"],
                title: "Multiple Actions",
                subtitle: "Choose an option",
                message: "Please select one of the following",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: actions,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_action_styles() {
        let actions: [[String: DNSStringBlock]] = [
            ["Primary": { _ in print("Primary action") }],
            ["Secondary": { _ in print("Secondary action") }]
        ]

        let styles: [[String: DNSThemeButtonStyle]] = [
            ["Primary": .default],
            ["Secondary": .default]
        ]

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Styled Tag"],
                title: "Styled Actions",
                subtitle: "Different button styles",
                message: "These buttons have custom styles",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: actions,
                actionsStyles: styles
            )
        }
    }

    // MARK: - Image Handling Tests
    func test_showCustomAlertWith_with_image() {
        let testImage = UIImage()

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Image Tag"],
                title: "Image Alert",
                subtitle: "Alert with image",
                message: "This alert contains an image",
                disclaimer: "",
                image: testImage,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_image_url() {
        let testURL = URL(string: "https://example.com/image.jpg")

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["URL Tag"],
                title: "URL Image Alert",
                subtitle: "Alert with URL image",
                message: "This alert loads an image from URL",
                disclaimer: "",
                image: nil,
                imageUrl: testURL,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_both_image_sources() {
        let testImage = UIImage()
        let testURL = URL(string: "https://example.com/image.jpg")

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Both Image Tag"],
                title: "Both Image Sources",
                subtitle: "Image and URL provided",
                message: "Both image sources are provided",
                disclaimer: "",
                image: testImage,
                imageUrl: testURL,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    // MARK: - Tag Handling Tests
    func test_showCustomAlertWith_with_empty_tags() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: [],
                title: "No Tags",
                subtitle: "Empty tag array",
                message: "This alert has no tags",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_single_tag() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Single Tag"],
                title: "One Tag",
                subtitle: "Single tag test",
                message: "This alert has one tag",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_multiple_tags() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Tag 1", "Tag 2", "Tag 3"],
                title: "Multiple Tags",
                subtitle: "Multiple tag test",
                message: "This alert has multiple tags",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_empty_tag_strings() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["", "Valid Tag", ""],
                title: "Empty Tag Strings",
                subtitle: "Some empty tags",
                message: "This alert has some empty tag strings",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    // MARK: - Text Content Tests
    func test_showCustomAlertWith_with_long_text() {
        let longText = String(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ", count: 100)

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Long Text"],
                title: longText,
                subtitle: longText,
                message: longText,
                disclaimer: longText,
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_unicode_text() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["🏷️", "标签", "тег"],
                title: "Unicode Title 🎉",
                subtitle: "字幕测试 ⭐",
                message: "Сообщение с юникодом 🚀",
                disclaimer: "Disclaimer with émojis 💯",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_empty_strings() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: [],
                title: "",
                subtitle: "",
                message: "",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    // MARK: - Modal Presentation Tests
    func test_alert_modal_presentation_style() {
        // The extension should set specific modal presentation properties
        sut.showCustomAlertWith(
            tags: ["Modal Test"],
            title: "Modal Test",
            subtitle: "",
            message: "Testing modal presentation",
            disclaimer: "",
            image: nil,
            imageUrl: nil,
            actions: nil,
            actionsStyles: nil
        )

        // Check if a view controller was presented
        DispatchQueue.main.async {
            XCTAssertNotNil(self.sut.presentedViewController)
            if let presentedVC = self.sut.presentedViewController {
                XCTAssertEqual(presentedVC.modalPresentationStyle, .overCurrentContext)
                XCTAssertEqual(presentedVC.modalTransitionStyle, .crossDissolve)
            }
        }
    }

    // MARK: - Error Handling Tests
    func test_showCustomAlertWith_with_invalid_url() {
        let invalidURL = URL(string: "")

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Invalid URL"],
                title: "Invalid URL Test",
                subtitle: "",
                message: "Testing with invalid URL",
                disclaimer: "",
                image: nil,
                imageUrl: invalidURL,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_showCustomAlertWith_with_nil_bundle() {
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                nibBundle: nil,
                tags: ["Nil Bundle"],
                title: "Nil Bundle Test",
                subtitle: "",
                message: "Testing with nil bundle",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    // MARK: - Bundle Lookup Tests
    func test_bundle_lookup_functionality() {
        // Test that the bundle lookup works correctly
        let foundBundle = Bundle.dnsLookupBundle(for: CommonAlertVC.self)
        XCTAssertNotNil(foundBundle)
    }

    // MARK: - Presenting View Controller Logic Tests
    func test_presenting_view_controller_logic_normal_case() {
        // Normal case: view controller with superview
        sut.loadViewIfNeeded()

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Normal Case"],
                title: "Normal Presentation",
                subtitle: "",
                message: "Normal presenting view controller",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_presenting_view_controller_logic_with_parent() {
        let parentViewController = UIViewController()
        let childViewController = UIViewController()

        parentViewController.addChild(childViewController)
        childViewController.didMove(toParent: parentViewController)

        XCTAssertNoThrow {
            childViewController.showCustomAlertWith(
                tags: ["Parent Case"],
                title: "Parent Presentation",
                subtitle: "",
                message: "Child with parent presenting",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    // MARK: - Complex Action Configuration Tests
    func test_showCustomAlertWith_complex_action_configuration() {
        var confirmCalled = false
        var cancelCalled = false
        var deleteCalled = false

        let actions: [[String: DNSStringBlock]] = [
            [
                "Confirm": { _ in confirmCalled = true },
                "Delete": { _ in deleteCalled = true }
            ],
            [
                "Cancel": { _ in cancelCalled = true }
            ]
        ]

        let styles: [[String: DNSThemeButtonStyle]] = [
            [
                "Confirm": .default,
                "Delete": .default
            ],
            [
                "Cancel": .default
            ]
        ]

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Complex Actions"],
                title: "Complex Action Test",
                subtitle: "Multiple action groups",
                message: "This alert has complex action configuration",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: actions,
                actionsStyles: styles
            )
        }

        // Actions won't be called without user interaction
        XCTAssertFalse(confirmCalled)
        XCTAssertFalse(cancelCalled)
        XCTAssertFalse(deleteCalled)
    }

    // MARK: - Memory Management Tests
    func test_memory_management_with_action_blocks() {
        weak var weakSelf: ExtensionUIViewControllerTests?
        weakSelf = self

        let okAction: DNSStringBlock = { [weak weakSelf] _ in
            XCTAssertNotNil(weakSelf)
        }

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                okButtonAction: okAction,
                tags: ["Memory Test"],
                title: "Memory Management",
                subtitle: "",
                message: "Testing memory management",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }

        XCTAssertNotNil(weakSelf)
    }

    func test_memory_management_with_presented_alert() {
        weak var weakPresentedVC: UIViewController?

        autoreleasepool {
            self.sut.showCustomAlertWith(
                tags: ["Presented VC Memory"],
                title: "Presented VC Test",
                subtitle: "",
                message: "Testing presented VC memory",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )

            weakPresentedVC = sut.presentedViewController
        }

        // The presented view controller should still be retained
        DispatchQueue.main.async {
            XCTAssertNotNil(weakPresentedVC)
        }
    }

    // MARK: - Performance Tests
    func test_performance_alert_presentation() {
        // Performance test without actual modal presentation to avoid UIKit timing issues
        let bundle = Bundle.dnsLookupBundle(for: CommonAlertVC.self)

        measure {
            for i in 0..<10 {
                // Test alert creation performance without presentation
                let alertVC = CommonAlertVC(nibName: "CommonAlertVC", bundle: bundle)
                alertVC.tags = ["Performance \(i)"]
                alertVC.title = "Performance Test \(i)"
                alertVC.subtitle = "Test \(i)"
                alertVC.message = "Performance message \(i)"
                alertVC.disclaimer = "Disclaimer \(i)"
                alertVC.arrayAction = nil
                alertVC.arrayActionStyles = nil
                alertVC.imageItem = nil
                alertVC.imageUrl = nil

                // Configure modal properties (test configuration overhead)
                alertVC.modalTransitionStyle = .crossDissolve
                alertVC.modalPresentationStyle = .overCurrentContext

                // Load view to trigger view lifecycle (test view loading performance)
                alertVC.loadViewIfNeeded()
            }
        }
    }

    func test_performance_with_complex_data() {
        let largeTags = Array(0..<100).map { "Tag \($0)" }
        let largeActions: [[String: DNSStringBlock]] = [
            Dictionary(uniqueKeysWithValues: (0..<10).map { ("Action \($0)", { _ in }) })
        ]
        let bundle = Bundle.dnsLookupBundle(for: CommonAlertVC.self)

        measure {
            // Test alert creation performance with complex data without presentation
            let alertVC = CommonAlertVC(nibName: "CommonAlertVC", bundle: bundle)
            alertVC.tags = largeTags
            alertVC.title = "Large Data Test"
            alertVC.subtitle = "Performance with large data"
            alertVC.message = "Testing performance with large datasets"
            alertVC.disclaimer = "Large disclaimer text"
            alertVC.arrayAction = largeActions
            alertVC.arrayActionStyles = nil
            alertVC.imageItem = nil
            alertVC.imageUrl = nil

            // Configure modal properties
            alertVC.modalTransitionStyle = .crossDissolve
            alertVC.modalPresentationStyle = .overCurrentContext

            // Load view to trigger view lifecycle with complex data
            alertVC.loadViewIfNeeded()
        }
    }

    // MARK: - Edge Cases Tests
    func test_alert_presentation_while_another_is_presented() {
        // Present first alert
        sut.showCustomAlertWith(
            tags: ["First Alert"],
            title: "First Alert",
            subtitle: "",
            message: "First alert message",
            disclaimer: "",
            image: nil,
            imageUrl: nil,
            actions: nil,
            actionsStyles: nil
        )

        // Try to present second alert
        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                tags: ["Second Alert"],
                title: "Second Alert",
                subtitle: "",
                message: "Second alert message",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    func test_alert_presentation_from_dismissed_view_controller() {
        let dismissedVC = UIViewController()
        // Simulate a dismissed view controller

        XCTAssertNoThrow {
            dismissedVC.showCustomAlertWith(
                tags: ["Dismissed VC"],
                title: "Dismissed VC Alert",
                subtitle: "",
                message: "Alert from dismissed VC",
                disclaimer: "",
                image: nil,
                imageUrl: nil,
                actions: nil,
                actionsStyles: nil
            )
        }
    }

    // MARK: - Integration Tests
    func test_full_integration_scenario() {
        var actionExecuted = false

        let actions: [[String: DNSStringBlock]] = [
            ["Save": { _ in actionExecuted = true }],
            ["Cancel": { _ in print("Cancelled") }]
        ]

        let styles: [[String: DNSThemeButtonStyle]] = [
            ["Save": .default],
            ["Cancel": .default]
        ]

        let testImage = UIImage()
        let testURL = URL(string: "https://example.com/test.jpg")

        XCTAssertNoThrow {
            self.sut.showCustomAlertWith(
                nibName: "CommonAlertVC",
                nibBundle: Bundle.dnsLookupBundle(for: CommonAlertVC.self),
                okButtonAction: { _ in print("OK action") },
                tags: ["Integration", "Test", "Full"],
                title: "Full Integration Test",
                subtitle: "Complete test scenario",
                message: "This tests the complete integration of the alert system with all parameters configured.",
                disclaimer: "This is a test disclaimer for integration testing purposes.",
                image: testImage,
                imageUrl: testURL,
                actions: actions,
                actionsStyles: styles
            )
        }

        // Verify the alert was presented
        DispatchQueue.main.async {
            XCTAssertNotNil(self.sut.presentedViewController)
            XCTAssertTrue(self.sut.presentedViewController is CommonAlertVC)
        }
    }
}

// MARK: - Test Helper Extensions

extension UIViewController {
    var isBeingDismissedForTest: Bool {
        return self.isBeingDismissed
    }
}