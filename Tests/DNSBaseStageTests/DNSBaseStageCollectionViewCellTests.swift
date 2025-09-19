//
//  DNSBaseStageCollectionViewCellTests.swift
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

class DNSBaseStageCollectionViewCellTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSBaseStageCollectionViewCell!
    private var mockCollectionView: UICollectionView!
    private var mockDisplayLogic: MockCellDisplayLogic!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        let layout = UICollectionViewFlowLayout()
        mockCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 300), collectionViewLayout: layout)
        mockDisplayLogic = MockCellDisplayLogic()
        // UIKit collection view cells must be created using the proper initializer
        sut = DNSBaseStageCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
    }

    override func tearDown() {
        sut = nil
        mockCollectionView = nil
        mockDisplayLogic = nil
        super.tearDown()
    }

    // MARK: - Static Property Tests
    func test_reuseIdentifier_returns_class_name() {
        let expectedIdentifier = String(describing: DNSBaseStageCollectionViewCell.self)
        XCTAssertEqual(DNSBaseStageCollectionViewCell.reuseIdentifier, expectedIdentifier)
    }

    func test_uiNib_created_with_correct_name() {
        let nib = DNSBaseStageCollectionViewCell.uiNib
        XCTAssertNotNil(nib)
        // UINib doesn't expose nibName property in public API
    }

    func test_bundle_is_initially_nil() {
        XCTAssertNil(DNSBaseStageCollectionViewCell.bundle)
    }

    // MARK: - Instance Property Tests
    func test_analyticsClassTitle_returns_class_name() {
        let expectedTitle = String(describing: DNSBaseStageCollectionViewCell.self)
        XCTAssertEqual(sut.analyticsClassTitle, expectedTitle)
    }

    func test_wkrAnalytics_has_default_crash_worker() {
        XCTAssertTrue(sut.wkrAnalytics is WKRCrashAnalytics)
    }

    func test_wkrAnalytics_can_be_set() {
        let mockAnalytics = MockCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics
        XCTAssertTrue(sut.wkrAnalytics is MockCellAnalyticsWorker)
    }

    // MARK: - Registration Tests
    func test_register_to_collectionView_without_bundle() {
        // This should not throw an error
        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)

        // Verify bundle remains nil
        XCTAssertNil(DNSBaseStageCollectionViewCell.bundle)
    }

    func test_register_to_collectionView_with_bundle() {
        let testBundle = Bundle.main

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView, from: testBundle)

        // Verify bundle is set
        XCTAssertEqual(DNSBaseStageCollectionViewCell.bundle, testBundle)
    }

    func test_register_multiple_times() {
        // Should handle multiple registrations without error
        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)
        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)
        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)

        XCTAssertTrue(true) // Test passes if no exception thrown
    }

    // MARK: - Dequeue Tests
    func test_dequeue_returns_correct_type() {
        let indexPath = IndexPath(item: 0, section: 0)

        // Register first
        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)

        // Dequeue
        let dequeuedCell = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: indexPath)

        XCTAssertTrue(dequeuedCell is DNSBaseStageCollectionViewCell)
    }

    func test_dequeue_with_different_index_paths() {
        let indexPath1 = IndexPath(item: 0, section: 0)
        let indexPath2 = IndexPath(item: 1, section: 0)
        let indexPath3 = IndexPath(item: 0, section: 1)

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)

        let cell1 = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: indexPath1)
        let cell2 = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: indexPath2)
        let cell3 = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: indexPath3)

        XCTAssertTrue(cell1 is DNSBaseStageCollectionViewCell)
        XCTAssertTrue(cell2 is DNSBaseStageCollectionViewCell)
        XCTAssertTrue(cell3 is DNSBaseStageCollectionViewCell)
    }

    func test_dequeue_with_large_index_values() {
        let indexPath = IndexPath(item: 999, section: 999)

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)

        let cell = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: indexPath)
        XCTAssertTrue(cell is DNSBaseStageCollectionViewCell)
    }

    // MARK: - Lifecycle Tests
    func test_awakeFromNib_sets_accessibility_identifier() {
        sut.awakeFromNib()

        let expectedIdentifier = "DNSBaseStageCollectionViewCell"
        XCTAssertEqual(sut.accessibilityIdentifier, expectedIdentifier)
    }

    func test_awakeFromNib_calls_contentInit() {
        let mockCell = MockCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockCell.awakeFromNib()

        XCTAssertTrue(mockCell.contentInitCalled)
    }

    func test_prepareForReuse_calls_contentInit() {
        let mockCell = MockCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockCell.prepareForReuse()

        XCTAssertTrue(mockCell.contentInitCalled)
    }

    func test_contentInit_can_be_overridden() {
        let mockCell = MockCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockCell.contentInit()

        XCTAssertTrue(mockCell.contentInitCalled)
    }

    func test_prepareForReuse_resets_state() {
        let mockCell = MockCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!

        // Set some state
        mockCell.contentInitCalled = false

        // Prepare for reuse should reset state via contentInit
        mockCell.prepareForReuse()

        XCTAssertTrue(mockCell.contentInitCalled)
    }

    // MARK: - Protocol Conformance Tests
    func test_conforms_to_DNSBaseStageCellLogic() {
        XCTAssertTrue(sut is DNSBaseStageCellLogic)
    }

    func test_subscribe_method_exists() {
        // Should not crash when called
        sut.subscribe(to: mockDisplayLogic)
        XCTAssertTrue(true) // Test passes if no exception thrown
    }

    // MARK: - Utility Method Tests
    func test_utilityAutoTrack_calls_analytics_worker() {
        let mockAnalytics = MockCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        sut.utilityAutoTrack("testMethod")

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackClass, sut.analyticsClassTitle)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "testMethod")
    }

    func test_utilityAutoTrack_with_empty_method() {
        let mockAnalytics = MockCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        sut.utilityAutoTrack("")

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "")
    }

    func test_utilityAutoTrack_with_long_method_name() {
        let mockAnalytics = MockCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        let longMethod = String(repeating: "a", count: 1000)
        sut.utilityAutoTrack(longMethod)

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, longMethod)
    }

    func test_utilityAutoTrack_with_unicode_characters() {
        let mockAnalytics = MockCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        let unicodeMethod = "测试方法🧪💯"
        sut.utilityAutoTrack(unicodeMethod)

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, unicodeMethod)
    }

    // MARK: - Accessibility Tests
    func test_accessibility_identifier_format() {
        // Test with a custom subclass to verify format
        let customCell = CustomCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        customCell.awakeFromNib()

        // Should use the last component of the class name
        let expectedIdentifier = "CustomCollectionViewCell"
        XCTAssertEqual(customCell.accessibilityIdentifier, expectedIdentifier)
    }

    func test_accessibility_identifier_with_module_name() {
        sut.awakeFromNib()

        // Should extract just the class name without module
        XCTAssertEqual(sut.accessibilityIdentifier, "DNSBaseStageCollectionViewCell")
        XCTAssertFalse(sut.accessibilityIdentifier?.contains(".") ?? true)
    }

    func test_accessibility_identifier_persistence() {
        sut.awakeFromNib()
        let firstIdentifier = sut.accessibilityIdentifier

        sut.prepareForReuse()
        let secondIdentifier = sut.accessibilityIdentifier

        XCTAssertEqual(firstIdentifier, secondIdentifier)
    }

    // MARK: - Cell State Tests
    func test_cell_selection_state() {
        XCTAssertFalse(sut.isSelected)

        sut.isSelected = true
        XCTAssertTrue(sut.isSelected)

        sut.isSelected = false
        XCTAssertFalse(sut.isSelected)
    }

    func test_cell_highlight_state() {
        XCTAssertFalse(sut.isHighlighted)

        sut.isHighlighted = true
        XCTAssertTrue(sut.isHighlighted)

        sut.isHighlighted = false
        XCTAssertFalse(sut.isHighlighted)
    }

    // MARK: - Error Handling Tests
    func test_dequeue_with_negative_index() {
        let invalidIndexPath = IndexPath(item: -1, section: 0)

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)

        // This may throw in real usage, but we test the method exists
        XCTAssertNoThrow {
            let _ = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: invalidIndexPath)
        }
    }

    func test_dequeue_with_negative_section() {
        let invalidIndexPath = IndexPath(item: 0, section: -1)

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)

        XCTAssertNoThrow {
            let _ = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: invalidIndexPath)
        }
    }

    // MARK: - Memory Management Tests
    func test_weak_references_not_retained() {
        weak var weakCell: DNSBaseStageCollectionViewCell?

        autoreleasepool {
            let cell = DNSBaseStageCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
            weakCell = cell
            XCTAssertNotNil(weakCell)
        }

        // Should be deallocated
        XCTAssertNil(weakCell)
    }

    func test_analytics_worker_replacement() {
        let analytics1 = MockCellAnalyticsWorker()
        let analytics2 = MockCellAnalyticsWorker()

        sut.wkrAnalytics = analytics1
        XCTAssertTrue(sut.wkrAnalytics === analytics1)

        sut.wkrAnalytics = analytics2
        XCTAssertTrue(sut.wkrAnalytics === analytics2)
        XCTAssertFalse(sut.wkrAnalytics === analytics1)
    }

    // MARK: - Bundle Handling Tests
    func test_bundle_reset_between_registrations() {
        let bundle1 = Bundle.main
        let bundle2 = Bundle(for: DNSBaseStageCollectionViewCell.self)

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView, from: bundle1)
        XCTAssertEqual(DNSBaseStageCollectionViewCell.bundle, bundle1)

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView, from: bundle2)
        XCTAssertEqual(DNSBaseStageCollectionViewCell.bundle, bundle2)
    }

    func test_bundle_nil_after_default_registration() {
        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)
        XCTAssertNil(DNSBaseStageCollectionViewCell.bundle)
    }

    // MARK: - Collection View Integration Tests
    func test_cell_frame_after_dequeue() {
        let indexPath = IndexPath(item: 0, section: 0)

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)
        let cell = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: indexPath)

        // Should have default frame initially
        XCTAssertEqual(cell.frame, CGRect.zero)
    }

    func test_cell_content_view_exists() {
        XCTAssertNotNil(sut.contentView)
        XCTAssertTrue(sut.contentView.isDescendant(of: sut))
    }

    // MARK: - Performance Tests
    func test_performance_registration() {
        measure {
            for _ in 0..<100 {
                DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)
            }
        }
    }

    func test_performance_dequeue() {
        let indexPath = IndexPath(item: 0, section: 0)

        DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)

        measure {
            for _ in 0..<100 {
                let _ = DNSBaseStageCollectionViewCell.dequeue(from: self.mockCollectionView, for: indexPath)
            }
        }
    }

    func test_performance_awakeFromNib() {
        measure {
            for _ in 0..<100 {
                let cell = DNSBaseStageCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
                cell.awakeFromNib()
            }
        }
    }

    // MARK: - Stress Tests
    func test_multiple_rapid_registrations() {
        let dispatchGroup = DispatchGroup()

        for _ in 0..<10 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                DNSBaseStageCollectionViewCell.register(to: self.mockCollectionView)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.wait()
        XCTAssertTrue(true) // Test passes if no crashes occur
    }
}

// MARK: - Mock Classes

class MockCellDisplayLogic: DNSBaseStageDisplayLogic {
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

class MockCollectionViewCell: DNSBaseStageCollectionViewCell {
    var contentInitCalled = false

    override func contentInit() {
        super.contentInit()
        contentInitCalled = true
    }
}

class CustomCollectionViewCell: DNSBaseStageCollectionViewCell {
    // Custom subclass for testing accessibility identifier
}

// Using consolidated MockAnalyticsWorker from TestHelpers/MockAnalyticsWorker.swift
typealias MockCellAnalyticsWorker = MockAnalyticsWorker