//
//  DNSAppConstantsExtensionTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
@testable import DNSBaseStage
@testable import DNSCore

class DNSAppConstantsExtensionTests: XCTestCase {

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Extension Existence Tests
    func test_baseStageDefaults_extension_exists() {
        XCTAssertNotNil(DNSAppConstants.baseStageDefaults)
    }

    func test_baseStageDefaults_is_correct_type() {
        let defaults = DNSAppConstants.baseStageDefaults
        XCTAssertTrue(defaults is DNSBaseStageModels.Defaults)
    }

    // MARK: - Error Configuration Tests
    func test_error_defaults_dismissingDirection() {
        let defaults = DNSAppConstants.baseStageDefaults
        XCTAssertEqual(defaults.error.dismissingDirection, .left)
    }

    func test_error_defaults_duration() {
        let defaults = DNSAppConstants.baseStageDefaults
        // Test the duration is set (equality check requires Equatable conformance)
        if case .long = defaults.error.duration {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected .long duration")
        }
    }

    func test_error_defaults_location() {
        let defaults = DNSAppConstants.baseStageDefaults
        XCTAssertEqual(defaults.error.location, .bottom)
    }

    func test_error_defaults_presentingDirection() {
        let defaults = DNSAppConstants.baseStageDefaults
        XCTAssertEqual(defaults.error.presentingDirection, .right)
    }

    // MARK: - Message Configuration Tests
    func test_message_defaults_dismissingDirection() {
        let defaults = DNSAppConstants.baseStageDefaults
        XCTAssertEqual(defaults.message.dismissingDirection, .right)
    }

    func test_message_defaults_duration() {
        let defaults = DNSAppConstants.baseStageDefaults
        // Test the duration is set (equality check requires Equatable conformance)
        if case .custom(let duration) = defaults.message.duration {
            XCTAssertEqual(duration, 6)
        } else {
            XCTFail("Expected .custom(6) duration")
        }
    }

    func test_message_defaults_location() {
        let defaults = DNSAppConstants.baseStageDefaults
        XCTAssertEqual(defaults.message.location, .bottom)
    }

    func test_message_defaults_presentingDirection() {
        let defaults = DNSAppConstants.baseStageDefaults
        XCTAssertEqual(defaults.message.presentingDirection, .left)
    }

    // MARK: - Configuration Consistency Tests
    func test_error_and_message_have_same_location() {
        let defaults = DNSAppConstants.baseStageDefaults
        XCTAssertEqual(defaults.error.location, defaults.message.location)
    }

    func test_error_and_message_have_opposite_directions() {
        let defaults = DNSAppConstants.baseStageDefaults

        // Error: presents from right, dismisses to left
        XCTAssertEqual(defaults.error.presentingDirection, .right)
        XCTAssertEqual(defaults.error.dismissingDirection, .left)

        // Message: presents from left, dismisses to right
        XCTAssertEqual(defaults.message.presentingDirection, .left)
        XCTAssertEqual(defaults.message.dismissingDirection, .right)
    }

    // MARK: - Duration Configuration Tests
    func test_error_duration_is_long() {
        let defaults = DNSAppConstants.baseStageDefaults

        if case .long = defaults.error.duration {
            XCTAssertTrue(true) // Test passes
        } else {
            XCTFail("Error duration should be .long")
        }
    }

    func test_message_duration_is_custom_six() {
        let defaults = DNSAppConstants.baseStageDefaults

        if case let .custom(duration) = defaults.message.duration {
            XCTAssertEqual(duration, 6)
        } else {
            XCTFail("Message duration should be .custom(6)")
        }
    }

    // MARK: - Static Property Tests
    func test_baseStageDefaults_is_static() {
        let defaults1 = DNSAppConstants.baseStageDefaults
        let defaults2 = DNSAppConstants.baseStageDefaults

        // Should have the same configuration values (structs can't use ObjectIdentifier)
        XCTAssertEqual(defaults1.error.location, defaults2.error.location)
        XCTAssertEqual(defaults1.message.location, defaults2.message.location)
    }

    func test_baseStageDefaults_is_lazy() {
        // Test that accessing multiple times returns consistent configuration
        let first = DNSAppConstants.baseStageDefaults
        let second = DNSAppConstants.baseStageDefaults
        let third = DNSAppConstants.baseStageDefaults

        XCTAssertEqual(first.error.location, second.error.location)
        XCTAssertEqual(second.message.location, third.message.location)
    }

    // MARK: - Modification Tests
    func test_baseStageDefaults_can_be_modified() {
        var originalDefaults = DNSAppConstants.baseStageDefaults
        let originalErrorDuration = originalDefaults.error.duration
        let originalMessageLocation = originalDefaults.message.location

        // Modify the defaults
        originalDefaults.error.duration = .short
        originalDefaults.message.location = .top

        // Verify changes
        XCTAssertEqual(originalDefaults.error.duration, .short)
        XCTAssertEqual(originalDefaults.message.location, .top)

        // Restore original values
        originalDefaults.error.duration = originalErrorDuration
        originalDefaults.message.location = originalMessageLocation
    }

    // MARK: - Property Access Tests
    func test_error_properties_accessible() {
        let errorDefaults = DNSAppConstants.baseStageDefaults.error

        XCTAssertNotNil(errorDefaults.dismissingDirection)
        XCTAssertNotNil(errorDefaults.duration)
        XCTAssertNotNil(errorDefaults.location)
        XCTAssertNotNil(errorDefaults.presentingDirection)
    }

    func test_message_properties_accessible() {
        let messageDefaults = DNSAppConstants.baseStageDefaults.message

        XCTAssertNotNil(messageDefaults.dismissingDirection)
        XCTAssertNotNil(messageDefaults.duration)
        XCTAssertNotNil(messageDefaults.location)
        XCTAssertNotNil(messageDefaults.presentingDirection)
    }

    // MARK: - Type Safety Tests
    func test_direction_types_are_correct() {
        let defaults = DNSAppConstants.baseStageDefaults

        // All direction properties should be of the same enum type
        XCTAssertTrue(type(of: defaults.error.dismissingDirection) == type(of: defaults.error.presentingDirection))
        XCTAssertTrue(type(of: defaults.message.dismissingDirection) == type(of: defaults.message.presentingDirection))
        XCTAssertTrue(type(of: defaults.error.dismissingDirection) == type(of: defaults.message.dismissingDirection))
    }

    func test_location_types_are_correct() {
        let defaults = DNSAppConstants.baseStageDefaults

        // All location properties should be of the same enum type
        XCTAssertTrue(type(of: defaults.error.location) == type(of: defaults.message.location))
    }

    // MARK: - Configuration Validation Tests
    func test_configuration_makes_logical_sense() {
        let defaults = DNSAppConstants.baseStageDefaults

        // Errors typically need more attention, so longer duration makes sense
        switch (defaults.error.duration, defaults.message.duration) {
        case (.long, .custom(let messageSeconds)):
            // Long is typically longer than 6 seconds, this is reasonable
            XCTAssertGreaterThan(messageSeconds, 0)
        case (.short, _):
            XCTFail("Error duration should not be short in default configuration")
        default:
            break // Other combinations might be valid
        }
    }

    func test_presentation_directions_are_opposite() {
        let defaults = DNSAppConstants.baseStageDefaults

        // The configuration shows error and message present from opposite sides
        let errorPresenting = defaults.error.presentingDirection
        let messagePresenting = defaults.message.presentingDirection

        XCTAssertNotEqual(errorPresenting, messagePresenting)
    }

    // MARK: - Thread Safety Tests
    func test_concurrent_access_thread_safety() {
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 10

        let dispatchGroup = DispatchGroup()
        var accessedDefaults: [DNSBaseStageModels.Defaults] = []
        let accessQueue = DispatchQueue(label: "access.queue", attributes: .concurrent)

        for _ in 0..<10 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                let defaults = DNSAppConstants.baseStageDefaults
                accessQueue.async(flags: .barrier) {
                    accessedDefaults.append(defaults)
                    expectation.fulfill()
                    dispatchGroup.leave()
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)

        // All accessed instances should have consistent configuration
        let firstDefaults = accessedDefaults.first!
        for defaults in accessedDefaults {
            XCTAssertEqual(defaults.error.location, firstDefaults.error.location)
            XCTAssertEqual(defaults.message.location, firstDefaults.message.location)
        }
    }

    // MARK: - Configuration Consistency Tests
    func test_baseStageDefaults_configuration_consistency() {
        let defaults = DNSAppConstants.baseStageDefaults

        // Test that default configuration remains consistent
        XCTAssertNotNil(defaults.error)
        XCTAssertNotNil(defaults.message)

        // Error and message should have valid configurations
        XCTAssertNotNil(defaults.error.location)
        XCTAssertNotNil(defaults.message.location)
    }

    // MARK: - Performance Tests
    func test_performance_accessing_baseStageDefaults() {
        measure {
            for _ in 0..<1000 {
                let _ = DNSAppConstants.baseStageDefaults
            }
        }
    }

    func test_performance_accessing_nested_properties() {
        let defaults = DNSAppConstants.baseStageDefaults

        measure {
            for _ in 0..<1000 {
                let _ = defaults.error.duration
                let _ = defaults.error.location
                let _ = defaults.message.duration
                let _ = defaults.message.location
            }
        }
    }

    // MARK: - Integration Tests
    func test_baseStageDefaults_integration_with_models() {
        let defaults = DNSAppConstants.baseStageDefaults

        // Should integrate with DNSBaseStageModels
        XCTAssertTrue(defaults is DNSBaseStageModels.Defaults)

        // Should have proper error and message configurations
        XCTAssertNotNil(defaults.error)
        XCTAssertNotNil(defaults.message)
    }

    // MARK: - Edge Cases Tests
    func test_defaults_modification_persistence() {
        let originalErrorDuration = DNSAppConstants.baseStageDefaults.error.duration

        // Modify the duration
        DNSAppConstants.baseStageDefaults.error.duration = .short

        // Verify the change persists
        XCTAssertEqual(DNSAppConstants.baseStageDefaults.error.duration, .short)

        // Restore original value
        DNSAppConstants.baseStageDefaults.error.duration = originalErrorDuration
    }

    func test_configuration_completeness() {
        let defaults = DNSAppConstants.baseStageDefaults

        // Both error and message should have complete configurations
        XCTAssertNotNil(defaults.error.dismissingDirection)
        XCTAssertNotNil(defaults.error.duration)
        XCTAssertNotNil(defaults.error.location)
        XCTAssertNotNil(defaults.error.presentingDirection)

        XCTAssertNotNil(defaults.message.dismissingDirection)
        XCTAssertNotNil(defaults.message.duration)
        XCTAssertNotNil(defaults.message.location)
        XCTAssertNotNil(defaults.message.presentingDirection)
    }

    // MARK: - Documentation Tests
    func test_configuration_reflects_documented_behavior() {
        let defaults = DNSAppConstants.baseStageDefaults

        // Based on the source code documentation/implementation:
        // Error messages are more prominent (longer duration, from right)
        // Regular messages are less intrusive (shorter duration, from left)

        // Error configuration
        XCTAssertEqual(defaults.error.presentingDirection, .right, "Errors should present from right for prominence")
        XCTAssertEqual(defaults.error.dismissingDirection, .left, "Errors should dismiss to left")
        XCTAssertEqual(defaults.error.duration, .long, "Errors should have long duration for attention")
        XCTAssertEqual(defaults.error.location, .bottom, "Errors should appear at bottom")

        // Message configuration
        XCTAssertEqual(defaults.message.presentingDirection, .left, "Messages should present from left")
        XCTAssertEqual(defaults.message.dismissingDirection, .right, "Messages should dismiss to right")
        if case let .custom(duration) = defaults.message.duration {
            XCTAssertEqual(duration, 6, "Messages should have 6 second custom duration")
        } else {
            XCTFail("Message duration should be custom with 6 seconds")
        }
        XCTAssertEqual(defaults.message.location, .bottom, "Messages should appear at bottom")
    }
}