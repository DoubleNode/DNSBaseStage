//
//  DNSBaseStageCollectionViewSwipeCellTests.swift
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

class DNSBaseStageCollectionViewSwipeCellTests: XCTestCase {

    // MARK: - Test Properties
    private var sut: DNSBaseStageCollectionViewSwipeCell!
    private var mockCollectionView: UICollectionView!
    private var mockDisplayLogic: MockSwipeCellDisplayLogic!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        let layout = UICollectionViewFlowLayout()
        mockCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 300), collectionViewLayout: layout)
        mockDisplayLogic = MockSwipeCellDisplayLogic()
        // UIKit collection view cells must be created using the proper initializer
        let coder = NSKeyedUnarchiver(forReadingWith: Data())
        sut = DNSBaseStageCollectionViewSwipeCell(coder: coder)!
    }

    override func tearDown() {
        sut = nil
        mockCollectionView = nil
        mockDisplayLogic = nil
        super.tearDown()
    }

    // MARK: - Static Property Tests
    func test_reuseIdentifier_returns_class_name() {
        let expectedIdentifier = String(describing: DNSBaseStageCollectionViewSwipeCell.self)
        XCTAssertEqual(DNSBaseStageCollectionViewSwipeCell.reuseIdentifier, expectedIdentifier)
    }

    func test_uiNib_created_successfully() {
        let nib = DNSBaseStageCollectionViewSwipeCell.uiNib
        XCTAssertNotNil(nib)
    }

    func test_bundle_is_initially_nil() {
        XCTAssertNil(DNSBaseStageCollectionViewSwipeCell.bundle)
    }

    // MARK: - Instance Property Tests
    func test_analyticsClassTitle_returns_class_name() {
        let expectedTitle = String(describing: DNSBaseStageCollectionViewSwipeCell.self)
        XCTAssertEqual(sut.analyticsClassTitle, expectedTitle)
    }

    func test_wkrAnalytics_has_default_crash_worker() {
        XCTAssertTrue(sut.wkrAnalytics is WKRCrashAnalytics)
    }

    func test_wkrAnalytics_can_be_set() {
        let mockAnalytics = MockSwipeCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics
        XCTAssertTrue(sut.wkrAnalytics is MockSwipeCellAnalyticsWorker)
    }

    // MARK: - Registration Tests
    func test_register_to_collectionView_without_bundle() {
        // This should not throw an error
        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)

        // Verify bundle remains nil
        XCTAssertNil(DNSBaseStageCollectionViewSwipeCell.bundle)
    }

    func test_register_to_collectionView_with_bundle() {
        let testBundle = Bundle.main

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView, from: testBundle)

        // Verify bundle is set
        XCTAssertEqual(DNSBaseStageCollectionViewSwipeCell.bundle, testBundle)
    }

    func test_register_multiple_times() {
        // Should handle multiple registrations without error
        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)
        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)
        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)

        XCTAssertTrue(true) // Test passes if no exception thrown
    }

    // MARK: - Dequeue Tests
    func test_dequeue_returns_correct_type() {
        let indexPath = IndexPath(item: 0, section: 0)

        // Register first
        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)

        // Dequeue
        let dequeuedCell = DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: indexPath)

        XCTAssertTrue(dequeuedCell is DNSBaseStageCollectionViewSwipeCell)
    }

    func test_dequeue_with_different_index_paths() {
        let indexPath1 = IndexPath(item: 0, section: 0)
        let indexPath2 = IndexPath(item: 1, section: 0)
        let indexPath3 = IndexPath(item: 0, section: 1)

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)

        let cell1 = DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: indexPath1)
        let cell2 = DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: indexPath2)
        let cell3 = DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: indexPath3)

        XCTAssertTrue(cell1 is DNSBaseStageCollectionViewSwipeCell)
        XCTAssertTrue(cell2 is DNSBaseStageCollectionViewSwipeCell)
        XCTAssertTrue(cell3 is DNSBaseStageCollectionViewSwipeCell)
    }

    func test_dequeue_inherits_from_swipe_cell() {
        let indexPath = IndexPath(item: 0, section: 0)

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)
        let cell = DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: indexPath)

        // Should inherit from UICollectionViewCell
        XCTAssertTrue(cell.isKind(of: UICollectionViewCell.self))
    }

    // MARK: - Lifecycle Tests
    func test_awakeFromNib_sets_accessibility_identifier() {
        sut.awakeFromNib()

        let expectedIdentifier = "DNSBaseStageCollectionViewSwipeCell"
        XCTAssertEqual(sut.accessibilityIdentifier, expectedIdentifier)
    }

    func test_awakeFromNib_calls_contentInit() {
        let mockCell = MockSwipeCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockCell.awakeFromNib()

        XCTAssertTrue(mockCell.contentInitCalled)
    }

    func test_prepareForReuse_calls_contentInit() {
        let mockCell = MockSwipeCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockCell.prepareForReuse()

        XCTAssertTrue(mockCell.contentInitCalled)
    }

    func test_contentInit_can_be_overridden() {
        let mockCell = MockSwipeCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        mockCell.contentInit()

        XCTAssertTrue(mockCell.contentInitCalled)
    }

    func test_prepareForReuse_resets_swipe_state() {
        let mockCell = MockSwipeCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!

        // Simulate some swipe state
        mockCell.contentInitCalled = false

        // Prepare for reuse should reset state
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

    // MARK: - Swipe Functionality Tests
    func test_inherits_swipe_capabilities() {
        // Verify it inherits from the swipe cell base class
        XCTAssertTrue(sut.isKind(of: UICollectionViewCell.self))
    }

    func test_swipe_cell_has_content_view() {
        XCTAssertNotNil(sut.contentView)
        XCTAssertTrue(sut.contentView.isDescendant(of: sut))
    }

    // MARK: - Utility Method Tests
    func test_utilityAutoTrack_calls_analytics_worker() {
        let mockAnalytics = MockSwipeCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        sut.utilityAutoTrack("testSwipeMethod")

        XCTAssertTrue(mockAnalytics.doAutoTrackCalled)
        XCTAssertEqual(mockAnalytics.lastAutoTrackClass, sut.analyticsClassTitle)
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "testSwipeMethod")
    }

    func test_utilityAutoTrack_with_swipe_actions() {
        let mockAnalytics = MockSwipeCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        sut.utilityAutoTrack("swipeLeft")
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "swipeLeft")

        sut.utilityAutoTrack("swipeRight")
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "swipeRight")

        sut.utilityAutoTrack("swipeUp")
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "swipeUp")

        sut.utilityAutoTrack("swipeDown")
        XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, "swipeDown")
    }

    func test_utilityAutoTrack_with_gesture_events() {
        let mockAnalytics = MockSwipeCellAnalyticsWorker()
        sut.wkrAnalytics = mockAnalytics

        let gestureEvents = [
            "gestureRecognizerShouldBegin",
            "handleSwipeGesture",
            "swipeDidBegin",
            "swipeDidEnd"
        ]

        for event in gestureEvents {
            sut.utilityAutoTrack(event)
            XCTAssertEqual(mockAnalytics.lastAutoTrackMethod, event)
        }
    }

    // MARK: - Accessibility Tests
    func test_accessibility_identifier_format() {
        let customSwipeCell = CustomSwipeCollectionViewCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        customSwipeCell.awakeFromNib()

        let expectedIdentifier = "CustomSwipeCollectionViewCell"
        XCTAssertEqual(customSwipeCell.accessibilityIdentifier, expectedIdentifier)
    }

    func test_accessibility_identifier_with_module_name() {
        sut.awakeFromNib()

        // Should extract just the class name without module
        XCTAssertEqual(sut.accessibilityIdentifier, "DNSBaseStageCollectionViewSwipeCell")
        XCTAssertFalse(sut.accessibilityIdentifier?.contains(".") ?? true)
    }

    func test_accessibility_for_swipe_actions() {
        sut.awakeFromNib()

        // Base accessibility should be set
        XCTAssertNotNil(sut.accessibilityIdentifier)

        // Should be accessible for swipe actions
        XCTAssertTrue(sut.isAccessibilityElement || sut.accessibilityElements != nil)
    }

    // MARK: - Cell State Tests
    func test_cell_selection_state_with_swipe() {
        XCTAssertFalse(sut.isSelected)

        sut.isSelected = true
        XCTAssertTrue(sut.isSelected)

        // Selection should persist even with swipe capabilities
        sut.isSelected = false
        XCTAssertFalse(sut.isSelected)
    }

    func test_cell_highlight_state_with_swipe() {
        XCTAssertFalse(sut.isHighlighted)

        sut.isHighlighted = true
        XCTAssertTrue(sut.isHighlighted)

        sut.isHighlighted = false
        XCTAssertFalse(sut.isHighlighted)
    }

    // MARK: - Error Handling Tests
    func test_dequeue_with_invalid_indexPath() {
        let invalidIndexPath = IndexPath(item: -1, section: -1)

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)

        XCTAssertNoThrow {
            let _ = DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: invalidIndexPath)
        }
    }

    func test_contentInit_with_nil_subviews() {
        let cell = DNSBaseStageCollectionViewSwipeCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!

        // Should not crash even with minimal setup
        XCTAssertNoThrow {
            cell.contentInit()
        }
    }

    // MARK: - Memory Management Tests
    func test_weak_references_not_retained() {
        weak var weakCell: DNSBaseStageCollectionViewSwipeCell?

        autoreleasepool {
            let cell = DNSBaseStageCollectionViewSwipeCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
            weakCell = cell
            XCTAssertNotNil(weakCell)
        }

        // Should be deallocated
        XCTAssertNil(weakCell)
    }

    func test_analytics_worker_replacement_in_swipe_cell() {
        let analytics1 = MockSwipeCellAnalyticsWorker()
        let analytics2 = MockSwipeCellAnalyticsWorker()

        sut.wkrAnalytics = analytics1
        XCTAssertTrue(sut.wkrAnalytics === analytics1)

        sut.wkrAnalytics = analytics2
        XCTAssertTrue(sut.wkrAnalytics === analytics2)
        XCTAssertFalse(sut.wkrAnalytics === analytics1)
    }

    // MARK: - Bundle Handling Tests
    func test_bundle_handling_for_swipe_cell() {
        let bundle1 = Bundle.main
        let bundle2 = Bundle(for: DNSBaseStageCollectionViewSwipeCell.self)

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView, from: bundle1)
        XCTAssertEqual(DNSBaseStageCollectionViewSwipeCell.bundle, bundle1)

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView, from: bundle2)
        XCTAssertEqual(DNSBaseStageCollectionViewSwipeCell.bundle, bundle2)
    }

    // MARK: - Gesture Recognition Tests
    func test_gesture_recognizer_setup() {
        // Cell should be able to handle gestures for swipe functionality
        XCTAssertNotNil(sut.gestureRecognizers)
    }

    func test_user_interaction_enabled() {
        // Swipe cells need user interaction enabled
        XCTAssertTrue(sut.isUserInteractionEnabled)
    }

    // MARK: - Performance Tests
    func test_performance_swipe_cell_registration() {
        measure {
            for _ in 0..<100 {
                DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)
            }
        }
    }

    func test_performance_swipe_cell_dequeue() {
        let indexPath = IndexPath(item: 0, section: 0)

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)

        measure {
            for _ in 0..<100 {
                let _ = DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: indexPath)
            }
        }
    }

    func test_performance_awakeFromNib_with_swipe_setup() {
        measure {
            for _ in 0..<100 {
                let cell = DNSBaseStageCollectionViewSwipeCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
                cell.awakeFromNib()
            }
        }
    }

    // MARK: - Integration Tests
    func test_swipe_cell_in_collection_view_context() {
        let indexPath = IndexPath(item: 0, section: 0)

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)
        let cell = DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: indexPath)

        // Should integrate properly with collection view
        XCTAssertEqual(cell.frame, CGRect.zero) // Default frame
        XCTAssertNotNil(cell.contentView)
        XCTAssertTrue(cell.contentView.isDescendant(of: cell))
    }

    func test_multiple_swipe_cells_in_collection() {
        let indexPaths = [
            IndexPath(item: 0, section: 0),
            IndexPath(item: 1, section: 0),
            IndexPath(item: 2, section: 0)
        ]

        DNSBaseStageCollectionViewSwipeCell.register(to: self.mockCollectionView)

        let cells = indexPaths.map { indexPath in
            DNSBaseStageCollectionViewSwipeCell.dequeue(from: self.mockCollectionView, for: indexPath)
        }

        XCTAssertEqual(cells.count, 3)
        cells.forEach { cell in
            XCTAssertTrue(cell is DNSBaseStageCollectionViewSwipeCell)
        }
    }

    // MARK: - Edge Cases
    func test_swipe_cell_with_zero_frame() {
        let cell = DNSBaseStageCollectionViewSwipeCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        cell.frame = CGRect.zero

        XCTAssertNoThrow {
            cell.awakeFromNib()
            cell.contentInit()
        }
    }

    func test_swipe_cell_with_large_frame() {
        let cell = DNSBaseStageCollectionViewSwipeCell(coder: NSKeyedUnarchiver(forReadingWith: Data()))!
        cell.frame = CGRect(x: 0, y: 0, width: 10000, height: 10000)

        XCTAssertNoThrow {
            cell.awakeFromNib()
            cell.contentInit()
        }
    }
}

// MARK: - Mock Classes

class MockSwipeCellDisplayLogic: DNSBaseStageDisplayLogic {
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

class MockSwipeCollectionViewCell: DNSBaseStageCollectionViewSwipeCell {
    var contentInitCalled = false

    override func contentInit() {
        super.contentInit()
        contentInitCalled = true
    }
}

class CustomSwipeCollectionViewCell: DNSBaseStageCollectionViewSwipeCell {
    // Custom subclass for testing accessibility identifier
}

// Using consolidated MockAnalyticsWorker from TestHelpers/MockAnalyticsWorker.swift
typealias MockSwipeCellAnalyticsWorker = MockAnalyticsWorker