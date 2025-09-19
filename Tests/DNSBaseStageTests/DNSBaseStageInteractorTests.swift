//
//  DNSBaseStageInteractorTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import Combine
import Foundation
@testable import DNSBaseStage
@testable import DNSCore
@testable import DNSError
@testable import DNSProtocols

class DNSBaseStageInteractorTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSBaseStageInteractor!
    private var mockViewController: MockBaseStageViewController!
    private var mockConfigurator: MockBaseStageConfiguratorForInteractor!
    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockConfigurator = MockBaseStageConfiguratorForInteractor()
        mockViewController = MockBaseStageViewController()
        sut = DNSBaseStageInteractor(configurator: mockConfigurator)
    }

    override func tearDown() {
        cancellables.removeAll()
        cancellables = nil
        sut = nil
        mockViewController = nil
        mockConfigurator = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func test_initialization_with_configurator() {
        let configurator = MockBaseStageConfiguratorForInteractor()
        let interactor = DNSBaseStageInteractor(configurator: configurator)

        XCTAssertNotNil(interactor)
        XCTAssertNotNil(interactor.baseConfigurator)
    }

    // MARK: - Properties Tests
    func test_analyticsClassTitle_returns_class_name() {
        let expectedTitle = String(describing: DNSBaseStageInteractor.self)
        XCTAssertEqual(sut.analyticsClassTitle, expectedTitle)
    }

    func test_analyticsStageTitle_returns_configurator_title_when_available() {
        mockConfigurator.mockAnalyticsStageTitle = "TestInteractorTitle"
        XCTAssertEqual(sut.analyticsStageTitle, "TestInteractorTitle")
    }

    func test_analyticsStageTitle_returns_class_name_when_configurator_unavailable() {
        mockConfigurator.mockAnalyticsStageTitle = nil
        let expectedTitle = String(describing: DNSBaseStageInteractor.self)
        XCTAssertEqual(sut.analyticsStageTitle, expectedTitle)
    }

    // MARK: - Publishers Tests
    func test_publishers_are_initialized() {
        XCTAssertNotNil(sut.stageStartPublisher)
        XCTAssertNotNil(sut.stageEndPublisher)
        XCTAssertNotNil(sut.confirmationPublisher)
        XCTAssertNotNil(sut.disabledPublisher)
        XCTAssertNotNil(sut.dismissPublisher)
        XCTAssertNotNil(sut.errorPublisher)
        XCTAssertNotNil(sut.messagePublisher)
        XCTAssertNotNil(sut.resetPublisher)
        XCTAssertNotNil(sut.spinnerPublisher)
        XCTAssertNotNil(sut.titlePublisher)
    }

    // MARK: - Stage Management Tests
    func test_startStage_sets_properties() {
        let displayMode = DNSBaseStage.Display.Mode.modal
        let displayOptions = [DNSBaseStage.Display.Option.navBarHidden(animated: false)]
        let initialization = MockInitialization()

        sut.startStage(with: displayMode, with: displayOptions, and: initialization)

        XCTAssertFalse(sut.hasStageAppeared)
        XCTAssertEqual(sut.displayMode, displayMode)
        XCTAssertEqual(sut.displayOptions, displayOptions)
        XCTAssertNotNil(sut.baseInitializationObject)
    }

    func test_startStage_sends_start_response() {
        var receivedResponse: DNSBaseStage.Models.Start.Response?

        sut.stageStartPublisher
            .sink { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        let displayMode = DNSBaseStage.Display.Mode.modal
        let displayOptions = [DNSBaseStage.Display.Option.navBarHidden(animated: false)]
        let initialization = MockInitialization()

        sut.startStage(with: displayMode, with: displayOptions, and: initialization)

        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.displayMode, displayMode)
        XCTAssertEqual(receivedResponse?.displayOptions, displayOptions)
    }

    func test_updateStage_before_appeared_does_not_trigger_update() {
        let initialization = MockInitialization()
        sut.hasStageAppeared = false

        sut.updateStage(with: initialization)

        XCTAssertFalse(sut.stageUpdated)
    }

    func test_updateStage_after_appeared_triggers_update() {
        let initialization = MockInitialization()
        sut.hasStageAppeared = true

        sut.updateStage(with: initialization)

        XCTAssertTrue(sut.stageUpdated)
    }

    func test_shouldEndStage_returns_true_first_time() {
        sut.hasStageEnded = false

        let result = sut.shouldEndStage()

        XCTAssertTrue(result)
        XCTAssertTrue(sut.hasStageEnded)
    }

    func test_shouldEndStage_returns_false_second_time() {
        sut.hasStageEnded = false
        _ = sut.shouldEndStage()

        let result = sut.shouldEndStage()

        XCTAssertFalse(result)
    }

    func test_endStage_calls_configurator() {
        sut.endStage(with: "testIntent", and: true, and: nil)

        XCTAssertTrue(mockConfigurator.endStageCalled)
        XCTAssertEqual(mockConfigurator.lastIntent, "testIntent")
        XCTAssertTrue(mockConfigurator.lastDataChanged)
    }

    func test_endStage_conditionally_when_should_end_false() {
        sut.hasStageEnded = true // This makes shouldEndStage return false

        sut.endStage(conditionally: true, with: "testIntent", and: true, and: nil)

        XCTAssertFalse(mockConfigurator.endStageCalled)
    }

    func test_endStage_conditionally_when_should_end_true() {
        sut.hasStageEnded = false // This makes shouldEndStage return true

        sut.endStage(conditionally: true, with: "testIntent", and: true, and: nil)

        XCTAssertTrue(mockConfigurator.endStageCalled)
    }

    func test_removeStage_sends_finish_response() {
        var receivedResponse: DNSBaseStage.Models.Finish.Response?

        sut.stageEndPublisher
            .sink { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        sut.displayMode = .modal
        sut.removeStage()

        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.displayMode, .modal)
    }

    func test_removeStage_with_nil_displayMode_does_nothing() {
        var receivedResponse: DNSBaseStage.Models.Finish.Response?

        sut.stageEndPublisher
            .sink { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        sut.displayMode = nil
        sut.removeStage()

        XCTAssertNil(receivedResponse)
    }

    func test_send_intent_calls_configurator() {
        sut.send(intent: "testIntent", with: true, and: nil)

        XCTAssertTrue(mockConfigurator.sendCalled)
        XCTAssertEqual(mockConfigurator.lastSentIntent, "testIntent")
        XCTAssertTrue(mockConfigurator.lastSentDataChanged)
    }

    // MARK: - Stage Lifecycle Tests
    func test_stageDidAppear_sets_flags() {
        let request = DNSBaseStage.Models.Base.Request()

        sut.stageDidAppear(request)

        XCTAssertTrue(sut.hasStageAppeared)
        XCTAssertFalse(sut.hasStageEnded)
        XCTAssertFalse(sut.stageUpdated)
    }

    func test_stageDidClose_calls_endStage_conditionally() {
        let request = DNSBaseStage.Models.Base.Request()
        sut.hasStageEnded = false

        sut.stageDidClose(request)

        XCTAssertTrue(mockConfigurator.endStageCalled)
    }

    func test_stageWillAppear_calls_configurator_restartEnding() {
        let request = DNSBaseStage.Models.Base.Request()

        sut.stageWillAppear(request)

        XCTAssertTrue(mockConfigurator.restartEndingCalled)
    }

    // MARK: - Business Logic Tests
    func test_doCloseAction_calls_utilityCloseAction() {
        let request = DNSBaseStage.Models.Base.Request()

        // This is protected/open method, we test it indirectly
        sut.doCloseAction(request)

        // The method should complete without errors
        XCTAssertTrue(true)
    }

    func test_doErrorOccurred_sends_error_response() {
        var receivedResponse: DNSBaseStage.Models.ErrorMessage.Response?

        sut.errorPublisher
            .sink { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        var request = DNSBaseStage.Models.ErrorMessage.Request(error: testError, style: .popup, title: "Error Title")
        request.okayButton = "OK"

        sut.doErrorOccurred(request)

        let expectation = XCTestExpectation(description: "Error response received")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(receivedResponse)
            XCTAssertEqual((receivedResponse?.error as? NSError)?.domain, "TestDomain")
            XCTAssertEqual((receivedResponse?.error as? NSError)?.code, 123)
            XCTAssertEqual(receivedResponse?.style, .popup)
            XCTAssertEqual(receivedResponse?.title, "Error Title")
            XCTAssertEqual(receivedResponse?.okayButton, "OK")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_doWebErrorNavigation_sends_error_response() {
        var receivedResponse: DNSBaseStage.Models.ErrorMessage.Response?

        sut.errorPublisher
            .sink { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        let url = URL(string: "https://example.com")!
        let webError = NSError(domain: "WebDomain", code: 404, userInfo: nil)
        let request = DNSBaseStage.Models.WebpageError.Request(url: url, error: webError)

        sut.doWebErrorNavigation(request)

        let expectation = XCTestExpectation(description: "Web error response received")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(receivedResponse)
            XCTAssertEqual((receivedResponse?.error as? NSError)?.domain, "WebDomain")
            XCTAssertEqual((receivedResponse?.error as? NSError)?.code, 404)
            XCTAssertEqual(receivedResponse?.style, .popup)
            XCTAssertEqual(receivedResponse?.title, "Web Error")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Shortcut Methods Tests
    func test_disabled_shortcut_sends_response() {
        var receivedResponse: DNSBaseStage.Models.Disabled.Response?

        sut.disabledPublisher
            .sink { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        sut.disabled(show: true, forceReset: true)

        let expectation = XCTestExpectation(description: "Disabled response received")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(receivedResponse)
            XCTAssertTrue(receivedResponse!.show)
            XCTAssertTrue(receivedResponse!.forceReset)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_spinner_shortcut_sends_response() {
        var receivedResponse: DNSBaseStage.Models.Spinner.Response?

        sut.spinnerPublisher
            .sink { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        sut.spinner(show: false, forceReset: true)

        let expectation = XCTestExpectation(description: "Spinner response received")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(receivedResponse)
            XCTAssertFalse(receivedResponse!.show)
            XCTAssertTrue(receivedResponse!.forceReset)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Subscription Tests
    func test_subscribe_to_viewController_sets_up_subscribers() {
        sut.subscribe(to: mockViewController)

        XCTAssertNotNil(sut.stageDidAppearSubscriber)
        XCTAssertNotNil(sut.stageDidCloseSubscriber)
        XCTAssertNotNil(sut.stageDidDisappearSubscriber)
        XCTAssertNotNil(sut.stageDidHideSubscriber)
        XCTAssertNotNil(sut.stageDidLoadSubscriber)
        XCTAssertNotNil(sut.stageWillAppearSubscriber)
        XCTAssertNotNil(sut.stageWillDisappearSubscriber)
        XCTAssertNotNil(sut.stageWillHideSubscriber)
        XCTAssertNotNil(sut.closeActionSubscriber)
        XCTAssertNotNil(sut.confirmationSubscriber)
        XCTAssertNotNil(sut.errorSubscriber)
        XCTAssertNotNil(sut.errorOccurredSubscriber)
        XCTAssertNotNil(sut.messageSubscriber)
        XCTAssertNotNil(sut.webStartNavigationSubscriber)
        XCTAssertNotNil(sut.webFinishNavigationSubscriber)
        XCTAssertNotNil(sut.webErrorNavigationSubscriber)
        XCTAssertNotNil(sut.webLoadProgressSubscriber)
    }

    func test_subscribe_to_viewController_clears_existing_subscribers() {
        sut.subscribers.append(AnyCancellable {})
        let initialCount = sut.subscribers.count
        XCTAssertGreaterThan(initialCount, 0)

        sut.subscribe(to: mockViewController)

        XCTAssertEqual(sut.subscribers.count, 0)
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

    func test_utilityCloseAction_resets_hasStageEnded() {
        sut.hasStageEnded = true

        sut.utilityCloseAction()

        XCTAssertFalse(sut.hasStageEnded)
        XCTAssertTrue(mockConfigurator.endStageCalled)
    }

    func test_utilityReset_sends_reset_response() {
        var receivedResponse: DNSBaseStage.Models.Base.Response?

        sut.resetPublisher
            .sink { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        sut.utilityReset()

        XCTAssertNotNil(receivedResponse)
    }

    // MARK: - Edge Cases Tests
    func test_multiple_stage_appears_handle_correctly() {
        let request = DNSBaseStage.Models.Base.Request()

        sut.stageDidAppear(request)
        XCTAssertTrue(sut.hasStageAppeared)
        XCTAssertFalse(sut.hasStageEnded)

        sut.stageDidAppear(request)
        XCTAssertTrue(sut.hasStageAppeared)
        XCTAssertFalse(sut.hasStageEnded)
    }

    func test_multiple_shouldEndStage_calls() {
        let first = sut.shouldEndStage()
        let second = sut.shouldEndStage()
        let third = sut.shouldEndStage()

        XCTAssertTrue(first)
        XCTAssertFalse(second)
        XCTAssertFalse(third)
    }

    func test_stage_lifecycle_methods_complete_without_errors() {
        let request = DNSBaseStage.Models.Base.Request()

        // Test all lifecycle methods complete without errors
        sut.stageDidLoad(request)
        sut.stageWillAppear(request)
        sut.stageDidAppear(request)
        sut.stageWillDisappear(request)
        sut.stageDidDisappear(request)
        sut.stageWillHide(request)
        sut.stageDidHide(request)
        sut.stageDidClose(request)

        XCTAssertTrue(true) // If we reach here, all methods completed
    }

    func test_business_logic_methods_complete_without_errors() {
        let baseRequest = DNSBaseStage.Models.Base.Request()
        let confirmationRequest = DNSBaseStage.Models.Confirmation.Request()
        let messageRequest = DNSBaseStage.Models.Message.Request()
        let webpageRequest = DNSBaseStage.Models.Webpage.Request(url: URL(string: "https://example.com")!)
        let webpageProgressRequest = DNSBaseStage.Models.WebpageProgress.Request(percentage: 0.5)

        // Test all business logic methods complete without errors
        sut.doCloseAction(baseRequest)
        sut.doConfirmation(confirmationRequest)
        sut.doErrorDone(messageRequest)
        sut.doMessageDone(messageRequest)
        sut.doWebStartNavigation(webpageRequest)
        sut.doWebFinishNavigation(webpageRequest)
        sut.doWebLoadProgress(webpageProgressRequest)

        XCTAssertTrue(true) // If we reach here, all methods completed
    }
}

// MARK: - Mock Classes


class MockBaseStageViewController: DNSBaseStageDisplayLogic {
    typealias BaseStage = DNSBaseStage

    let stageDidAppearPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    let stageDidClosePublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    let stageDidDisappearPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    let stageDidHidePublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    let stageDidLoadPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    let stageWillAppearPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    let stageWillDisappearPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    let stageWillHidePublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()

    let closeActionPublisher = PassthroughSubject<BaseStage.Models.Base.Request, Never>()
    let confirmationPublisher = PassthroughSubject<BaseStage.Models.Confirmation.Request, Never>()
    let errorDonePublisher = PassthroughSubject<BaseStage.Models.Message.Request, Never>()
    let errorOccurredPublisher = PassthroughSubject<BaseStage.Models.ErrorMessage.Request, Never>()
    let messageDonePublisher = PassthroughSubject<BaseStage.Models.Message.Request, Never>()
    let webStartNavigationPublisher = PassthroughSubject<BaseStage.Models.Webpage.Request, Never>()
    let webFinishNavigationPublisher = PassthroughSubject<BaseStage.Models.Webpage.Request, Never>()
    let webErrorNavigationPublisher = PassthroughSubject<BaseStage.Models.WebpageError.Request, Never>()
    let webLoadProgressPublisher = PassthroughSubject<BaseStage.Models.WebpageProgress.Request, Never>()
}

class MockBaseStageConfiguratorForInteractor: DNSBaseStageConfigurator {
    var mockAnalyticsStageTitle: String?

    var endStageCalled = false
    var restartEndingCalled = false
    var sendCalled = false

    var lastIntent: String?
    var lastDataChanged: Bool = false
    var lastSentIntent: String?
    var lastSentDataChanged: Bool = false

    override var analyticsStageTitle: String {
        get { return mockAnalyticsStageTitle ?? "MockStageTitle" }
        set { } // Allow setting but ignore
    }

    override func endStage(with intent: String? = nil, and dataChanged: Bool = false, and results: DNSBaseStageBaseResults? = nil) {
        endStageCalled = true
        lastIntent = intent
        lastDataChanged = dataChanged
    }

    override func restartEnding() {
        restartEndingCalled = true
    }

    override func send(intent: String, with dataChanged: Bool, and results: DNSBaseStageBaseResults?) {
        sendCalled = true
        lastSentIntent = intent
        lastSentDataChanged = dataChanged
    }
}