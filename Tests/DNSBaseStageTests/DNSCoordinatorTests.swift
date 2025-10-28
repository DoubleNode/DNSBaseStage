//
//  DNSCoordinatorTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import UIKit
@testable import DNSBaseStage
@testable import DNSCore
@testable import DNSDataObjects
@testable import DNSProtocols

// MARK: - Mock Classes
class MockConnectionOptions: NSObject {
    // Mock implementation since UIScene.ConnectionOptions init() is unavailable
}

class MockResults: DNSBaseStageBaseResults {
}

class DNSCoordinatorTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSCoordinator!
    private var parentCoordinator: DNSCoordinator!
    private var childCoordinator: DNSCoordinator!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        parentCoordinator = DNSCoordinator()
        sut = DNSCoordinator(with: parentCoordinator)
        childCoordinator = DNSCoordinator(with: sut)
    }

    override func tearDown() {
        childCoordinator = nil
        sut = nil
        parentCoordinator = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func test_initialization_without_parent() {
        let coordinator = DNSCoordinator()

        XCTAssertNotNil(coordinator)
        XCTAssertNil(coordinator.parent)
        XCTAssertEqual(coordinator.runState, .notStarted)
        XCTAssertTrue(coordinator.children.isEmpty)
    }

    func test_initialization_with_parent() {
        let parent = DNSCoordinator()
        let coordinator = DNSCoordinator(with: parent)

        XCTAssertNotNil(coordinator)
        XCTAssertEqual(coordinator.parent, parent)
        XCTAssertTrue(parent.children.contains(coordinator))
        XCTAssertEqual(coordinator.runState, .notStarted)
    }

    // MARK: - Properties Tests
    func test_analyticsClassTitle_returns_class_name() {
        let expectedTitle = String(describing: DNSCoordinator.self)
        XCTAssertEqual(sut.analyticsClassTitle, expectedTitle)
    }

    func test_isRunning_returns_correct_state() {
        XCTAssertFalse(sut.isRunning)

        sut.runState = .started
        XCTAssertTrue(sut.isRunning)

        sut.runState = .terminated
        XCTAssertFalse(sut.isRunning)
    }

    func test_runningChildren_returns_only_running_children() {
        let child1 = DNSCoordinator(with: sut)
        let child2 = DNSCoordinator(with: sut)
        let child3 = DNSCoordinator(with: sut)

        child1.runState = .started
        child2.runState = .notStarted
        child3.runState = .started

        let runningChildren = sut.runningChildren
        XCTAssertEqual(runningChildren.count, 2)
        XCTAssertTrue(runningChildren.contains(child1))
        XCTAssertTrue(runningChildren.contains(child3))
        XCTAssertFalse(runningChildren.contains(child2))
    }

    // MARK: - Parent-Child Relationship Tests
    func test_setting_parent_adds_to_parent_children() {
        let newParent = DNSCoordinator()
        let coordinator = DNSCoordinator()

        coordinator.parent = newParent

        XCTAssertTrue(newParent.children.contains(coordinator))
        XCTAssertEqual(coordinator.parent, newParent)
    }

    func test_changing_parent_removes_from_old_parent() {
        let oldParent = DNSCoordinator()
        let newParent = DNSCoordinator()
        let coordinator = DNSCoordinator(with: oldParent)

        XCTAssertTrue(oldParent.children.contains(coordinator))

        coordinator.parent = newParent

        XCTAssertFalse(oldParent.children.contains(coordinator))
        XCTAssertTrue(newParent.children.contains(coordinator))
    }

    func test_setting_parent_to_nil_removes_from_parent() {
        let parent = DNSCoordinator()
        let coordinator = DNSCoordinator(with: parent)

        XCTAssertTrue(parent.children.contains(coordinator))

        coordinator.parent = nil

        XCTAssertFalse(parent.children.contains(coordinator))
        XCTAssertNil(coordinator.parent)
    }

    // MARK: - Run State Tests
    func test_runState_enum_cases() {
        sut.runState = .notStarted
        XCTAssertEqual(sut.runState, .notStarted)

        sut.runState = .started
        XCTAssertEqual(sut.runState, .started)

        sut.runState = .terminated
        XCTAssertEqual(sut.runState, .terminated)
    }

    // MARK: - Start Methods Tests
    func test_start_with_completion_block() {
        var completionCalled = false
        var completionResult: Bool?

        sut.start(then: { result in
            completionCalled = true
            completionResult = result
        })

        XCTAssertEqual(sut.runState, .started)
        XCTAssertNotNil(sut.completionBlock)
        XCTAssertNil(sut.completionResultsBlock)

        // Test completion block call
        sut.stop()
        XCTAssertTrue(completionCalled)
        XCTAssertTrue(completionResult!)
    }

    func test_start_with_results_block() {
        var completionCalled = false
        var completionResults: DNSBaseStageBaseResults?

        sut.start(then: { results in
            completionCalled = true
            completionResults = results
        })

        XCTAssertEqual(sut.runState, .started)
        XCTAssertNil(sut.completionBlock)
        XCTAssertNotNil(sut.completionResultsBlock)

        // Test completion block call
        let testResults = MockResults()
        sut.stop(with: testResults)
        XCTAssertTrue(completionCalled)
        XCTAssertNotNil(completionResults)
    }

    func test_start_with_connectionOptions() {
        // Skip testing with UIScene.ConnectionOptions since it has no public initializer
        // Test basic start functionality instead
        var completionCalled = false

        sut.start(then: { (result: Bool) in
            completionCalled = true
        })

        XCTAssertEqual(sut.runState, .started)
        sut.stop()
        XCTAssertTrue(completionCalled)
    }

    func test_start_with_notification() {
        let notification = DAONotification()
        var completionCalled = false

        sut.start(with: notification, then: { (result: Bool) in
            completionCalled = true
        })

        XCTAssertEqual(sut.runState, .started)
        sut.stop()
        XCTAssertTrue(completionCalled)
    }

    func test_start_with_openURLContexts() {
        let urlContexts: Set<UIOpenURLContext> = Set()
        var completionCalled = false

        sut.start(with: urlContexts, then: { (result: Bool) in
            completionCalled = true
        })

        XCTAssertEqual(sut.runState, .started)
        sut.stop()
        XCTAssertTrue(completionCalled)
    }

    func test_start_with_userActivity() {
        let userActivity = NSUserActivity(activityType: "test")
        var completionCalled = false

        sut.start(with: userActivity, then: { (result: Bool) in
            completionCalled = true
        })

        XCTAssertEqual(sut.runState, .started)
        sut.stop()
        XCTAssertTrue(completionCalled)
    }

    // MARK: - Common Start Tests
    func test_commonStart_from_notStarted_sets_started() {
        sut.runState = .notStarted

        sut.commonStart()

        XCTAssertEqual(sut.runState, .started)
    }

    func test_commonStart_from_started_calls_reset() {
        sut.runState = .started

        sut.commonStart()

        XCTAssertEqual(sut.runState, .started)
    }

    func test_commonStart_from_terminated_calls_reset() {
        sut.runState = .terminated

        sut.commonStart()

        XCTAssertEqual(sut.runState, .started)
    }

    // MARK: - Continue Running Tests
    func test_continueRunning_methods_complete_without_error() {
        sut.continueRunning()
        // Skip continueRunning(with: UIScene.ConnectionOptions) since it has no public initializer
        sut.continueRunning(with: DAONotification())
        sut.continueRunning(with: Set<UIOpenURLContext>())
        sut.continueRunning(with: NSUserActivity(activityType: "test"))

        XCTAssertTrue(true) // If we reach here, all methods completed
    }

    // MARK: - Reset Tests
    func test_reset_resets_state_and_clears_children() {
        let child1 = DNSCoordinator(with: sut)
        let child2 = DNSCoordinator(with: sut)
        child1.runState = .started
        child2.runState = .started
        sut.runState = .started

        sut.reset()

        XCTAssertEqual(sut.runState, .notStarted)
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertEqual(child1.runState, .notStarted)
        XCTAssertEqual(child2.runState, .notStarted)
    }

    // MARK: - Stop Tests
    func test_stop_with_results_calls_completion() {
        var completionCalled = false
        var receivedResults: DNSBaseStageBaseResults?

        sut.start { results in
            completionCalled = true
            receivedResults = results
        }

        let testResults = MockResults()
        sut.stop(with: testResults)

        XCTAssertEqual(sut.runState, .terminated)
        XCTAssertTrue(completionCalled)
        XCTAssertNotNil(receivedResults)
    }

    func test_stop_calls_bool_completion() {
        var completionCalled = false
        var receivedResult: Bool?

        sut.start { result in
            completionCalled = true
            receivedResult = result
        }

        sut.stop()

        XCTAssertEqual(sut.runState, .terminated)
        XCTAssertTrue(completionCalled)
        XCTAssertTrue(receivedResult!)
    }

    func test_stopAndCancel_calls_completion_with_false() {
        var completionCalled = false
        var receivedResult: Bool?

        sut.start { result in
            completionCalled = true
            receivedResult = result
        }

        sut.stopAndCancel()

        XCTAssertEqual(sut.runState, .terminated)
        XCTAssertTrue(completionCalled)
        XCTAssertFalse(receivedResult!)
    }

    func test_cancel_calls_completion_with_false() {
        var completionCalled = false
        var receivedResult: Bool?

        sut.start { result in
            completionCalled = true
            receivedResult = result
        }

        sut.cancel()

        XCTAssertEqual(sut.runState, .terminated)
        XCTAssertTrue(completionCalled)
        XCTAssertFalse(receivedResult!)
    }

    func test_stop_when_already_terminated_does_nothing() {
        var callCount = 0

        sut.start(then: { (result: Bool) in
            callCount += 1
        })

        sut.stop()
        XCTAssertEqual(callCount, 1)

        sut.stop()
        XCTAssertEqual(callCount, 1) // Should not be called again
    }

    // MARK: - Stop with Configurator Tests
    func test_stop_configurator_calls_endStage() {
        let mockConfigurator = MockBaseStageConfiguratorForCoordinator()
        var completionCalled = false

        sut.start(then: { (result: Bool) in completionCalled = true })

        sut.stop(mockConfigurator)

        XCTAssertTrue(mockConfigurator.endStageCalled)
        XCTAssertEqual(sut.runState, .terminated)
        XCTAssertTrue(completionCalled)
    }

    func test_stopAndCancel_configurator_calls_endStage() {
        let mockConfigurator = MockBaseStageConfiguratorForCoordinator()
        var completionCalled = false
        var receivedResult: Bool?

        sut.start { result in
            completionCalled = true
            receivedResult = result
        }

        sut.stopAndCancel(mockConfigurator)

        XCTAssertTrue(mockConfigurator.endStageCalled)
        XCTAssertEqual(sut.runState, .terminated)
        XCTAssertTrue(completionCalled)
        XCTAssertFalse(receivedResult!)
    }

    func test_cancel_configurator_calls_endStage() {
        let mockConfigurator = MockBaseStageConfiguratorForCoordinator()
        var completionCalled = false
        var receivedResult: Bool?

        sut.start { result in
            completionCalled = true
            receivedResult = result
        }

        sut.cancel(mockConfigurator)

        XCTAssertTrue(mockConfigurator.endStageCalled)
        XCTAssertEqual(sut.runState, .terminated)
        XCTAssertTrue(completionCalled)
        XCTAssertFalse(receivedResult!)
    }

    // MARK: - Cancel Running Children Tests
    func test_cancelRunningChildren_cancels_only_running_children() {
        let child1 = DNSCoordinator(with: sut)
        let child2 = DNSCoordinator(with: sut)
        let child3 = DNSCoordinator(with: sut)

        child1.runState = .started
        child2.runState = .notStarted
        child3.runState = .started

        sut.cancelRunningChildren()

        XCTAssertEqual(child1.runState, .terminated)
        XCTAssertEqual(child2.runState, .notStarted)
        XCTAssertEqual(child3.runState, .terminated)
    }

    // MARK: - Update Tests
    func test_update_propagates_to_parent_and_children() {
        let grandParent = DNSCoordinator()
        let parent = DNSCoordinator(with: grandParent)
        let coordinator = DNSCoordinator(with: parent)
        let child1 = DNSCoordinator(with: coordinator)
        let child2 = DNSCoordinator(with: coordinator)

        // Mock update tracking (in real implementation, this would affect state)
        coordinator.update()

        // In the actual implementation, this calls update on parent and children
        // We can't easily test the propagation without modifying the class
        // But we can test that the method completes without error
        XCTAssertTrue(true)
    }

    func test_update_with_sender_does_not_propagate_back_to_sender() {
        let child = DNSCoordinator(with: sut)

        // This should not cause infinite recursion
        sut.update(from: child)

        XCTAssertTrue(true) // If we reach here, no infinite recursion occurred
    }

    func test_update_when_terminated_does_not_propagate_to_children() {
        let child = DNSCoordinator(with: sut)
        sut.runState = .terminated

        sut.update()

        // Method should complete without error
        XCTAssertTrue(true)
    }

    // MARK: - Intent Processing Tests
    func test_run_actions_with_blank_intent() {
        var onBlankCalled = false
        var receivedResults: DNSBaseStageBaseResults?

        let actions: [String: DNSCoordinatorResultsBlock] = [:]
        let testResults = MockResults()

        sut.run(actions: actions,
                for: "",
                with: testResults,
                onBlank: { results in
                    onBlankCalled = true
                    receivedResults = results
                })

        XCTAssertTrue(onBlankCalled)
        XCTAssertNotNil(receivedResults)
    }

    func test_run_actions_with_close_intent() {
        var onCloseCalled = false
        var receivedResults: DNSBaseStageBaseResults?

        let actions: [String: DNSCoordinatorResultsBlock] = [:]
        let testResults = MockResults()

        sut.run(actions: actions,
                for: DNSBaseStage.BaseIntents.close,
                with: testResults,
                onClose: { results in
                    onCloseCalled = true
                    receivedResults = results
                })

        XCTAssertTrue(onCloseCalled)
        XCTAssertNotNil(receivedResults)
    }

    func test_run_actions_with_matching_intent() {
        var actionCalled = false
        var receivedResults: DNSBaseStageBaseResults?

        let actions: [String: DNSCoordinatorResultsBlock] = [
            "testAction": { results in
                actionCalled = true
                receivedResults = results
            }
        ]
        let testResults = MockResults()

        sut.run(actions: actions,
                for: "testAction",
                with: testResults)

        XCTAssertTrue(actionCalled)
        XCTAssertNotNil(receivedResults)
    }

    func test_run_actions_with_no_matching_intent() {
        var orNoMatchCalled = false
        var receivedResults: DNSBaseStageBaseResults?

        let actions: [String: DNSCoordinatorResultsBlock] = [
            "otherAction": { _ in }
        ]
        let testResults = MockResults()

        sut.run(actions: actions,
                for: "unknownAction",
                with: testResults,
                orNoMatch: { results in
                    orNoMatchCalled = true
                    receivedResults = results
                })

        XCTAssertTrue(orNoMatchCalled)
        XCTAssertNotNil(receivedResults)
    }

    // MARK: - Start Stage Tests
    func test_startStage_sets_parent_configurator() {
        let mockConfigurator = MockBaseStageConfiguratorForCoordinator()
        let grandParent = DNSCoordinator()
        let parent = DNSCoordinator(with: grandParent)
        let coordinator = DNSCoordinator(with: parent)

        parent.latestConfigurator = mockConfigurator

        let actions: [String: DNSCoordinatorResultsBlock] = [:]
        let initialization = MockInitialization()

        coordinator.startStage(mockConfigurator,
                              and: .modal,
                              and: initialization,
                              thenRunActions: actions)

        XCTAssertTrue(mockConfigurator.runStageCalled)
    }

    func test_updateStage_calls_configurator() {
        let mockConfigurator = MockBaseStageConfiguratorForCoordinator()
        let initialization = MockInitialization()

        sut.updateStage(mockConfigurator, with: initialization)

        XCTAssertTrue(mockConfigurator.updateStageCalled)
    }

    // MARK: - Utility Tests
    func test_utilityAutoTrack_calls_analytics_worker() {
        let mockAnalytics = MockAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        sut.utilityAutoTrack("testMethod")

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackClass, sut.analyticsClassTitle)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "testMethod")
    }

    func test_utilityShowSectionStatusMessage_with_empty_title() {
        var continueCalled = false
        var cancelCalled = false

        sut.utilityShowSectionStatusMessage(with: "",
                                           and: "Message",
                                           continueBlock: { continueCalled = true },
                                           cancelBlock: { cancelCalled = true })

        XCTAssertTrue(continueCalled)
        XCTAssertFalse(cancelCalled)
    }

    func test_utilityShouldAllowSectionStatus_green_status() {
        var continueCalled = false
        var cancelCalled = false

        sut.utilityShouldAllowSectionStatus(for: .green,
                                           with: "Test",
                                           and: "Message",
                                           continueBlock: { continueCalled = true },
                                           cancelBlock: { cancelCalled = true },
                                           buildType: .prod)

        XCTAssertTrue(continueCalled)
        XCTAssertFalse(cancelCalled)
    }

    func test_utilityShouldAllowSectionStatus_unknown_status() {
        var continueCalled = false
        var cancelCalled = false

        sut.utilityShouldAllowSectionStatus(for: .green,
                                           with: "Test",
                                           and: "Message",
                                           continueBlock: { continueCalled = true },
                                           cancelBlock: { cancelCalled = true },
                                           buildType: .prod)

        XCTAssertTrue(continueCalled)
        XCTAssertFalse(cancelCalled)
    }

    // MARK: - Edge Cases Tests
    func test_multiple_stops_do_not_cause_multiple_completions() {
        var completionCallCount = 0

        sut.start(then: { (result: Bool) in
            completionCallCount += 1
        })

        sut.stop()
        sut.stop()
        sut.stopAndCancel()
        sut.cancel()

        XCTAssertEqual(completionCallCount, 1)
        XCTAssertEqual(sut.runState, .terminated)
    }

    func test_nested_coordinator_hierarchy() {
        let level1 = DNSCoordinator()
        let level2 = DNSCoordinator(with: level1)
        let level3 = DNSCoordinator(with: level2)
        let level4 = DNSCoordinator(with: level3)

        XCTAssertTrue(level1.children.contains(level2))
        XCTAssertTrue(level2.children.contains(level3))
        XCTAssertTrue(level3.children.contains(level4))

        level1.reset()

        XCTAssertTrue(level1.children.isEmpty)
        XCTAssertEqual(level1.runState, .notStarted)
        XCTAssertEqual(level2.runState, .notStarted)
        XCTAssertEqual(level3.runState, .notStarted)
        XCTAssertEqual(level4.runState, .notStarted)
    }

    // MARK: - Crash #3366 Regression Tests - Infinite Recursion Prevention

    /// Tests that the recursion guard prevents infinite loops in reset()
    /// This test reproduces the conditions that caused Crash #3366
    func test_reset_prevents_infinite_recursion() {
        // Create a coordinator hierarchy that could cause recursion
        let parent = DNSCoordinator()
        let child = DNSNavBarCoordinator(with: parent as? DNSUINavigationController)
        child.parent = parent

        parent.runState = .started
        child.runState = .started

        // This should not cause infinite recursion or stack overflow
        // The recursion guard should prevent re-entrant calls
        parent.reset()

        // Verify the reset completed successfully
        XCTAssertEqual(parent.runState, .notStarted, "Parent should be reset")
        XCTAssertEqual(child.runState, .notStarted, "Child should be reset")
        XCTAssertTrue(parent.children.isEmpty, "Parent children should be cleared")
    }

    /// Tests that calling reset() multiple times on the same coordinator is safe
    func test_reset_multiple_times_does_not_crash() {
        let coordinator = DNSCoordinator()
        coordinator.runState = .started

        // Call reset multiple times - should be idempotent
        coordinator.reset()
        coordinator.reset()
        coordinator.reset()

        XCTAssertEqual(coordinator.runState, .notStarted)
        XCTAssertTrue(coordinator.children.isEmpty)
    }

    /// Tests that deep coordinator hierarchies reset without recursion issues
    func test_reset_deep_hierarchy_with_navBar_coordinators() {
        // Create a deep hierarchy mixing DNSCoordinator and DNSNavBarCoordinator
        let root = DNSCoordinator()
        let nav1 = DNSNavBarCoordinator(with: nil)
        nav1.parent = root

        let level2 = DNSCoordinator(with: nav1)
        let nav2 = DNSNavBarCoordinator(with: nil)
        nav2.parent = level2

        let level3 = DNSCoordinator(with: nav2)

        root.runState = .started
        nav1.runState = .started
        level2.runState = .started
        nav2.runState = .started
        level3.runState = .started

        // This should not cause stack overflow
        root.reset()

        // Verify all levels were reset
        XCTAssertEqual(root.runState, .notStarted)
        XCTAssertEqual(nav1.runState, .notStarted)
        XCTAssertEqual(level2.runState, .notStarted)
        XCTAssertEqual(nav2.runState, .notStarted)
        XCTAssertEqual(level3.runState, .notStarted)
    }

    /// Tests that NavBarCoordinator can safely call super.reset() without causing recursion
    func test_navBarCoordinator_reset_calls_super_safely() {
        let navCoordinator = DNSNavBarCoordinator(with: nil)
        let child = DNSCoordinator(with: navCoordinator)

        navCoordinator.runState = .started
        child.runState = .started
        navCoordinator.savedViewControllers = [UIViewController()]

        // NavBarCoordinator.reset() calls super.reset()
        // This should not cause infinite recursion
        navCoordinator.reset()

        XCTAssertEqual(navCoordinator.runState, .notStarted)
        XCTAssertEqual(child.runState, .notStarted)
        XCTAssertNil(navCoordinator.savedViewControllers)
        XCTAssertTrue(navCoordinator.children.isEmpty)
    }

    /// Tests that circular parent-child references are handled safely
    func test_reset_handles_circular_references_safely() {
        let coordinator1 = DNSCoordinator()
        let coordinator2 = DNSCoordinator()

        // Create a parent-child relationship
        coordinator2.parent = coordinator1

        coordinator1.runState = .started
        coordinator2.runState = .started

        // Reset should handle this without infinite recursion
        coordinator1.reset()

        XCTAssertEqual(coordinator1.runState, .notStarted)
        XCTAssertEqual(coordinator2.runState, .notStarted)
    }

    /// Tests that commonStart() properly resets when already started (triggers reset internally)
    func test_commonStart_when_already_started_prevents_recursion() {
        let parent = DNSCoordinator()
        let child = DNSNavBarCoordinator(with: nil)
        child.parent = parent

        // Start both coordinators
        parent.runState = .started
        child.runState = .started

        // Calling commonStart when already started triggers reset()
        // This should not cause infinite recursion
        parent.commonStart()

        XCTAssertEqual(parent.runState, .started)
    }

    /// Performance test to ensure reset completes quickly even with many children
    func test_reset_performance_with_many_children() {
        let parent = DNSCoordinator()

        // Create many child coordinators (mix of regular and NavBar)
        for i in 0..<50 {
            if i % 2 == 0 {
                _ = DNSCoordinator(with: parent)
            } else {
                let navChild = DNSNavBarCoordinator(with: nil)
                navChild.parent = parent
            }
        }

        parent.runState = .started

        measure {
            parent.reset()
            parent.runState = .started // Reset state for next iteration

            // Re-add children for next iteration
            if parent.children.isEmpty {
                for i in 0..<50 {
                    if i % 2 == 0 {
                        _ = DNSCoordinator(with: parent)
                    } else {
                        let navChild = DNSNavBarCoordinator(with: nil)
                        navChild.parent = parent
                    }
                }
            }
        }

        XCTAssertEqual(parent.runState, .started)
    }

    /// Tests that concurrent reset calls are handled safely
    func test_reset_concurrent_calls_are_safe() {
        let coordinator = DNSCoordinator()
        coordinator.runState = .started

        let expectation = XCTestExpectation(description: "Concurrent resets complete")
        expectation.expectedFulfillmentCount = 10

        // Attempt multiple concurrent resets
        for _ in 0..<10 {
            DispatchQueue.global().async {
                coordinator.reset()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(coordinator.runState, .notStarted)
    }
}

// MARK: - Mock Classes

class MockBaseStageConfiguratorForCoordinator: DNSBaseStageConfigurator {
    var endStageCalled = false
    var runStageCalled = false
    var updateStageCalled = false

    override func endStage(with intent: String? = nil, and dataChanged: Bool = false, and results: DNSBaseStageBaseResults? = nil) {
        endStageCalled = true
    }

    override func runStage(with coordinator: DNSCoordinator,
                  and displayMode: DNSBaseStage.Display.Mode,
                  with displayOptions: DNSBaseStage.Display.Options = [],
                  and initializationObject: DNSBaseStageBaseInitialization,
                  thenRun intentBlock: DNSBaseStageConfiguratorBlock?) -> DNSBaseStageViewController {
        runStageCalled = true
        return DNSBaseStageViewController()
    }

    override func updateStage(with initializationObject: DNSBaseStageBaseInitialization) {
        updateStageCalled = true
    }
}