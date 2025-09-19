//
//  DNSBaseStageViewControllerTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import Combine
import UIKit
@testable import DNSBaseStage
@testable import DNSCore
@testable import DNSError
@testable import DNSProtocols

class DNSBaseStageViewControllerTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSBaseStageViewController!
    private var mockPresenter: MockBaseStagePresenter!
    private var mockConfigurator: MockBaseStageConfigurator!
    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockPresenter = MockBaseStagePresenter()
        mockConfigurator = MockBaseStageConfigurator()
        sut = DNSBaseStageViewController()
        sut.baseConfigurator = mockConfigurator
    }

    override func tearDown() {
        cancellables.removeAll()
        cancellables = nil
        sut = nil
        mockPresenter = nil
        mockConfigurator = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func test_initialization_with_nibName() {
        let viewController = DNSBaseStageViewController(nibName: "TestNib", bundle: nil)
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController.nibName, "TestNib")
    }

    func test_initialization_with_coder() {
        let coder = NSCoder()
        let viewController = DNSBaseStageViewController(coder: coder)
        XCTAssertNil(viewController) // Expected to be nil for DNSBaseStageViewController
    }

    // MARK: - Properties Tests
    func test_analyticsClassTitle_returns_class_name() {
        let expectedTitle = String(describing: DNSBaseStageViewController.self)
        XCTAssertEqual(sut.analyticsClassTitle, expectedTitle)
    }

    func test_analyticsStageTitle_returns_configurator_title_when_available() {
        mockConfigurator.mockAnalyticsStageTitle = "TestStageTitle"
        XCTAssertEqual(sut.analyticsStageTitle, "TestStageTitle")
    }

    func test_analyticsStageTitle_returns_class_name_when_configurator_unavailable() {
        sut.baseConfigurator = nil
        let expectedTitle = String(describing: DNSBaseStageViewController.self)
        XCTAssertEqual(sut.analyticsStageTitle, expectedTitle)
    }

    func test_stageTitle_setting_updates_title_properties() {
        let testTitle = "Test Stage Title"
        sut.stageTitle = testTitle

        XCTAssertEqual(sut.stageTitle, testTitle)
        // Note: UI updates are tested in UI-specific tests
    }

    func test_stageTitle_setting_updates_stageBackTitle_when_empty() {
        let testTitle = "Test Stage Title"
        sut.stageTitle = testTitle

        XCTAssertEqual(sut.stageBackTitle, testTitle)
    }

    // MARK: - Display Logic Publisher Tests
    func test_publishers_are_initialized() {
        XCTAssertNotNil(sut.stageDidAppearPublisher)
        XCTAssertNotNil(sut.stageDidClosePublisher)
        XCTAssertNotNil(sut.stageDidDisappearPublisher)
        XCTAssertNotNil(sut.stageDidHidePublisher)
        XCTAssertNotNil(sut.stageDidLoadPublisher)
        XCTAssertNotNil(sut.stageWillAppearPublisher)
        XCTAssertNotNil(sut.stageWillDisappearPublisher)
        XCTAssertNotNil(sut.stageWillHidePublisher)
        XCTAssertNotNil(sut.closeActionPublisher)
        XCTAssertNotNil(sut.confirmationPublisher)
        XCTAssertNotNil(sut.errorDonePublisher)
        XCTAssertNotNil(sut.errorOccurredPublisher)
        XCTAssertNotNil(sut.messageDonePublisher)
        XCTAssertNotNil(sut.webStartNavigationPublisher)
        XCTAssertNotNil(sut.webFinishNavigationPublisher)
        XCTAssertNotNil(sut.webErrorNavigationPublisher)
        XCTAssertNotNil(sut.webLoadProgressPublisher)
    }

    // MARK: - Stage Lifecycle Tests
    func test_stageDidLoad_sends_publisher_event() {
        var receivedRequest: DNSBaseStage.Models.Base.Request?

        sut.stageDidLoadPublisher
            .sink { request in
                receivedRequest = request
            }
            .store(in: &cancellables)

        sut.stageDidLoad()

        XCTAssertNotNil(receivedRequest)
    }

    func test_stageWillAppear_sends_publisher_event() {
        var receivedRequest: DNSBaseStage.Models.Base.Request?

        sut.stageWillAppearPublisher
            .sink { request in
                receivedRequest = request
            }
            .store(in: &cancellables)

        sut.stageWillAppear()

        XCTAssertNotNil(receivedRequest)
    }

    func test_stageDidAppear_sends_publisher_event() {
        var receivedRequest: DNSBaseStage.Models.Base.Request?

        sut.stageDidAppearPublisher
            .sink { request in
                receivedRequest = request
            }
            .store(in: &cancellables)

        sut.stageDidAppear()

        XCTAssertNotNil(receivedRequest)
    }

    func test_stageWillDisappear_sends_publisher_event() {
        var receivedRequest: DNSBaseStage.Models.Base.Request?

        sut.stageWillDisappearPublisher
            .sink { request in
                receivedRequest = request
            }
            .store(in: &cancellables)

        sut.stageWillDisappear()

        XCTAssertNotNil(receivedRequest)
    }

    func test_stageDidDisappear_sends_publisher_event() {
        var receivedRequest: DNSBaseStage.Models.Base.Request?

        sut.stageDidDisappearPublisher
            .sink { request in
                receivedRequest = request
            }
            .store(in: &cancellables)

        sut.stageDidDisappear()

        XCTAssertNotNil(receivedRequest)
    }

    func test_stageDidHide_sends_publisher_event() {
        var receivedRequest: DNSBaseStage.Models.Base.Request?

        sut.stageDidHidePublisher
            .sink { request in
                receivedRequest = request
            }
            .store(in: &cancellables)

        sut.stageDidHide()

        XCTAssertNotNil(receivedRequest)
    }

    func test_stageDidClose_sends_publisher_event() {
        var receivedRequest: DNSBaseStage.Models.Base.Request?

        sut.stageDidClosePublisher
            .sink { request in
                receivedRequest = request
            }
            .store(in: &cancellables)

        sut.stageDidClose()

        XCTAssertNotNil(receivedRequest)
    }

    // MARK: - Action Tests
    func test_closeButtonAction_sends_publisher_event() {
        var receivedRequest: DNSBaseStage.Models.Base.Request?

        sut.closeActionPublisher
            .sink { request in
                receivedRequest = request
            }
            .store(in: &cancellables)

        let mockButton = UIButton()
        sut.closeButtonAction(sender: mockButton)

        XCTAssertNotNil(receivedRequest)
    }

    func test_closeButtonAction_disables_close_button_when_sender_is_close_button() {
        let closeButton = UIButton()
        closeButton.isEnabled = true
        sut.closeButton = closeButton

        sut.closeButtonAction(sender: closeButton)

        XCTAssertFalse(closeButton.isEnabled)
    }

    // MARK: - Subscription Tests
    func test_subscribe_to_presenter_sets_up_subscribers() {
        sut.subscribe(to: mockPresenter)

        XCTAssertNotNil(sut.stageStartSubscriber)
        XCTAssertNotNil(sut.stageEndSubscriber)
        XCTAssertNotNil(sut.confirmationSubscriber)
        XCTAssertNotNil(sut.disabledSubscriber)
        XCTAssertNotNil(sut.dismissSubscriber)
        XCTAssertNotNil(sut.messageSubscriber)
        XCTAssertNotNil(sut.resetSubscriber)
        XCTAssertNotNil(sut.spinnerSubscriber)
        XCTAssertNotNil(sut.titleSubscriber)
    }

    func test_subscribe_to_presenter_clears_existing_subscribers() {
        sut.subscribers.append(AnyCancellable {})
        let initialCount = sut.subscribers.count
        XCTAssertGreaterThan(initialCount, 0)

        sut.subscribe(to: mockPresenter)

        XCTAssertEqual(sut.subscribers.count, 0)
    }

    // MARK: - Display Logic Tests
    func test_displayReset_enables_close_button() {
        let closeButton = UIButton()
        closeButton.isEnabled = false
        sut.closeButton = closeButton

        let viewModel = DNSBaseStage.Models.Base.ViewModel()
        sut.displayReset(viewModel)

        // Use expectation to wait for async UI updates
        let expectation = XCTestExpectation(description: "Close button enabled")
        DispatchQueue.main.async {
            XCTAssertTrue(closeButton.isEnabled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
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

    // MARK: - Modal Detection Tests
    func test_isModal_returns_false_for_navigation_controller_child() {
        let navigationController = UINavigationController()
        navigationController.viewControllers = [sut]

        XCTAssertFalse(sut.isModal)
    }

    func test_isModal_returns_true_for_presented_view_controller() {
        let presentingViewController = UIViewController()
        sut.modalPresentationStyle = .formSheet

        // Simulate presentation
        let expectation = XCTestExpectation(description: "Modal presentation")
        presentingViewController.present(sut, animated: false) {
            XCTAssertTrue(self.sut.isModal)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Display Mode and Options Tests
    func test_displayMode_can_be_set_and_retrieved() {
        let testMode = DNSBaseStage.Display.Mode.modal
        sut.displayMode = testMode

        XCTAssertEqual(sut.displayMode, testMode)
    }

    func test_displayOptions_can_be_set_and_retrieved() {
        let testOptions: DNSBaseStage.Display.Options = [.navBarHidden(animated: false)]
        sut.displayOptions = testOptions

        XCTAssertEqual(sut.displayOptions, testOptions)
    }

    // MARK: - Gesture Recognizer Tests
    func test_gestureRecognizer_shouldBeRequiredToFailBy_returns_true() {
        let gestureRecognizer = UITapGestureRecognizer()
        let otherGestureRecognizer = UITapGestureRecognizer()

        let result = sut.gestureRecognizer(gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer)

        XCTAssertTrue(result)
    }

    func test_tapToDismiss_ends_view_editing() {
        let view = UIView()
        let textField = UITextField()
        view.addSubview(textField)
        sut.view.addSubview(view)

        textField.becomeFirstResponder()
        XCTAssertTrue(textField.isFirstResponder)

        let tapRecognizer = UITapGestureRecognizer()
        sut.tapToDismiss(recognizer: tapRecognizer)

        XCTAssertFalse(textField.isFirstResponder)
    }
}

// MARK: - Mock Classes

class MockBaseStagePresenter: DNSBaseStagePresentationLogic {
    typealias BaseStage = DNSBaseStage

    let stageStartPublisher = PassthroughSubject<BaseStage.Models.Start.ViewModel, Never>()
    let stageEndPublisher = PassthroughSubject<BaseStage.Models.Finish.ViewModel, Never>()
    let confirmationPublisher = PassthroughSubject<BaseStage.Models.Confirmation.ViewModel, Never>()
    let disabledPublisher = PassthroughSubject<BaseStage.Models.Disabled.ViewModel, Never>()
    let dismissPublisher = PassthroughSubject<BaseStage.Models.Dismiss.ViewModel, Never>()
    let messagePublisher = PassthroughSubject<BaseStage.Models.Message.ViewModel, Never>()
    let resetPublisher = PassthroughSubject<BaseStage.Models.Base.ViewModel, Never>()
    let spinnerPublisher = PassthroughSubject<BaseStage.Models.Spinner.ViewModel, Never>()
    let titlePublisher = PassthroughSubject<BaseStage.Models.Title.ViewModel, Never>()
}

class MockBaseStageConfigurator: DNSBaseStageConfigurator {
    var mockAnalyticsStageTitle: String?
    var configureStageWasCalled = false

    override var analyticsStageTitle: String {
        get { return mockAnalyticsStageTitle ?? "MockStageTitle" }
        set { } // Allow setting but ignore
    }

    override func configureStage() {
        configureStageWasCalled = true
    }
}

// MockAnalyticsWorker is now defined in TestHelpers/MockAnalyticsWorker.swift