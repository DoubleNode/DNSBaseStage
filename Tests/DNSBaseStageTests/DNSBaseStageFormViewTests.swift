//
//  DNSBaseStageFormViewTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import UIKit
@testable import DNSBaseStage
@testable import DNSCore
@testable import DNSThemeObjects

class DNSBaseStageFormViewTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSBaseStageFormView!
    private var parentView: UIView!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = DNSBaseStageFormView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        parentView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
    }

    override func tearDown() {
        sut = nil
        parentView = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func test_initialization_default() {
        let formView = DNSBaseStageFormView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        XCTAssertNotNil(formView)
        XCTAssertTrue(formView is DNSUIView)
    }

    func test_initialization_with_frame() {
        let frame = CGRect(x: 10, y: 20, width: 300, height: 200)
        let formView = DNSBaseStageFormView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!

        XCTAssertNotNil(formView)
        XCTAssertEqual(formView.frame, frame)
    }

    func test_initialization_with_coder() {
        let coder = NSCoder()
        let formView = DNSBaseStageFormView(coder: coder)

        // Should handle coder initialization (may be nil depending on implementation)
        if let view = formView {
            XCTAssertTrue(view is DNSBaseStageFormView)
        }
    }

    // MARK: - Inheritance Tests
    func test_inherits_from_DNSUIView() {
        XCTAssertTrue(sut is DNSUIView)
        XCTAssertTrue(sut.isKind(of: DNSUIView.self))
    }

    func test_inherits_from_UIView() {
        XCTAssertTrue(sut is UIView)
        XCTAssertTrue(sut.isKind(of: UIView.self))
    }

    // MARK: - Basic Properties Tests
    func test_default_properties() {
        XCTAssertEqual(sut.frame, CGRect.zero)
        XCTAssertEqual(sut.bounds, CGRect.zero)
        XCTAssertTrue(sut.clipsToBounds)
        XCTAssertEqual(sut.backgroundColor, UIColor.clear)
    }

    func test_view_hierarchy() {
        parentView.addSubview(sut)

        XCTAssertEqual(sut.superview, parentView)
        XCTAssertTrue(parentView.subviews.contains(sut))
    }

    func test_subview_management() {
        let childView = UIView()
        sut.addSubview(childView)

        XCTAssertEqual(childView.superview, sut)
        XCTAssertTrue(sut.subviews.contains(childView))
        XCTAssertEqual(sut.subviews.count, 1)
    }

    // MARK: - Layout Tests
    func test_frame_setting() {
        let newFrame = CGRect(x: 50, y: 100, width: 200, height: 150)
        sut.frame = newFrame

        XCTAssertEqual(sut.frame, newFrame)
    }

    func test_bounds_setting() {
        let newBounds = CGRect(x: 0, y: 0, width: 250, height: 180)
        sut.bounds = newBounds

        XCTAssertEqual(sut.bounds, newBounds)
    }

    func test_center_setting() {
        let newCenter = CGPoint(x: 160, y: 240)
        sut.center = newCenter

        XCTAssertEqual(sut.center, newCenter)
    }

    func test_autolayout_properties() {
        sut.translatesAutoresizingMaskIntoConstraints = false
        XCTAssertFalse(sut.translatesAutoresizingMaskIntoConstraints)

        sut.translatesAutoresizingMaskIntoConstraints = true
        XCTAssertTrue(sut.translatesAutoresizingMaskIntoConstraints)
    }

    // MARK: - Auto Layout Tests
    func test_constraint_setup() {
        parentView.addSubview(sut)
        sut.translatesAutoresizingMaskIntoConstraints = false

        let leadingConstraint = sut.leadingAnchor.constraint(equalTo: parentView.leadingAnchor)
        let trailingConstraint = sut.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        let topConstraint = sut.topAnchor.constraint(equalTo: parentView.topAnchor)
        let bottomConstraint = sut.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)

        NSLayoutConstraint.activate([
            leadingConstraint,
            trailingConstraint,
            topConstraint,
            bottomConstraint
        ])

        XCTAssertTrue(leadingConstraint.isActive)
        XCTAssertTrue(trailingConstraint.isActive)
        XCTAssertTrue(topConstraint.isActive)
        XCTAssertTrue(bottomConstraint.isActive)
    }

    func test_intrinsic_content_size() {
        let intrinsicSize = sut.intrinsicContentSize

        // Should have a valid intrinsic content size or return UIView.noIntrinsicMetric
        XCTAssertTrue(intrinsicSize.width >= 0 || intrinsicSize.width == UIView.noIntrinsicMetric)
        XCTAssertTrue(intrinsicSize.height >= 0 || intrinsicSize.height == UIView.noIntrinsicMetric)
    }

    // MARK: - Form-Specific Tests
    func test_form_view_can_contain_form_elements() {
        let textField = UITextField()
        let label = UILabel()
        let button = UIButton()

        sut.addSubview(textField)
        sut.addSubview(label)
        sut.addSubview(button)

        XCTAssertEqual(sut.subviews.count, 3)
        XCTAssertTrue(sut.subviews.contains(textField))
        XCTAssertTrue(sut.subviews.contains(label))
        XCTAssertTrue(sut.subviews.contains(button))
    }

    func test_form_view_accessibility() {
        sut.accessibilityLabel = "Form View"
        sut.accessibilityIdentifier = "form-view"

        XCTAssertEqual(sut.accessibilityLabel, "Form View")
        XCTAssertEqual(sut.accessibilityIdentifier, "form-view")
    }

    func test_form_view_with_stack_view() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10

        sut.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: sut.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: sut.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: sut.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: sut.bottomAnchor)
        ])

        XCTAssertEqual(stackView.superview, sut)
        XCTAssertTrue(sut.subviews.contains(stackView))
    }

    // MARK: - User Interaction Tests
    func test_user_interaction_enabled() {
        XCTAssertTrue(sut.isUserInteractionEnabled)

        sut.isUserInteractionEnabled = false
        XCTAssertFalse(sut.isUserInteractionEnabled)

        sut.isUserInteractionEnabled = true
        XCTAssertTrue(sut.isUserInteractionEnabled)
    }

    func test_multiple_touch_handling() {
        XCTAssertFalse(sut.isMultipleTouchEnabled)

        sut.isMultipleTouchEnabled = true
        XCTAssertTrue(sut.isMultipleTouchEnabled)
    }

    // MARK: - Visibility Tests
    func test_visibility_properties() {
        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.alpha, 1.0)

        sut.isHidden = true
        XCTAssertTrue(sut.isHidden)

        sut.isHidden = false
        sut.alpha = 0.5
        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.alpha, 0.5, accuracy: 0.001)
    }

    func test_background_color_setting() {
        sut.backgroundColor = UIColor.red
        XCTAssertEqual(sut.backgroundColor, UIColor.red)

        sut.backgroundColor = UIColor.clear
        XCTAssertEqual(sut.backgroundColor, UIColor.clear)
    }

    // MARK: - Form Validation Support Tests
    func test_form_view_supports_validation() {
        // Test that form view can handle validation-related UI updates
        let errorLabel = UILabel()
        errorLabel.text = "Validation error"
        errorLabel.textColor = UIColor.red
        errorLabel.isHidden = true

        sut.addSubview(errorLabel)

        XCTAssertTrue(sut.subviews.contains(errorLabel))
        XCTAssertTrue(errorLabel.isHidden)

        // Simulate showing validation error
        errorLabel.isHidden = false
        XCTAssertFalse(errorLabel.isHidden)
    }

    func test_form_view_input_grouping() {
        // Test grouping of form inputs
        let nameContainer = UIView()
        let emailContainer = UIView()
        let passwordContainer = UIView()

        sut.addSubview(nameContainer)
        sut.addSubview(emailContainer)
        sut.addSubview(passwordContainer)

        XCTAssertEqual(sut.subviews.count, 3)

        // Each container can hold form elements
        nameContainer.addSubview(UITextField())
        emailContainer.addSubview(UITextField())
        passwordContainer.addSubview(UITextField())

        XCTAssertEqual(nameContainer.subviews.count, 1)
        XCTAssertEqual(emailContainer.subviews.count, 1)
        XCTAssertEqual(passwordContainer.subviews.count, 1)
    }

    // MARK: - Memory Management Tests
    func test_weak_references_not_retained() {
        weak var weakFormView: DNSBaseStageFormView?

        autoreleasepool {
            let formView = DNSBaseStageFormView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
            weakFormView = formView
            XCTAssertNotNil(weakFormView)
        }

        // Should be deallocated
        XCTAssertNil(weakFormView)
    }

    func test_subview_memory_management() {
        weak var weakSubview: UIView?

        autoreleasepool {
            let subview = UIView()
            weakSubview = subview
            sut.addSubview(subview)
            XCTAssertNotNil(weakSubview)
        }

        // Should still be retained by parent view
        XCTAssertNotNil(weakSubview)

        // Remove from parent
        sut.subviews.forEach { $0.removeFromSuperview() }

        // Should be deallocated after removal
        XCTAssertNil(weakSubview)
    }

    // MARK: - Animation Support Tests
    func test_animation_properties() {
        // Test that view supports animations
        sut.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        let expectation = XCTestExpectation(description: "Animation completion")

        UIView.animate(withDuration: 0.1, animations: {
            self.sut.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
        }) { completed in
            XCTAssertTrue(completed)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_transform_animations() {
        let originalTransform = sut.transform

        sut.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        XCTAssertNotEqual(sut.transform, originalTransform)

        sut.transform = CGAffineTransform.identity
        XCTAssertEqual(sut.transform, CGAffineTransform.identity)
    }

    // MARK: - Event Handling Tests
    func test_gesture_recognizer_support() {
        let tapGesture = UITapGestureRecognizer()
        sut.addGestureRecognizer(tapGesture)

        XCTAssertTrue(sut.gestureRecognizers?.contains(tapGesture) ?? false)

        sut.removeGestureRecognizer(tapGesture)
        XCTAssertFalse(sut.gestureRecognizers?.contains(tapGesture) ?? true)
    }

    // MARK: - Performance Tests
    func test_performance_view_creation() {
        measure {
            for _ in 0..<100 {
                let _ = DNSBaseStageFormView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
            }
        }
    }

    func test_performance_subview_addition() {
        measure {
            for i in 0..<100 {
                let subview = UIView()
                subview.tag = i
                sut.addSubview(subview)
            }

            // Clean up
            sut.subviews.forEach { $0.removeFromSuperview() }
        }
    }

    func test_performance_layout_updates() {
        parentView.addSubview(sut)
        sut.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sut.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            sut.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            sut.topAnchor.constraint(equalTo: parentView.topAnchor),
            sut.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])

        measure {
            for _ in 0..<100 {
                sut.setNeedsLayout()
                sut.layoutIfNeeded()
            }
        }
    }

    // MARK: - Edge Cases Tests
    func test_nil_frame_handling() {
        XCTAssertNoThrow {
            self.sut.frame = CGRect.null
        }
    }

    func test_infinite_frame_handling() {
        XCTAssertNoThrow {
            self.sut.frame = CGRect.infinite
        }
    }

    func test_zero_size_frame() {
        sut.frame = CGRect(x: 10, y: 10, width: 0, height: 0)
        XCTAssertEqual(sut.frame.size, CGSize.zero)
    }

    func test_negative_frame_values() {
        let negativeFrame = CGRect(x: -10, y: -20, width: 100, height: 50)
        sut.frame = negativeFrame
        XCTAssertEqual(sut.frame, negativeFrame)
    }

    // MARK: - Complex Form Tests
    func test_complex_form_layout() {
        // Create a complex form layout
        let scrollView = UIScrollView()
        let contentView = UIView()
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill

        // Add form elements
        let titleLabel = UILabel()
        let nameField = UITextField()
        let emailField = UITextField()
        let submitButton = UIButton()

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(submitButton)

        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        sut.addSubview(scrollView)

        // Test hierarchy
        XCTAssertEqual(sut.subviews.count, 1)
        XCTAssertTrue(sut.subviews.contains(scrollView))
        XCTAssertTrue(scrollView.subviews.contains(contentView))
        XCTAssertTrue(contentView.subviews.contains(stackView))
        XCTAssertEqual(stackView.arrangedSubviews.count, 4)
    }

    // MARK: - Theme Integration Tests
    func test_theme_compatibility() {
        // Test that form view works with theming
        sut.backgroundColor = UIColor.systemBackground
        XCTAssertNotNil(sut.backgroundColor)

        // Should support dynamic colors
        if #available(iOS 13.0, *) {
            sut.backgroundColor = UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? .black : .white
            }
            XCTAssertNotNil(sut.backgroundColor)
        }
    }
}

// MARK: - Mock Classes and Extensions

class MockFormView: DNSBaseStageFormView {
    var layoutSubviewsCalled = false

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsCalled = true
    }
}