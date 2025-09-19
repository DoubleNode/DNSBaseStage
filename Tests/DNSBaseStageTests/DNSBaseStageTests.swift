//
//  DNSBaseStageTests.swift
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
@testable import DNSAppCore

/// Base test class for DNSBaseStage package
/// This file acts as the main test entry point and imports all necessary modules
final class DNSBaseStageTests: XCTestCase {

    // MARK: - Basic Package Test
    func test_package_import_success() {
        // Test that the package can be imported successfully
        XCTAssertTrue(true, "DNSBaseStage package imports successfully")
    }

    // MARK: - BaseStage Type Aliases Test
    func test_baseStage_type_aliases() {
        // Test that DNSBaseStage type aliases are accessible
        let displayMode = DNSBaseStage.Display.Mode.modal
        XCTAssertNotNil(displayMode)

        let displayOptions = DNSBaseStage.Display.Options()
        XCTAssertNotNil(displayOptions)
    }

    // MARK: - Model Protocol Tests
    func test_baseStage_model_protocols() {
        // Test that base model protocols can be instantiated
        let baseRequest = DNSBaseStage.Models.Base.Request()
        XCTAssertNotNil(baseRequest)

        let baseResponse = DNSBaseStage.Models.Base.Response()
        XCTAssertNotNil(baseResponse)

        let baseViewModel = DNSBaseStage.Models.Base.ViewModel()
        XCTAssertNotNil(baseViewModel)
    }

    // MARK: - Error and Code Location Tests
    func test_baseStage_error_integration() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.unknown(codeLocation)
        XCTAssertNotNil(error)
        XCTAssertEqual(error.nsError.code, 1001)
    }

    func test_baseStage_code_location() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        XCTAssertNotNil(codeLocation)
        XCTAssertEqual(codeLocation.domain.hasPrefix("com.doublenode.baseStage."), true)
    }
}
