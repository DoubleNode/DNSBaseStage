//
//  DNSBaseStageConfiguratorTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import UIKit
import JKDrawer
@testable import DNSBaseStage
@testable import DNSCore
@testable import DNSProtocols
@testable import DNSCrashWorkers

class DNSBaseStageConfiguratorTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSBaseStageConfigurator!
    private var mockCoordinator: MockCoordinator!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = DNSBaseStageConfigurator()
        mockCoordinator = MockCoordinator()
    }

    override func tearDown() {
        sut = nil
        mockCoordinator = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func test_initialization() {
        let configurator = DNSBaseStageConfigurator()

        XCTAssertNotNil(configurator)
        XCTAssertFalse(configurator.started)
        XCTAssertFalse(configurator.ending)
        XCTAssertNil(configurator.initializationObject)
        XCTAssertNil(configurator.parentConfigurator)
        XCTAssertNil(configurator.coordinator)
        XCTAssertNil(configurator.intentBlock)
    }

    // MARK: - Properties Tests
    func test_analyticsStageTitle_returns_class_description() {
        let expectedTitle = String(describing: sut)
        XCTAssertEqual(sut.analyticsStageTitle, expectedTitle)
    }

    func test_type_properties_return_correct_types() {
        XCTAssertTrue(sut.interactorType == DNSBaseStageInteractor.self)
        XCTAssertTrue(sut.presenterType == DNSBaseStagePresenter.self)
        XCTAssertTrue(sut.viewControllerType == DNSBaseStageViewController.self)
    }

    func test_isRunning_returns_correct_state() {
        XCTAssertFalse(sut.isRunning)

        sut.started = true
        XCTAssertTrue(sut.isRunning)

        sut.ending = true
        XCTAssertFalse(sut.isRunning)

        sut.started = false
        sut.ending = false
        XCTAssertFalse(sut.isRunning)
    }

    // MARK: - VIP Object Creation Tests
    func test_baseInteractor_lazy_creation() {
        let interactor = sut.baseInteractor

        XCTAssertNotNil(interactor)
        XCTAssertTrue(interactor is DNSBaseStageInteractor)
        XCTAssertNotNil(interactor.baseConfigurator)
    }

    func test_basePresenter_lazy_creation() {
        let presenter = sut.basePresenter

        XCTAssertNotNil(presenter)
        XCTAssertTrue(presenter is DNSBaseStagePresenter)
        XCTAssertNotNil(presenter.baseConfigurator)
    }

    func test_baseViewController_lazy_creation() {
        let viewController = sut.baseViewController

        XCTAssertNotNil(viewController)
        XCTAssertTrue(viewController is DNSBaseStageViewController)
    }

    func test_vip_objects_are_same_instance_on_multiple_access() {
        let interactor1 = sut.baseInteractor
        let interactor2 = sut.baseInteractor

        let presenter1 = sut.basePresenter
        let presenter2 = sut.basePresenter

        let viewController1 = sut.baseViewController
        let viewController2 = sut.baseViewController

        XCTAssertTrue(interactor1 === interactor2)
        XCTAssertTrue(presenter1 === presenter2)
        XCTAssertTrue(viewController1 === viewController2)
    }

    // MARK: - Configuration Tests
    func test_configureStage_sets_up_vip_connections() {
        sut.configureStage()

        // Check that VIP objects are created and connected
        XCTAssertNotNil(sut.baseInteractor)
        XCTAssertNotNil(sut.basePresenter)
        XCTAssertNotNil(sut.baseViewController)

        // Check that subscribers are set up (indirect test)
        XCTAssertNotNil(sut.baseViewController.stageStartSubscriber)
        XCTAssertNotNil(sut.basePresenter.stageStartSubscriber)
        XCTAssertNotNil(sut.baseInteractor.stageDidAppearSubscriber)
    }

    func test_configureStage_sets_defaults() {
        sut.configureStage()

        // Test that defaults are reset
        XCTAssertNotNil(DNSBaseStageModels.defaults)
    }

    func test_configureStage_injects_analytics_workers() {
        sut.configureStage()

        XCTAssertNotNil(sut.baseInteractor.wkrAnalytics)
        XCTAssertNotNil(sut.basePresenter.wkrAnalytics)
        XCTAssertNotNil(sut.baseViewController.wkrAnalytics)

        XCTAssertTrue(sut.baseInteractor.wkrAnalytics is WKRCrashAnalytics)
        XCTAssertTrue(sut.basePresenter.wkrAnalytics is WKRCrashAnalytics)
        XCTAssertTrue(sut.baseViewController.wkrAnalytics is WKRCrashAnalytics)
    }

    // MARK: - Stage Lifecycle Tests
    func test_runStage_sets_properties() {
        let initialization = MockInitialization()
        let displayMode = DNSBaseStage.Display.Mode.modal
        let displayOptions: DNSBaseStage.Display.Options = [.navBarHidden(animated: false)]
        var intentBlockCalled = false

        let viewController = sut.runStage(with: mockCoordinator,
                                         and: displayMode,
                                         with: displayOptions,
                                         and: initialization) { _, _, _, _ in
            intentBlockCalled = true
        }

        XCTAssertNotNil(viewController)
        XCTAssertTrue(sut.started)
        XCTAssertFalse(sut.ending)
        XCTAssertNotNil(sut.coordinator)
        XCTAssertNotNil(sut.intentBlock)
        XCTAssertNotNil(sut.initializationObject)
        XCTAssertNotNil(sut.rootViewController)
        XCTAssertNotNil(viewController.baseConfigurator)
        XCTAssertFalse(viewController.stageTitle.isEmpty)
    }

    func test_runStage_calls_restartEnding() {
        let initialization = MockInitialization()

        sut.ending = true
        _ = sut.runStage(with: mockCoordinator,
                        and: .modal,
                        and: initialization) { _, _, _, _ in }

        XCTAssertFalse(sut.ending)
    }

    func test_updateStage_calls_interactor() {
        let initialization = MockInitialization()

        // First run the stage to initialize
        _ = sut.runStage(with: mockCoordinator,
                        and: .modal,
                        and: initialization) { _, _, _, _ in }

        let newInitialization = MockInitialization()
        sut.updateStage(with: newInitialization)

        XCTAssertNotNil(sut.initializationObject)
    }

    func test_endStage_sets_ending_flag() {
        sut.ending = false

        sut.endStage()

        XCTAssertTrue(sut.ending)
    }

    func test_endStage_calls_intentBlock_after_delay() {
        var intentBlockCalled = false
        var receivedEnd = false
        var receivedIntent: String?

        sut.intentBlock = { end, intent, _, _ in
            intentBlockCalled = true
            receivedEnd = end
            receivedIntent = intent
        }

        sut.endStage(with: "testIntent")

        let expectation = XCTestExpectation(description: "Intent block called after delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertTrue(intentBlockCalled)
            XCTAssertTrue(receivedEnd)
            XCTAssertEqual(receivedIntent, "testIntent")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_endStage_when_already_ending_does_nothing() {
        var intentBlockCallCount = 0

        sut.intentBlock = { _, _, _, _ in
            intentBlockCallCount += 1
        }

        sut.ending = true
        sut.endStage()
        sut.endStage()

        let expectation = XCTestExpectation(description: "Intent block not called multiple times")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(intentBlockCallCount, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_restartEnding_resets_ending_flag() {
        sut.ending = true

        sut.restartEnding()

        XCTAssertFalse(sut.ending)
    }

    func test_send_calls_intentBlock() {
        var intentBlockCalled = false
        var receivedEnd = false
        var receivedIntent: String?
        var receivedDataChanged = false

        sut.intentBlock = { end, intent, dataChanged, _ in
            intentBlockCalled = true
            receivedEnd = end
            receivedIntent = intent
            receivedDataChanged = dataChanged
        }

        sut.send(intent: "testIntent", with: true, and: nil)

        XCTAssertTrue(intentBlockCalled)
        XCTAssertFalse(receivedEnd)
        XCTAssertEqual(receivedIntent, "testIntent")
        XCTAssertTrue(receivedDataChanged)
    }

    // MARK: - Navigation Controller Properties Tests
    func test_navigation_properties_can_be_set() {
        let navController = DNSUINavigationController()
        let tabBarController = DNSUITabBarController()
        let navDrawerController = DNSUINavDrawerController(rootViewController: UIViewController(), configuration: JKDrawer.DrawerConfiguration(gravity: .bottom, offset: 100))

        sut.navigationController = navController
        sut.tabBarController = tabBarController
        sut.navDrawerController = navDrawerController

        XCTAssertEqual(sut.navigationController, navController)
        XCTAssertEqual(sut.tabBarController, tabBarController)
        XCTAssertEqual(sut.navDrawerController, navDrawerController)
    }

    func test_parent_configurator_can_be_set() {
        let parentConfigurator = DNSBaseStageConfigurator()

        sut.parentConfigurator = parentConfigurator

        XCTAssertTrue(sut.parentConfigurator === parentConfigurator)
    }

    func test_root_viewController_can_be_set() {
        let rootViewController = DNSBaseStageViewController()

        sut.rootViewController = rootViewController

        XCTAssertEqual(sut.rootViewController, rootViewController)
    }

    // MARK: - Intent Block Tests
    func test_intentBlock_type_matches_expected() {
        let intentBlock: DNSBaseStageConfiguratorBlock = { end, intent, dataChanged, results in
            // Test block
        }

        sut.intentBlock = intentBlock

        XCTAssertNotNil(sut.intentBlock)
    }

    // MARK: - Edge Cases Tests
    func test_multiple_configureStage_calls_work_correctly() {
        sut.configureStage()
        let firstInteractor = sut.baseInteractor

        sut.configureStage()
        let secondInteractor = sut.baseInteractor

        // Should be the same instance since lazy properties
        XCTAssertTrue(firstInteractor === secondInteractor)
    }

    func test_runStage_without_intentBlock() {
        let initialization = MockInitialization()

        let viewController = sut.runStage(with: mockCoordinator,
                                         and: .modal,
                                         and: initialization,
                                         thenRun: nil)

        XCTAssertNotNil(viewController)
        XCTAssertNil(sut.intentBlock)
    }

    func test_endStage_without_intentBlock() {
        sut.intentBlock = nil

        sut.endStage(with: "testIntent")

        let expectation = XCTestExpectation(description: "No crash without intent block")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Should complete without error
            XCTAssertTrue(true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_send_without_intentBlock() {
        sut.intentBlock = nil

        sut.send(intent: "testIntent", with: true, and: nil)

        // Should complete without error
        XCTAssertTrue(true)
    }

    func test_endStage_with_nil_intent() {
        var intentBlockCalled = false

        sut.intentBlock = { _, _, _, _ in
            intentBlockCalled = true
        }

        sut.endStage(with: nil)

        let expectation = XCTestExpectation(description: "Intent block not called with nil intent")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertFalse(intentBlockCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Complex Scenario Tests
    func test_full_stage_lifecycle() {
        let initialization = MockInitialization()
        var stageEndedWithIntent: String?
        var stageEndedWithDataChanged: Bool?

        // Start stage
        let viewController = sut.runStage(with: mockCoordinator,
                                         and: .modal,
                                         and: initialization) { end, intent, dataChanged, _ in
            if end {
                stageEndedWithIntent = intent
                stageEndedWithDataChanged = dataChanged
            }
        }

        XCTAssertNotNil(viewController)
        XCTAssertTrue(sut.started)
        XCTAssertFalse(sut.ending)

        // Update stage
        let newInitialization = MockInitialization()
        sut.updateStage(with: newInitialization)

        // Send intent
        sut.send(intent: "intermediateIntent", with: false, and: nil)

        // End stage
        sut.endStage(with: "finalIntent", and: true, and: nil)

        let expectation = XCTestExpectation(description: "Full lifecycle completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(stageEndedWithIntent, "finalIntent")
            XCTAssertTrue(stageEndedWithDataChanged!)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_concurrent_endStage_calls() {
        var intentBlockCallCount = 0

        sut.intentBlock = { _, _, _, _ in
            intentBlockCallCount += 1
        }

        // Multiple concurrent calls should only result in one callback
        DispatchQueue.global().async {
            self.sut.endStage(with: "intent1")
        }
        DispatchQueue.global().async {
            self.sut.endStage(with: "intent2")
        }
        DispatchQueue.global().async {
            self.sut.endStage(with: "intent3")
        }

        let expectation = XCTestExpectation(description: "Only one intent block called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(intentBlockCallCount, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Mock Classes

class MockCoordinator: DNSCoordinator {
    override init(with parent: DNSCoordinator? = nil) {
        super.init(with: parent)
        self.defaultRootViewController = DNSBaseStageViewController()
    }
}

class MockInitialization: DNSBaseStageBaseInitialization {
    // Empty implementation for testing
}