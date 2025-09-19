//
//  DNSBaseStagePresenterTests.swift
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

class DNSBaseStagePresenterTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSBaseStagePresenter!
    private var mockInteractor: MockBaseStageInteractor!
    private var mockConfigurator: MockBaseStageConfigurator!
    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockConfigurator = MockBaseStageConfigurator()
        mockInteractor = MockBaseStageInteractor()
        sut = DNSBaseStagePresenter(configurator: mockConfigurator)
    }

    override func tearDown() {
        cancellables.removeAll()
        cancellables = nil
        sut = nil
        mockInteractor = nil
        mockConfigurator = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func test_initialization_with_configurator() {
        let configurator = MockBaseStageConfigurator()
        let presenter = DNSBaseStagePresenter(configurator: configurator)

        XCTAssertNotNil(presenter)
        XCTAssertNotNil(presenter.baseConfigurator)
    }

    // MARK: - Properties Tests
    func test_analyticsClassTitle_returns_class_name() {
        let expectedTitle = String(describing: DNSBaseStagePresenter.self)
        XCTAssertEqual(sut.analyticsClassTitle, expectedTitle)
    }

    func test_analyticsStageTitle_returns_configurator_title_when_available() {
        mockConfigurator.mockAnalyticsStageTitle = "TestPresenterTitle"
        XCTAssertEqual(sut.analyticsStageTitle, "TestPresenterTitle")
    }

    func test_analyticsStageTitle_returns_class_name_when_configurator_unavailable() {
        mockConfigurator.mockAnalyticsStageTitle = nil
        let expectedTitle = String(describing: DNSBaseStagePresenter.self)
        XCTAssertEqual(sut.analyticsStageTitle, expectedTitle)
    }

    // MARK: - Publishers Tests
    func test_publishers_are_initialized() {
        XCTAssertNotNil(sut.stageStartPublisher)
        XCTAssertNotNil(sut.stageEndPublisher)
        XCTAssertNotNil(sut.confirmationPublisher)
        XCTAssertNotNil(sut.disabledPublisher)
        XCTAssertNotNil(sut.dismissPublisher)
        XCTAssertNotNil(sut.messagePublisher)
        XCTAssertNotNil(sut.resetPublisher)
        XCTAssertNotNil(sut.spinnerPublisher)
        XCTAssertNotNil(sut.titlePublisher)
    }

    // MARK: - Default Color Properties Tests
    func test_default_color_properties() {
        XCTAssertEqual(sut.defaultBackgroundColor, UIColor.blue)
        XCTAssertEqual(sut.defaultMessageColor, UIColor.white)
        XCTAssertEqual(sut.defaultTitleColor, UIColor.white)

        XCTAssertEqual(sut.errorBackgroundColor, UIColor.red)
        XCTAssertEqual(sut.errorMessageColor, UIColor.white)
        XCTAssertEqual(sut.errorTitleColor, UIColor.white)
    }

    func test_default_font_properties() {
        XCTAssertEqual(sut.defaultMessageFont, UIFont.systemFont(ofSize: 14))
        XCTAssertEqual(sut.defaultTitleFont, UIFont.boldSystemFont(ofSize: 16))

        XCTAssertEqual(sut.errorMessageFont, UIFont.systemFont(ofSize: 14))
        XCTAssertEqual(sut.errorTitleFont, UIFont.boldSystemFont(ofSize: 16))
    }

    // MARK: - Lifecycle Methods Tests
    func test_startStage_sends_viewModel_with_correct_data() {
        var receivedViewModel: DNSBaseStage.Models.Start.ViewModel?

        sut.stageStartPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        let displayMode = DNSBaseStage.Display.Mode.modal
        let displayOptions: DNSBaseStage.Display.Options = [.navBarHidden(animated: false)]
        let response = DNSBaseStage.Models.Start.Response(displayMode: displayMode, displayOptions: displayOptions)

        sut.startStage(response)

        XCTAssertNotNil(receivedViewModel)
        XCTAssertTrue(receivedViewModel!.animated)
        XCTAssertEqual(receivedViewModel!.displayMode, displayMode)
        XCTAssertEqual(receivedViewModel!.displayOptions, displayOptions)
    }

    func test_startStage_resets_spinner_count() {
        sut.spinnerCount = 5
        let response = DNSBaseStage.Models.Start.Response(displayMode: .modal, displayOptions: [])

        sut.startStage(response)

        XCTAssertEqual(sut.spinnerCount, 0)
    }

    func test_endStage_sends_viewModel_with_correct_data() {
        var receivedViewModel: DNSBaseStage.Models.Finish.ViewModel?

        sut.stageEndPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        let displayMode = DNSBaseStage.Display.Mode.modal
        let response = DNSBaseStage.Models.Finish.Response(displayMode: displayMode)

        sut.endStage(response)

        XCTAssertNotNil(receivedViewModel)
        XCTAssertTrue(receivedViewModel!.animated)
        XCTAssertEqual(receivedViewModel!.displayMode, displayMode)
    }

    func test_endStage_resets_spinner_count() {
        sut.spinnerCount = 3
        let response = DNSBaseStage.Models.Finish.Response(displayMode: .modal)

        sut.endStage(response)

        XCTAssertEqual(sut.spinnerCount, 0)
    }

    // MARK: - Presentation Logic Tests
    func test_presentConfirmation_sends_correct_viewModel() {
        var receivedViewModel: DNSBaseStage.Models.Confirmation.ViewModel?

        sut.confirmationPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        var response = DNSBaseStage.Models.Confirmation.Response()
        response.title = "Test Title"
        response.message = "Test Message"
        response.alertStyle = .alert

        sut.presentConfirmation(response)

        // Allow time for async processing
        let expectation = XCTestExpectation(description: "Confirmation presented")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(receivedViewModel)
            XCTAssertEqual(receivedViewModel?.title, "Test Title")
            XCTAssertEqual(receivedViewModel?.message, "Test Message")
            XCTAssertEqual(receivedViewModel?.alertStyle, .alert)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_presentConfirmation_with_textFields_and_buttons() {
        var receivedViewModel: DNSBaseStage.Models.Confirmation.ViewModel?

        sut.confirmationPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        let response = DNSBaseStage.Models.Confirmation.Response()

        var textField = DNSBaseStage.Models.Confirmation.Response.TextField()
        textField.placeholder = "Enter text"
        textField.keyboardType = .default
        response.textFields.append(textField)

        var button = DNSBaseStage.Models.Confirmation.Response.Button()
        button.title = "OK"
        button.style = .default
        button.code = "ok"
        response.buttons.append(button)

        sut.presentConfirmation(response)

        let expectation = XCTestExpectation(description: "Confirmation with fields presented")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(receivedViewModel)
            XCTAssertEqual(receivedViewModel?.textFields.count, 1)
            XCTAssertEqual(receivedViewModel?.textFields.first?.placeholder, "Enter text")
            XCTAssertEqual(receivedViewModel?.buttons.count, 1)
            XCTAssertEqual(receivedViewModel?.buttons.first?.title, "OK")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Disabled Presentation Tests
    func test_presentDisabled_show_increments_count() {
        let response = DNSBaseStage.Models.Disabled.Response(show: true)

        sut.presentDisabled(response)
        XCTAssertEqual(sut.disabledCount, 1)

        sut.presentDisabled(response)
        XCTAssertEqual(sut.disabledCount, 2)
    }

    func test_presentDisabled_hide_decrements_count() {
        sut.disabledCount = 2
        let response = DNSBaseStage.Models.Disabled.Response(show: false)

        sut.presentDisabled(response)
        XCTAssertEqual(sut.disabledCount, 1)

        sut.presentDisabled(response)
        XCTAssertEqual(sut.disabledCount, 0)
    }

    func test_presentDisabled_forceReset_resets_count() {
        sut.disabledCount = 5
        var response = DNSBaseStage.Models.Disabled.Response(show: true)
        response.forceReset = true

        sut.presentDisabled(response)
        XCTAssertEqual(sut.disabledCount, 1)
    }

    func test_presentDisabled_only_shows_when_count_is_one() {
        var receivedViewModel: DNSBaseStage.Models.Disabled.ViewModel?
        var callCount = 0

        sut.disabledPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
                callCount += 1
            }
            .store(in: &cancellables)

        let response = DNSBaseStage.Models.Disabled.Response(show: true)

        // First call should trigger publisher after delay
        sut.presentDisabled(response)
        // Second call should not trigger publisher (count = 2)
        sut.presentDisabled(response)

        let expectation = XCTestExpectation(description: "Disabled shown only once")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(callCount, 1)
            XCTAssertNotNil(receivedViewModel)
            XCTAssertTrue(receivedViewModel!.show)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Spinner Presentation Tests
    func test_presentSpinner_show_increments_count() {
        let response = DNSBaseStage.Models.Spinner.Response(show: true)

        sut.presentSpinner(response)
        XCTAssertEqual(sut.spinnerCount, 1)

        sut.presentSpinner(response)
        XCTAssertEqual(sut.spinnerCount, 2)
    }

    func test_presentSpinner_hide_decrements_count() {
        sut.spinnerCount = 2
        let response = DNSBaseStage.Models.Spinner.Response(show: false)

        sut.presentSpinner(response)
        XCTAssertEqual(sut.spinnerCount, 1)

        sut.presentSpinner(response)
        XCTAssertEqual(sut.spinnerCount, 0)
    }

    func test_presentSpinner_forceReset_resets_count() {
        sut.spinnerCount = 5
        var response = DNSBaseStage.Models.Spinner.Response(show: true)
        response.forceReset = true

        sut.presentSpinner(response)
        XCTAssertEqual(sut.spinnerCount, 1)
    }

    func test_presentSpinner_only_shows_when_count_is_one() {
        var receivedViewModel: DNSBaseStage.Models.Spinner.ViewModel?
        var callCount = 0

        sut.spinnerPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
                callCount += 1
            }
            .store(in: &cancellables)

        let response = DNSBaseStage.Models.Spinner.Response(show: true)

        // First call should trigger publisher after delay
        sut.presentSpinner(response)
        // Second call should not trigger publisher (count = 2)
        sut.presentSpinner(response)

        let expectation = XCTestExpectation(description: "Spinner shown only once")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(callCount, 1)
            XCTAssertNotNil(receivedViewModel)
            XCTAssertTrue(receivedViewModel!.show)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Dismiss Presentation Tests
    func test_presentDismiss_sends_correct_viewModel() {
        var receivedViewModel: DNSBaseStage.Models.Dismiss.ViewModel?

        sut.dismissPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        let response = DNSBaseStage.Models.Dismiss.Response(animated: true)
        sut.presentDismiss(response)

        XCTAssertNotNil(receivedViewModel)
        XCTAssertTrue(receivedViewModel!.animated)
    }

    // MARK: - Error Message Presentation Tests
    func test_presentErrorMessage_creates_correct_viewModel() {
        var receivedViewModel: DNSBaseStage.Models.Message.ViewModel?

        sut.messagePublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let response = DNSBaseStage.Models.ErrorMessage.Response(error: testError, style: .popup, title: "Error Title")

        sut.presentErrorMessage(response)

        let expectation = XCTestExpectation(description: "Error message presented")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(receivedViewModel)
            XCTAssertEqual(receivedViewModel?.title, "Error Title")
            XCTAssertEqual(receivedViewModel?.message, "Test error")
            XCTAssertEqual(receivedViewModel?.style, .popup)
            XCTAssertEqual(receivedViewModel?.colors?.background, self.sut.errorBackgroundColor)
            XCTAssertEqual(receivedViewModel?.colors?.message, self.sut.errorMessageColor)
            XCTAssertEqual(receivedViewModel?.colors?.title, self.sut.errorTitleColor)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Message Presentation Tests
    func test_presentMessage_creates_correct_viewModel() {
        var receivedViewModel: DNSBaseStage.Models.Message.ViewModel?

        sut.messagePublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        var response = DNSBaseStage.Models.Message.Response(message: "Test Message", style: .toastInfo, title: "Info Title")
        response.subtitle = "Test Subtitle"
        response.percentage = 0.75
        response.actions = ["ok": "OK"]

        sut.presentMessage(response)

        let expectation = XCTestExpectation(description: "Message presented")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(receivedViewModel)
            XCTAssertEqual(receivedViewModel?.title, "Info Title")
            XCTAssertEqual(receivedViewModel?.message, "Test Message")
            XCTAssertEqual(receivedViewModel?.subtitle, "Test Subtitle")
            XCTAssertEqual(receivedViewModel?.percentage, 0.75)
            XCTAssertEqual(receivedViewModel?.style, .toastInfo)
            XCTAssertEqual(receivedViewModel?.actions["ok"], "OK")
            XCTAssertEqual(receivedViewModel?.colors?.background, self.sut.defaultBackgroundColor)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Reset Presentation Tests
    func test_presentReset_sends_base_viewModel() {
        var receivedViewModel: DNSBaseStage.Models.Base.ViewModel?

        sut.resetPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        let response = DNSBaseStage.Models.Base.Response()
        sut.presentReset(response)

        XCTAssertNotNil(receivedViewModel)
    }

    // MARK: - Title Presentation Tests
    func test_presentTitle_creates_correct_viewModel() {
        var receivedViewModel: DNSBaseStage.Models.Title.ViewModel?

        sut.titlePublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        var response = DNSBaseStage.Models.Title.Response(title: "Test Title")
        response.tabBarHide = true
        response.tabBarImageName = "testImage"

        sut.presentTitle(response)

        XCTAssertNotNil(receivedViewModel)
        XCTAssertEqual(receivedViewModel?.title, "Test Title")
        XCTAssertTrue(receivedViewModel?.tabBarHide ?? false)
        // Note: Image testing requires bundle resources
    }

    // MARK: - Subscription Tests
    func test_subscribe_to_interactor_sets_up_subscribers() {
        sut.subscribe(to: mockInteractor)

        XCTAssertNotNil(sut.stageStartSubscriber)
        XCTAssertNotNil(sut.stageEndSubscriber)
        XCTAssertNotNil(sut.confirmationSubscriber)
        XCTAssertNotNil(sut.disabledSubscriber)
        XCTAssertNotNil(sut.dismissSubscriber)
        XCTAssertNotNil(sut.errorSubscriber)
        XCTAssertNotNil(sut.messageSubscriber)
        XCTAssertNotNil(sut.resetSubscriber)
        XCTAssertNotNil(sut.spinnerSubscriber)
        XCTAssertNotNil(sut.titleSubscriber)
    }

    func test_subscribe_to_interactor_clears_existing_subscribers() {
        sut.subscribers.append(AnyCancellable {})
        let initialCount = sut.subscribers.count
        XCTAssertGreaterThan(initialCount, 0)

        sut.subscribe(to: mockInteractor)

        XCTAssertEqual(sut.subscribers.count, 0)
    }

    // MARK: - Shortcut Methods Tests
    func test_disabled_shortcut_sends_correct_response() {
        var receivedViewModel: DNSBaseStage.Models.Disabled.ViewModel?

        sut.disabledPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        sut.disabled(show: true)

        let expectation = XCTestExpectation(description: "Disabled shortcut")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertNotNil(receivedViewModel)
            XCTAssertTrue(receivedViewModel!.show)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_spinner_shortcut_sends_correct_response() {
        var receivedViewModel: DNSBaseStage.Models.Spinner.ViewModel?

        sut.spinnerPublisher
            .sink { viewModel in
                receivedViewModel = viewModel
            }
            .store(in: &cancellables)

        sut.spinner(show: true)

        let expectation = XCTestExpectation(description: "Spinner shortcut")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertNotNil(receivedViewModel)
            XCTAssertTrue(receivedViewModel!.show)
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
}

// MARK: - Mock Classes

class MockBaseStageInteractor: DNSBaseStageBusinessLogic {
    typealias BaseStage = DNSBaseStage

    let stageStartPublisher = PassthroughSubject<BaseStage.Models.Start.Response, Never>()
    let stageEndPublisher = PassthroughSubject<BaseStage.Models.Finish.Response, Never>()
    let confirmationPublisher = PassthroughSubject<BaseStage.Models.Confirmation.Response, Never>()
    let disabledPublisher = PassthroughSubject<BaseStage.Models.Disabled.Response, Never>()
    let dismissPublisher = PassthroughSubject<BaseStage.Models.Dismiss.Response, Never>()
    let errorPublisher = PassthroughSubject<BaseStage.Models.ErrorMessage.Response, Never>()
    let messagePublisher = PassthroughSubject<BaseStage.Models.Message.Response, Never>()
    let resetPublisher = PassthroughSubject<BaseStage.Models.Base.Response, Never>()
    let spinnerPublisher = PassthroughSubject<BaseStage.Models.Spinner.Response, Never>()
    let titlePublisher = PassthroughSubject<BaseStage.Models.Title.Response, Never>()
}