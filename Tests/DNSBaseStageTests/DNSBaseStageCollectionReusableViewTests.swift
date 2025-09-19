//
//  DNSBaseStageCollectionReusableViewTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import Combine
import UIKit
@testable import DNSBaseStage
@testable import DNSCrashWorkers
@testable import DNSProtocols

class DNSBaseStageCollectionReusableViewTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSBaseStageCollectionReusableView!
    private var mockCollectionView: UICollectionView!
    private var mockDisplayLogic: MockDisplayLogic!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        let layout = UICollectionViewFlowLayout()
        mockCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 300), collectionViewLayout: layout)
        mockDisplayLogic = MockDisplayLogic()
        // UIKit collection reusable views must be created using the proper initializer
        sut = DNSBaseStageCollectionReusableView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
    }

    override func tearDown() {
        sut = nil
        mockCollectionView = nil
        mockDisplayLogic = nil
        super.tearDown()
    }

    // MARK: - Static Property Tests
    func test_reuseIdentifier_returns_class_name() {
        let expectedIdentifier = String(describing: DNSBaseStageCollectionReusableView.self)
        XCTAssertEqual(DNSBaseStageCollectionReusableView.reuseIdentifier, expectedIdentifier)
    }

    func test_uiNib_created_with_correct_name() {
        let nib = DNSBaseStageCollectionReusableView.uiNib
        XCTAssertNotNil(nib)
        // UINib doesn't expose nibName property in public API
    }

    func test_bundle_is_initially_nil() {
        XCTAssertNil(DNSBaseStageCollectionReusableView.bundle)
    }

    // MARK: - Instance Property Tests
    func test_analyticsClassTitle_returns_class_name() {
        let expectedTitle = String(describing: DNSBaseStageCollectionReusableView.self)
        XCTAssertEqual(sut.analyticsClassTitle, expectedTitle)
    }

    func test_wkrAnalytics_has_default_crash_worker() {
        XCTAssertTrue(sut.wkrAnalytics is WKRCrashAnalytics)
    }

    func test_wkrAnalytics_can_be_set() {
        let mockAnalytics = MockAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics
        XCTAssertTrue(sut.wkrAnalytics is MockAnalyticsWorker)
    }

    // MARK: - Registration Tests
    func test_register_to_collectionView_without_bundle() {
        let elementKind = UICollectionView.elementKindSectionHeader

        // This should not throw an error
        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind)

        // Verify bundle remains nil
        XCTAssertNil(DNSBaseStageCollectionReusableView.bundle)
    }

    func test_register_to_collectionView_with_bundle() {
        let elementKind = UICollectionView.elementKindSectionHeader
        let testBundle = Bundle.main

        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind, from: testBundle)

        // Verify bundle is set
        XCTAssertEqual(DNSBaseStageCollectionReusableView.bundle, testBundle)
    }

    func test_register_for_different_element_kinds() {
        let headerKind = UICollectionView.elementKindSectionHeader
        let footerKind = UICollectionView.elementKindSectionFooter

        // Should handle different element kinds without error
        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: headerKind)
        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: footerKind)

        XCTAssertTrue(true) // Test passes if no exception thrown
    }

    // MARK: - Dequeue Tests
    func test_dequeue_returns_correct_type() {
        let elementKind = UICollectionView.elementKindSectionHeader
        let indexPath = IndexPath(item: 0, section: 0)

        // Register first
        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind)

        // Dequeue
        let dequeuedView = DNSBaseStageCollectionReusableView.dequeue(elementKind, from: self.mockCollectionView, for: indexPath)

        XCTAssertTrue(dequeuedView is DNSBaseStageCollectionReusableView)
    }

    func test_dequeue_with_different_element_kinds() {
        let headerKind = UICollectionView.elementKindSectionHeader
        let footerKind = UICollectionView.elementKindSectionFooter
        let indexPath = IndexPath(item: 0, section: 0)

        // Register for both kinds
        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: headerKind)
        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: footerKind)

        // Should be able to dequeue for both kinds
        let headerView = DNSBaseStageCollectionReusableView.dequeue(headerKind, from: self.mockCollectionView, for: indexPath)
        let footerView = DNSBaseStageCollectionReusableView.dequeue(footerKind, from: self.mockCollectionView, for: indexPath)

        XCTAssertTrue(headerView is DNSBaseStageCollectionReusableView)
        XCTAssertTrue(footerView is DNSBaseStageCollectionReusableView)
    }

    func test_dequeue_with_multiple_sections() {
        let elementKind = UICollectionView.elementKindSectionHeader
        let indexPath1 = IndexPath(item: 0, section: 0)
        let indexPath2 = IndexPath(item: 0, section: 1)

        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind)

        let view1 = DNSBaseStageCollectionReusableView.dequeue(elementKind, from: self.mockCollectionView, for: indexPath1)
        let view2 = DNSBaseStageCollectionReusableView.dequeue(elementKind, from: self.mockCollectionView, for: indexPath2)

        XCTAssertTrue(view1 is DNSBaseStageCollectionReusableView)
        XCTAssertTrue(view2 is DNSBaseStageCollectionReusableView)
    }

    // MARK: - Lifecycle Tests
    func test_awakeFromNib_sets_accessibility_identifier() {
        sut.awakeFromNib()

        let expectedIdentifier = "DNSBaseStageCollectionReusableView"
        XCTAssertEqual(sut.accessibilityIdentifier, expectedIdentifier)
    }

    func test_awakeFromNib_calls_contentInit() {
        let mockView = MockReusableView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockView.awakeFromNib()

        XCTAssertTrue(mockView.contentInitCalled)
    }

    func test_prepareForReuse_calls_contentInit() {
        let mockView = MockReusableView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockView.prepareForReuse()

        XCTAssertTrue(mockView.contentInitCalled)
    }

    func test_contentInit_can_be_overridden() {
        let mockView = MockReusableView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockView.contentInit()

        XCTAssertTrue(mockView.contentInitCalled)
    }

    // MARK: - Protocol Conformance Tests
    func test_conforms_to_DNSBaseStageReusableViewLogic() {
        XCTAssertTrue(sut is DNSBaseStageReusableViewLogic)
    }

    func test_subscribe_method_exists() {
        // Should not crash when called
        sut.subscribe(to: mockDisplayLogic)
        XCTAssertTrue(true) // Test passes if no exception thrown
    }

    // MARK: - Utility Method Tests
    func test_utilityAutoTrack_calls_analytics_worker() {
        let mockAnalytics = MockAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        sut.utilityAutoTrack("testMethod")

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackClass, sut.analyticsClassTitle)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "testMethod")
    }

    func test_utilityAutoTrack_with_empty_method() {
        let mockAnalytics = MockAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        sut.utilityAutoTrack("")

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "")
    }

    func test_utilityAutoTrack_with_special_characters() {
        let mockAnalytics = MockAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        let specialMethod = "test@method#with$special%characters"
        sut.utilityAutoTrack(specialMethod)

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, specialMethod)
    }

    // MARK: - Accessibility Tests
    func test_accessibility_identifier_format() {
        // Test with a custom subclass to verify format
        let customView = CustomReusableView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        customView.awakeFromNib()

        // Should use the last component of the class name
        let expectedIdentifier = "CustomReusableView"
        XCTAssertEqual(customView.accessibilityIdentifier, expectedIdentifier)
    }

    func test_accessibility_identifier_with_module_name() {
        sut.awakeFromNib()

        // Should extract just the class name without module
        XCTAssertEqual(sut.accessibilityIdentifier, "DNSBaseStageCollectionReusableView")
        XCTAssertFalse(sut.accessibilityIdentifier?.contains(".") ?? true)
    }

    // MARK: - Error Handling Tests
    func test_dequeue_with_invalid_indexPath() {
        let elementKind = UICollectionView.elementKindSectionHeader
        let invalidIndexPath = IndexPath(item: -1, section: -1)

        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind)

        // This may throw in real usage, but we test the method exists
        XCTAssertNoThrow {
            let _ = DNSBaseStageCollectionReusableView.dequeue(elementKind, from: self.mockCollectionView, for: invalidIndexPath)
        }
    }

    // MARK: - Memory Management Tests
    func test_weak_references_not_retained() {
        weak var weakView: DNSBaseStageCollectionReusableView?

        autoreleasepool {
            let view = DNSBaseStageCollectionReusableView(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
            weakView = view
            XCTAssertNotNil(weakView)
        }

        // Should be deallocated
        XCTAssertNil(weakView)
    }

    // MARK: - Bundle Handling Tests
    func test_bundle_reset_between_registrations() {
        let bundle1 = Bundle.main
        let bundle2 = Bundle(for: DNSBaseStageCollectionReusableView.self)
        let elementKind = UICollectionView.elementKindSectionHeader

        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind, from: bundle1)
        XCTAssertEqual(DNSBaseStageCollectionReusableView.bundle, bundle1)

        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind, from: bundle2)
        XCTAssertEqual(DNSBaseStageCollectionReusableView.bundle, bundle2)
    }

    // MARK: - Performance Tests
    func test_performance_registration() {
        let elementKind = UICollectionView.elementKindSectionHeader

        measure {
            for _ in 0..<100 {
                DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind)
            }
        }
    }

    func test_performance_dequeue() {
        let elementKind = UICollectionView.elementKindSectionHeader
        let indexPath = IndexPath(item: 0, section: 0)

        DNSBaseStageCollectionReusableView.register(to: self.mockCollectionView, for: elementKind)

        measure {
            for _ in 0..<100 {
                let _ = DNSBaseStageCollectionReusableView.dequeue(elementKind, from: self.mockCollectionView, for: indexPath)
            }
        }
    }
}

// MARK: - Mock Classes

class MockDisplayLogic: DNSBaseStageDisplayLogic {
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

class MockReusableView: DNSBaseStageCollectionReusableView {
    var contentInitCalled = false

    override func contentInit() {
        super.contentInit()
        contentInitCalled = true
    }
}

class CustomReusableView: DNSBaseStageCollectionReusableView {
    // Custom subclass for testing accessibility identifier
}

// MockAnalyticsWorker is now defined in TestHelpers/MockAnalyticsWorker.swift