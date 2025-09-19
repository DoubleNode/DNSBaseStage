//
//  DNSBaseStageModelsTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import UIKit
@testable import DNSBaseStage
@testable import DNSError
@testable import DNSThemeTypes

class DNSBaseStageModelsTests: XCTestCase {

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        // Reset defaults before each test
        DNSBaseStageModels.defaults = DNSBaseStageModels.Defaults()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Defaults Tests
    func test_defaults_initialization() {
        let defaults = DNSBaseStageModels.Defaults()

        XCTAssertNotNil(defaults.error)
        XCTAssertNotNil(defaults.message)
        XCTAssertEqual(defaults.error.dismissingDirection, .default)
        XCTAssertEqual(defaults.error.duration, .default)
        XCTAssertEqual(defaults.error.location, .default)
        XCTAssertEqual(defaults.error.presentingDirection, .default)
    }

    func test_toast_defaults_initialization() {
        let toastDefaults = DNSBaseStageModels.ToastDefaults()

        XCTAssertEqual(toastDefaults.dismissingDirection, .default)
        XCTAssertEqual(toastDefaults.duration, .default)
        XCTAssertEqual(toastDefaults.location, .default)
        XCTAssertEqual(toastDefaults.presentingDirection, .default)
    }

    // MARK: - Enums Tests
    func test_direction_enum_cases() {
        XCTAssertNotNil(DNSBaseStageModels.Direction.default)
        XCTAssertNotNil(DNSBaseStageModels.Direction.left)
        XCTAssertNotNil(DNSBaseStageModels.Direction.right)
        XCTAssertNotNil(DNSBaseStageModels.Direction.vertical)
    }

    func test_duration_enum_cases() {
        XCTAssertNotNil(DNSBaseStageModels.Duration.default)
        XCTAssertNotNil(DNSBaseStageModels.Duration.short)
        XCTAssertNotNil(DNSBaseStageModels.Duration.average)
        XCTAssertNotNil(DNSBaseStageModels.Duration.long)

        let customDuration = DNSBaseStageModels.Duration.custom(5.0)
        if case .custom(let timeInterval) = customDuration {
            XCTAssertEqual(timeInterval, 5.0)
        } else {
            XCTFail("Custom duration not properly set")
        }
    }

    func test_location_enum_cases() {
        XCTAssertNotNil(DNSBaseStageModels.Location.default)
        XCTAssertNotNil(DNSBaseStageModels.Location.top)
        XCTAssertNotNil(DNSBaseStageModels.Location.bottom)
    }

    func test_style_enum_cases() {
        XCTAssertNotNil(DNSBaseStageModels.Style.none)
        XCTAssertNotNil(DNSBaseStageModels.Style.hudShow)
        XCTAssertNotNil(DNSBaseStageModels.Style.hudHide)
        XCTAssertNotNil(DNSBaseStageModels.Style.popup)
        XCTAssertNotNil(DNSBaseStageModels.Style.popupAction)
        XCTAssertNotNil(DNSBaseStageModels.Style.toastSuccess)
        XCTAssertNotNil(DNSBaseStageModels.Style.toastError)
        XCTAssertNotNil(DNSBaseStageModels.Style.toastWarning)
        XCTAssertNotNil(DNSBaseStageModels.Style.toastInfo)
    }

    // MARK: - Base Models Tests
    func test_base_initialization() {
        let initialization = DNSBaseStageModels.Base.Initialization()
        XCTAssertNotNil(initialization)
    }

    func test_base_results() {
        let results = DNSBaseStageModels.Base.Results()
        XCTAssertNotNil(results)
    }

    func test_base_data() {
        let data = DNSBaseStageModels.Base.Data()
        XCTAssertNotNil(data)
    }

    func test_base_request() {
        let request = DNSBaseStageModels.Base.Request()
        XCTAssertNotNil(request)
    }

    func test_base_response() {
        let response = DNSBaseStageModels.Base.Response()
        XCTAssertNotNil(response)
    }

    func test_base_viewModel() {
        let viewModel = DNSBaseStageModels.Base.ViewModel()
        XCTAssertNotNil(viewModel)
    }

    // MARK: - Start Models Tests
    func test_start_response_initialization() {
        let displayMode = DNSBaseStage.Display.Mode.modal
        let displayOptions: DNSBaseStage.Display.Options = [.navBarHidden(animated: false)]

        let response = DNSBaseStageModels.Start.Response(displayMode: displayMode, displayOptions: displayOptions)

        XCTAssertEqual(response.displayMode, displayMode)
        XCTAssertEqual(response.displayOptions, displayOptions)
    }

    func test_start_viewModel_initialization() {
        let displayMode = DNSBaseStage.Display.Mode.modal
        let displayOptions: DNSBaseStage.Display.Options = [.navBarHidden(animated: false)]

        let viewModel = DNSBaseStageModels.Start.ViewModel(animated: true, displayMode: displayMode, displayOptions: displayOptions)

        XCTAssertTrue(viewModel.animated)
        XCTAssertEqual(viewModel.displayMode, displayMode)
        XCTAssertEqual(viewModel.displayOptions, displayOptions)
    }

    // MARK: - Finish Models Tests
    func test_finish_response_initialization() {
        let displayMode = DNSBaseStage.Display.Mode.modal
        let response = DNSBaseStageModels.Finish.Response(displayMode: displayMode)

        XCTAssertEqual(response.displayMode, displayMode)
    }

    func test_finish_viewModel_initialization() {
        let displayMode = DNSBaseStage.Display.Mode.modal
        let viewModel = DNSBaseStageModels.Finish.ViewModel(animated: false, displayMode: displayMode)

        XCTAssertFalse(viewModel.animated)
        XCTAssertEqual(viewModel.displayMode, displayMode)
    }

    // MARK: - Confirmation Models Tests
    func test_confirmation_request_initialization() {
        let request = DNSBaseStageModels.Confirmation.Request()

        XCTAssertNotNil(request)
        XCTAssertNil(request.userData)
        XCTAssertNil(request.selection)
        XCTAssertTrue(request.textFields.isEmpty)
    }

    func test_confirmation_request_textField() {
        var textField = DNSBaseStageModels.Confirmation.Request.TextField()
        textField.value = "Test Value"

        XCTAssertEqual(textField.value, "Test Value")
    }

    func test_confirmation_response_initialization() {
        let response = DNSBaseStageModels.Confirmation.Response()

        XCTAssertNotNil(response)
        XCTAssertNil(response.alertStyle)
        XCTAssertNil(response.message)
        XCTAssertNil(response.title)
        XCTAssertTrue(response.buttons.isEmpty)
        XCTAssertTrue(response.textFields.isEmpty)
        XCTAssertNil(response.userData)
    }

    func test_confirmation_response_textField() {
        var textField = DNSBaseStageModels.Confirmation.Response.TextField()
        textField.contentType = "emailAddress"
        textField.keyboardType = .emailAddress
        textField.placeholder = "Enter email"

        XCTAssertEqual(textField.contentType, "emailAddress")
        XCTAssertEqual(textField.keyboardType, .emailAddress)
        XCTAssertEqual(textField.placeholder, "Enter email")
    }

    func test_confirmation_response_button() {
        var button = DNSBaseStageModels.Confirmation.Response.Button()
        button.code = "ok"
        button.style = .default
        button.title = "OK"

        XCTAssertEqual(button.code, "ok")
        XCTAssertEqual(button.style, .default)
        XCTAssertEqual(button.title, "OK")
    }

    func test_confirmation_viewModel_initialization() {
        let viewModel = DNSBaseStageModels.Confirmation.ViewModel()

        XCTAssertNotNil(viewModel)
        XCTAssertNil(viewModel.alertStyle)
        XCTAssertNil(viewModel.message)
        XCTAssertNil(viewModel.title)
        XCTAssertTrue(viewModel.buttons.isEmpty)
        XCTAssertTrue(viewModel.textFields.isEmpty)
        XCTAssertNil(viewModel.userData)
    }

    // MARK: - Disabled Models Tests
    func test_disabled_response_initialization() {
        let response = DNSBaseStageModels.Disabled.Response(show: true)

        XCTAssertTrue(response.show)
        XCTAssertFalse(response.forceReset)
    }

    func test_disabled_response_with_forceReset() {
        var response = DNSBaseStageModels.Disabled.Response(show: true)
        response.forceReset = true

        XCTAssertTrue(response.show)
        XCTAssertTrue(response.forceReset)
    }

    func test_disabled_viewModel_initialization() {
        let viewModel = DNSBaseStageModels.Disabled.ViewModel(show: false)

        XCTAssertFalse(viewModel.show)
    }

    // MARK: - Dismiss Models Tests
    func test_dismiss_response_initialization() {
        let response = DNSBaseStageModels.Dismiss.Response(animated: true)

        XCTAssertTrue(response.animated)
    }

    func test_dismiss_viewModel_initialization() {
        let viewModel = DNSBaseStageModels.Dismiss.ViewModel(animated: false)

        XCTAssertFalse(viewModel.animated)
    }

    // MARK: - ErrorMessage Models Tests
    func test_errorMessage_request_initialization() {
        let error = NSError(domain: "TestDomain", code: 123, userInfo: nil)
        let request = DNSBaseStageModels.ErrorMessage.Request(error: error, style: .popup, title: "Error")

        XCTAssertEqual((request.error as NSError).domain, "TestDomain")
        XCTAssertEqual((request.error as NSError).code, 123)
        XCTAssertEqual(request.style, .popup)
        XCTAssertEqual(request.title, "Error")
        XCTAssertTrue(request.nibName.isEmpty)
        XCTAssertNil(request.nibBundle)
        XCTAssertTrue(request.okayButton.isEmpty)
    }

    func test_errorMessage_response_initialization() {
        let error = NSError(domain: "TestDomain", code: 123, userInfo: nil)
        let response = DNSBaseStageModels.ErrorMessage.Response(error: error, style: .popup, title: "Error")

        XCTAssertEqual((response.error as NSError).domain, "TestDomain")
        XCTAssertEqual((response.error as NSError).code, 123)
        XCTAssertEqual(response.style, .popup)
        XCTAssertEqual(response.title, "Error")
        XCTAssertEqual(response.dismissingDirection, DNSBaseStageModels.defaults.error.dismissingDirection)
        XCTAssertEqual(response.duration, DNSBaseStageModels.defaults.error.duration)
        XCTAssertEqual(response.location, DNSBaseStageModels.defaults.error.location)
        XCTAssertEqual(response.presentingDirection, DNSBaseStageModels.defaults.error.presentingDirection)
    }

    // MARK: - Message Models Tests
    func test_message_request_initialization() {
        let request = DNSBaseStageModels.Message.Request()

        XCTAssertTrue(request.actionCode.isEmpty)
        XCTAssertFalse(request.cancelled)
        XCTAssertNil(request.userData)
    }

    func test_message_response_initialization() {
        let response = DNSBaseStageModels.Message.Response(message: "Test Message", style: .toastInfo, title: "Info")

        XCTAssertEqual(response.message, "Test Message")
        XCTAssertEqual(response.style, .toastInfo)
        XCTAssertEqual(response.title, "Info")
        XCTAssertTrue(response.disclaimer.isEmpty)
        XCTAssertEqual(response.dismissingDirection, DNSBaseStageModels.defaults.message.dismissingDirection)
        XCTAssertEqual(response.duration, DNSBaseStageModels.defaults.message.duration)
        XCTAssertNil(response.image)
        XCTAssertNil(response.imageUrl)
        XCTAssertEqual(response.location, DNSBaseStageModels.defaults.message.location)
        XCTAssertTrue(response.tags.isEmpty)
        XCTAssertEqual(response.percentage, -1)
        XCTAssertEqual(response.presentingDirection, DNSBaseStageModels.defaults.message.presentingDirection)
        XCTAssertTrue(response.subtitle.isEmpty)
        XCTAssertTrue(response.actions.isEmpty)
        XCTAssertTrue(response.cancelText.isEmpty)
        XCTAssertTrue(response.nibName.isEmpty)
        XCTAssertNil(response.nibBundle)
        XCTAssertNil(response.userData)
        XCTAssertTrue(response.actionsStyles.isEmpty)
    }

    func test_message_viewModel_initialization() {
        let viewModel = DNSBaseStageModels.Message.ViewModel(message: "Test Message", style: .toastInfo, title: "Info")

        XCTAssertEqual(viewModel.message, "Test Message")
        XCTAssertEqual(viewModel.style, .toastInfo)
        XCTAssertEqual(viewModel.title, "Info")
        XCTAssertEqual(viewModel.percentage, -1)
    }

    func test_message_viewModel_with_percentage() {
        let viewModel = DNSBaseStageModels.Message.ViewModel(message: "Progress", percentage: 0.5, style: .hudShow, title: "Loading")

        XCTAssertEqual(viewModel.message, "Progress")
        XCTAssertEqual(viewModel.percentage, 0.5)
        XCTAssertEqual(viewModel.style, .hudShow)
        XCTAssertEqual(viewModel.title, "Loading")
    }

    func test_message_viewModel_colors() {
        var colors = DNSBaseStageModels.Message.ViewModel.Colors()
        colors.background = UIColor.blue
        colors.message = UIColor.white
        colors.subtitle = UIColor.gray
        colors.title = UIColor.black

        XCTAssertEqual(colors.background, UIColor.blue)
        XCTAssertEqual(colors.message, UIColor.white)
        XCTAssertEqual(colors.subtitle, UIColor.gray)
        XCTAssertEqual(colors.title, UIColor.black)
    }

    func test_message_viewModel_fonts() {
        var fonts = DNSBaseStageModels.Message.ViewModel.Fonts()
        fonts.message = UIFont.systemFont(ofSize: 14)
        fonts.subtitle = UIFont.systemFont(ofSize: 12)
        fonts.title = UIFont.boldSystemFont(ofSize: 16)

        XCTAssertEqual(fonts.message, UIFont.systemFont(ofSize: 14))
        XCTAssertEqual(fonts.subtitle, UIFont.systemFont(ofSize: 12))
        XCTAssertEqual(fonts.title, UIFont.boldSystemFont(ofSize: 16))
    }

    // MARK: - Spinner Models Tests
    func test_spinner_response_initialization() {
        let response = DNSBaseStageModels.Spinner.Response(show: true)

        XCTAssertTrue(response.show)
        XCTAssertFalse(response.forceReset)
    }

    func test_spinner_response_with_forceReset() {
        var response = DNSBaseStageModels.Spinner.Response(show: false)
        response.forceReset = true

        XCTAssertFalse(response.show)
        XCTAssertTrue(response.forceReset)
    }

    func test_spinner_viewModel_initialization() {
        let viewModel = DNSBaseStageModels.Spinner.ViewModel(show: true)

        XCTAssertTrue(viewModel.show)
    }

    // MARK: - Title Models Tests
    func test_title_response_initialization() {
        let response = DNSBaseStageModels.Title.Response(title: "Test Title")

        XCTAssertEqual(response.title, "Test Title")
        XCTAssertTrue(response.tabBarImageName.isEmpty)
        XCTAssertFalse(response.tabBarHide)
    }

    func test_title_response_with_tabBar_settings() {
        var response = DNSBaseStageModels.Title.Response(title: "Test Title")
        response.tabBarImageName = "testImage"
        response.tabBarHide = true

        XCTAssertEqual(response.title, "Test Title")
        XCTAssertEqual(response.tabBarImageName, "testImage")
        XCTAssertTrue(response.tabBarHide)
    }

    func test_title_viewModel_initialization() {
        let viewModel = DNSBaseStageModels.Title.ViewModel(title: "Test Title")

        XCTAssertEqual(viewModel.title, "Test Title")
        XCTAssertFalse(viewModel.tabBarHide)
        XCTAssertNil(viewModel.tabBarSelectedImage)
        XCTAssertNil(viewModel.tabBarUnselectedImage)
    }

    // MARK: - Webpage Models Tests
    func test_webpage_request_initialization() {
        let url = URL(string: "https://example.com")!
        let request = DNSBaseStageModels.Webpage.Request(url: url)

        XCTAssertEqual(request.url, url)
    }

    func test_webpageProgress_request_initialization() {
        let request = DNSBaseStageModels.WebpageProgress.Request(percentage: 0.75)

        XCTAssertEqual(request.percentage, 0.75)
    }

    func test_webpageError_request_initialization() {
        let url = URL(string: "https://example.com")!
        let error = NSError(domain: "WebError", code: 404, userInfo: nil)
        let request = DNSBaseStageModels.WebpageError.Request(url: url, error: error)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual((request.error as NSError).domain, "WebError")
        XCTAssertEqual((request.error as NSError).code, 404)
    }

    // MARK: - Protocol Conformance Tests
    func test_base_models_conform_to_protocols() {
        let initialization = DNSBaseStageModels.Base.Initialization()
        XCTAssertTrue(initialization is DNSBaseStageBaseInitialization)

        let results = DNSBaseStageModels.Base.Results()
        XCTAssertTrue(results is DNSBaseStageBaseResults)

        let data = DNSBaseStageModels.Base.Data()
        XCTAssertTrue(data is DNSBaseStageBaseData)

        let request = DNSBaseStageModels.Base.Request()
        XCTAssertTrue(request is DNSBaseStageBaseRequest)

        let response = DNSBaseStageModels.Base.Response()
        XCTAssertTrue(response is DNSBaseStageBaseResponse)

        let viewModel = DNSBaseStageModels.Base.ViewModel()
        XCTAssertTrue(viewModel is DNSBaseStageBaseViewModel)
    }

    func test_specialized_models_conform_to_base_protocols() {
        let startResponse = DNSBaseStageModels.Start.Response(displayMode: .modal, displayOptions: [])
        XCTAssertTrue(startResponse is DNSBaseStageBaseResponse)

        let confirmationRequest = DNSBaseStageModels.Confirmation.Request()
        XCTAssertTrue(confirmationRequest is DNSBaseStageBaseRequest)

        let messageViewModel = DNSBaseStageModels.Message.ViewModel(message: "", style: .none, title: "")
        XCTAssertTrue(messageViewModel is DNSBaseStageBaseViewModel)
    }

    // MARK: - Edge Cases and Error Handling Tests
    func test_custom_duration_edge_cases() {
        let zeroDuration = DNSBaseStageModels.Duration.custom(0.0)
        let negativeDuration = DNSBaseStageModels.Duration.custom(-1.0)
        let largeDuration = DNSBaseStageModels.Duration.custom(999999.0)

        if case .custom(let time1) = zeroDuration { XCTAssertEqual(time1, 0.0) }
        if case .custom(let time2) = negativeDuration { XCTAssertEqual(time2, -1.0) }
        if case .custom(let time3) = largeDuration { XCTAssertEqual(time3, 999999.0) }
    }

    func test_empty_string_handling() {
        let response = DNSBaseStageModels.Message.Response(message: "", style: .none, title: "")

        XCTAssertTrue(response.message.isEmpty)
        XCTAssertTrue(response.title.isEmpty)
        XCTAssertTrue(response.disclaimer.isEmpty)
        XCTAssertTrue(response.subtitle.isEmpty)
        XCTAssertTrue(response.cancelText.isEmpty)
        XCTAssertTrue(response.nibName.isEmpty)
    }

    func test_nil_handling_in_optional_properties() {
        let confirmationResponse = DNSBaseStageModels.Confirmation.Response()

        XCTAssertNil(confirmationResponse.alertStyle)
        XCTAssertNil(confirmationResponse.message)
        XCTAssertNil(confirmationResponse.title)
        XCTAssertNil(confirmationResponse.userData)

        let messageResponse = DNSBaseStageModels.Message.Response(message: "test", style: .none, title: "test")
        XCTAssertNil(messageResponse.image)
        XCTAssertNil(messageResponse.imageUrl)
        XCTAssertNil(messageResponse.nibBundle)
        XCTAssertNil(messageResponse.userData)
    }
}