//
//  DNSBaseStageErrorTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import Foundation
@testable import DNSBaseStage
@testable import DNSError

class DNSBaseStageErrorTests: XCTestCase {

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Domain and Code Tests
    func test_error_domain_is_correct() {
        XCTAssertEqual(DNSBaseStageError.domain, "BASESTAGE")
    }

    func test_error_codes_have_correct_values() {
        XCTAssertEqual(DNSBaseStageError.Code.unknown.rawValue, 1001)
        XCTAssertEqual(DNSBaseStageError.Code.notImplemented.rawValue, 1002)
        XCTAssertEqual(DNSBaseStageError.Code.notFound.rawValue, 1003)
        XCTAssertEqual(DNSBaseStageError.Code.invalidParameters.rawValue, 1004)
        XCTAssertEqual(DNSBaseStageError.Code.lowerError.rawValue, 1005)

        XCTAssertEqual(DNSBaseStageError.Code.systemError.rawValue, 2001)
        XCTAssertEqual(DNSBaseStageError.Code.webViewError.rawValue, 2002)
        XCTAssertEqual(DNSBaseStageError.Code.calendarError.rawValue, 2003)
        XCTAssertEqual(DNSBaseStageError.Code.calendarDenied.rawValue, 2004)
        XCTAssertEqual(DNSBaseStageError.Code.mailError.rawValue, 2005)
    }

    // MARK: - Common Error Tests
    func test_unknown_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.unknown(codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 1001)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("Unknown Error"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:1001"))
    }

    func test_notImplemented_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.notImplemented(codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 1002)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("Not Implemented"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:1002"))
    }

    func test_notFound_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.notFound(field: "userId", value: "12345", codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 1003)
        XCTAssertEqual(error.nsError.userInfo["field"] as? String, "userId")
        XCTAssertEqual(error.nsError.userInfo["value"] as? String, "12345")
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("Not Found"))
        XCTAssertTrue(error.errorString.contains("userId"))
        XCTAssertTrue(error.errorString.contains("12345"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:1003"))
    }

    func test_invalidParameters_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let parameters = ["param1", "param2", "param3"]
        let error = DNSBaseStageError.invalidParameters(parameters: parameters, codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 1004)
        XCTAssertEqual(error.nsError.userInfo["Parameters"] as? [String], parameters)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("Invalid Parameters"))
        XCTAssertTrue(error.errorString.contains("param1, param2, param3"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:1004"))
    }

    func test_lowerError_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let underlyingError = NSError(domain: "TestDomain", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test underlying error"])
        let error = DNSBaseStageError.lowerError(error: underlyingError, codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 1005)
        XCTAssertNotNil(error.nsError.userInfo["Error"])
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("Lower Error"))
        XCTAssertTrue(error.errorString.contains("Test underlying error"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:1005"))
    }

    // MARK: - Domain-Specific Error Tests
    func test_systemError_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let systemError = NSError(domain: "SystemDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "System failure"])
        let error = DNSBaseStageError.systemError(error: systemError, codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 2001)
        XCTAssertNotNil(error.nsError.userInfo["Error"])
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("System Error"))
        XCTAssertTrue(error.errorString.contains("System failure"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:2001"))
    }

    func test_webViewError_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let webError = NSError(domain: "WebDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Page not found"])
        let error = DNSBaseStageError.webViewError(error: webError, codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 2002)
        XCTAssertNotNil(error.nsError.userInfo["Error"])
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("WebView Error"))
        XCTAssertTrue(error.errorString.contains("Page not found"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:2002"))
    }

    func test_calendarError_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let calendarError = NSError(domain: "CalendarDomain", code: 300, userInfo: [NSLocalizedDescriptionKey: "Calendar access failed"])
        let error = DNSBaseStageError.calendarError(error: calendarError, codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 2003)
        XCTAssertNotNil(error.nsError.userInfo["Error"])
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("Calendar Error"))
        XCTAssertTrue(error.errorString.contains("Calendar access failed"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:2003"))
    }

    func test_calendarDenied_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.calendarDenied(codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 2004)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("Calendar Denied"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:2003")) // Note: Uses calendarError code in string
    }

    func test_mailError_error() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let mailError = NSError(domain: "MailDomain", code: 600, userInfo: [NSLocalizedDescriptionKey: "Mail send failed"])
        let error = DNSBaseStageError.mailError(error: mailError, codeLocation)

        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
        XCTAssertEqual(error.nsError.code, 2005)
        XCTAssertNotNil(error.nsError.userInfo["Error"])
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorString.contains("Mail Error"))
        XCTAssertTrue(error.errorString.contains("Mail send failed"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:2005"))
    }

    // MARK: - Failure Reason Tests
    func test_failureReason_returns_codeLocation_failureReason() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.unknown(codeLocation)

        XCTAssertEqual(error.failureReason, codeLocation.failureReason)
    }

    func test_failureReason_for_all_error_types() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)

        let errors: [DNSBaseStageError] = [
            .unknown(codeLocation),
            .notImplemented(codeLocation),
            .notFound(field: "test", value: "value", codeLocation),
            .invalidParameters(parameters: ["param"], codeLocation),
            .lowerError(error: testError, codeLocation),
            .systemError(error: testError, codeLocation),
            .webViewError(error: testError, codeLocation),
            .calendarError(error: testError, codeLocation),
            .calendarDenied(codeLocation),
            .mailError(error: testError, codeLocation)
        ]

        for error in errors {
            XCTAssertEqual(error.failureReason, codeLocation.failureReason)
        }
    }

    // MARK: - NSError Integration Tests
    func test_nsError_contains_codeLocation_userInfo() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.unknown(codeLocation)
        let nsError = error.nsError!

        // Should contain code location info
        XCTAssertNotNil(nsError.userInfo[NSLocalizedDescriptionKey])

        // Test that userInfo contains code location data
        let codeLocationUserInfo = codeLocation.userInfo
        for (key, value) in codeLocationUserInfo {
            XCTAssertEqual(nsError.userInfo[key] as? String, value as? String)
        }
    }

    func test_errorDescription_matches_errorString() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.notImplemented(codeLocation)

        XCTAssertEqual(error.errorDescription, error.errorString)
    }

    // MARK: - Edge Cases Tests
    func test_invalidParameters_with_empty_array() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.invalidParameters(parameters: [], codeLocation)

        XCTAssertTrue(error.errorString.contains("Invalid Parameters"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:1004"))
        // Should handle empty parameters gracefully
    }

    func test_invalidParameters_with_single_parameter() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.invalidParameters(parameters: ["singleParam"], codeLocation)

        XCTAssertTrue(error.errorString.contains("singleParam"))
        XCTAssertFalse(error.errorString.contains(",")) // No comma for single parameter
    }

    func test_notFound_with_empty_field_and_value() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.notFound(field: "", value: "", codeLocation)

        XCTAssertTrue(error.errorString.contains("Not Found"))
        XCTAssertTrue(error.errorString.contains("BASESTAGE:1003"))
        // Should handle empty field and value gracefully
    }

    // MARK: - Type Alias Tests
    func test_DNSError_BaseStage_typealias() {
        // Test that the type alias works correctly
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error: DNSError.BaseStage = .unknown(codeLocation)

        XCTAssertTrue(error is DNSBaseStageError)
        XCTAssertEqual(error.nsError.domain, "BASESTAGE")
    }

    // MARK: - LocalizedError Protocol Tests
    func test_localizedError_protocol_conformance() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let error = DNSBaseStageError.unknown(codeLocation)

        XCTAssertTrue(error is LocalizedError)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.failureReason)
    }

    // MARK: - Error Chain Tests
    func test_nested_errors_maintain_information() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let originalError = NSError(domain: "OriginalDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Original error message"])

        let lowerError = DNSBaseStageError.lowerError(error: originalError, codeLocation)
        let systemError = DNSBaseStageError.systemError(error: lowerError.nsError, codeLocation)

        XCTAssertTrue(systemError.errorString.contains("Lower Error"))
        XCTAssertTrue(systemError.errorString.contains("Original error message"))
        XCTAssertEqual(systemError.nsError.domain, "BASESTAGE")
        XCTAssertEqual(systemError.nsError.code, 2001)
    }

    // MARK: - Performance Tests
    func test_error_creation_performance() {
        let codeLocation = DNSBaseStageCodeLocation(self)

        measure {
            for _ in 0..<1000 {
                let error = DNSBaseStageError.unknown(codeLocation)
                _ = error.nsError
                _ = error.errorString
            }
        }
    }
}

// MARK: - DNSBaseStageCodeLocation Tests

class DNSBaseStageCodeLocationTests: XCTestCase {

    func test_domainPreface_is_correct() {
        XCTAssertEqual(DNSBaseStageCodeLocation.domainPreface, "com.doublenode.baseStage.")
    }

    func test_initialization() {
        let codeLocation = DNSBaseStageCodeLocation(self)

        XCTAssertNotNil(codeLocation)
        XCTAssertNotNil(codeLocation.userInfo)
        XCTAssertNotNil(codeLocation.failureReason)
    }

    func test_inherits_from_DNSCodeLocation() {
        let codeLocation = DNSBaseStageCodeLocation(self)

        XCTAssertTrue(codeLocation is DNSCodeLocation)
    }

    func test_type_alias_works() {
        let codeLocation: DNSCodeLocation.baseStage = DNSBaseStageCodeLocation(self)

        XCTAssertTrue(codeLocation is DNSBaseStageCodeLocation)
        XCTAssertEqual(type(of: codeLocation).domainPreface, "com.doublenode.baseStage.")
    }

    func test_userInfo_contains_location_data() {
        let codeLocation = DNSBaseStageCodeLocation(self)
        let userInfo = codeLocation.userInfo

        XCTAssertFalse(userInfo.isEmpty)
        // UserInfo should contain location-related data from DNSCodeLocation
    }
}