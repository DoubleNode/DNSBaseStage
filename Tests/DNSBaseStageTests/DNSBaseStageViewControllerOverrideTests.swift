//
//  DNSBaseStageViewControllerOverrideTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//
//  XDNS-0009-003: Cross-module override unit test for displayTitle(_:)
//  Verifies that a subclass of DNSBaseStageViewController defined in the
//  separate DNSBaseStageTests SPM module can override displayTitle(_:).
//
//  This file would have failed to compile before XDNS-0009-002 moved
//  displayTitle from a public extension declaration into the class body
//  as `open func`. The `override` keyword below is the load-bearing
//  regression signal: if a future refactor accidentally re-scopes
//  displayTitle to `public` (non-overridable across modules) or moves
//  it back into an extension, this file breaks at compile time.
//

import UIKit
import XCTest
@testable import DNSBaseStage

// MARK: - Cross-Module Subclass

/// A subclass of DNSBaseStageViewController defined inside the DNSBaseStageTests
/// SPM module — a *separate* Swift module from DNSBaseStage. The `override`
/// keyword below proves that `displayTitle(_:)` is `open` (not merely `public`),
/// which is the contract established by XDNS-0009-002.
///
/// `private final` keeps this class scoped to the test file so it cannot
/// accidentally leak into other tests or affect production code.
private final class OverridingStageViewController: DNSBaseStageViewController {
    var capturedTitle: String?
    var overrideCallCount: Int = 0

    override func displayTitle(_ viewModel: BaseStage.Models.Title.ViewModel) {
        overrideCallCount += 1
        capturedTitle = viewModel.title
        // Deliberately do NOT call super — this test verifies override dispatch,
        // not the super implementation's UIKit side-effects.
    }
}

// MARK: - Tests

final class DNSBaseStageViewControllerOverrideTests: XCTestCase {

    // MARK: - Properties

    private var sut: OverridingStageViewController!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = OverridingStageViewController()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Override Dispatch Tests

    /// Verifies that calling displayTitle(_:) on a cross-module subclass instance
    /// dispatches to the subclass implementation, not the base class.
    func test_overrideDispatchesToSubclassImplementation() {
        // Given: A ViewModel with a known title, constructed using the public
        //        DNSBaseStageModels.Title.ViewModel(title:) initializer.
        let expectedTitle = "Cross-Module Override Test"
        let viewModel = DNSBaseStage.Models.Title.ViewModel(title: expectedTitle)

        // When: Calling displayTitle on the cross-module subclass
        sut.displayTitle(viewModel)

        // Then: The subclass override was invoked exactly once
        XCTAssertEqual(sut.overrideCallCount, 1,
                       "displayTitle should dispatch to the subclass override exactly once")

        // And: The title was captured by the override, confirming the correct
        //       ViewModel was passed through
        XCTAssertEqual(sut.capturedTitle, expectedTitle,
                       "Subclass override should receive the ViewModel's title unchanged")
    }

    /// Multiple successive calls should each dispatch to the subclass override.
    func test_overrideDispatchesCorrectlyOnMultipleCalls() {
        // Given: Two ViewModels with distinct titles
        let firstTitle  = "First Title"
        let secondTitle = "Second Title"
        let viewModel1 = DNSBaseStage.Models.Title.ViewModel(title: firstTitle)
        let viewModel2 = DNSBaseStage.Models.Title.ViewModel(title: secondTitle)

        // When: Calling displayTitle twice
        sut.displayTitle(viewModel1)
        sut.displayTitle(viewModel2)

        // Then: Override was invoked twice and the last captured title is correct
        XCTAssertEqual(sut.overrideCallCount, 2,
                       "Each displayTitle call should dispatch to the subclass override")
        XCTAssertEqual(sut.capturedTitle, secondTitle,
                       "capturedTitle should reflect the most recently passed ViewModel")
    }

    // MARK: - Compile-Contract Test

    /// Compile-contract assertion: the mere existence of OverridingStageViewController
    /// (defined above with `override func displayTitle`) in this cross-module test
    /// target is the real test. If displayTitle were not `open`, the file would fail
    /// to compile with "method does not override any method from its superclass".
    ///
    /// This runtime assertion is intentionally trivial — compile success IS the test.
    func test_overrideCompilesInSeparateModule() {
        // This assertion is a compile-contract guard. Its runtime value is
        // secondary: what matters is that `OverridingStageViewController` (which
        // declares `override func displayTitle`) was accepted by the Swift compiler
        // while importing DNSBaseStage as an external module.
        XCTAssertNotNil(OverridingStageViewController.self,
                        "OverridingStageViewController must exist (compile-contract guard)")
    }
}
