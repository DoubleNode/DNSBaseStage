//
//  MockAnalyticsWorker.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import Foundation
import DNSCore
import DNSProtocols
import DNSDataObjects
@testable import DNSCrashWorkers

/// Consolidated MockAnalyticsWorker that inherits from WKRCrashAnalytics and adds test tracking capabilities.
/// This single implementation should be used across all test files to avoid duplication and compilation errors.
public class MockAnalyticsWorker: WKRCrashAnalytics {

    // MARK: - Test Tracking Properties
    public var doAutoTrackCalled = false
    public var lastAutoTrackClass: String?
    public var lastAutoTrackMethod: String?
    public var lastAutoTrackProperties: DNSDataDictionary?
    public var lastAutoTrackOptions: DNSDataDictionary?

    // MARK: - Initialization
    public required init() {
        super.init()
    }

    // MARK: - Internal Work Methods (Override)
    override open func intDoAutoTrack(class classTitle: String, method: String,
                                      properties: DNSDataDictionary, options: DNSDataDictionary,
                                      then resultBlock: DNSPTCLResultBlock?) -> WKRPTCLAnalyticsResVoid {
        doAutoTrackCalled = true
        lastAutoTrackClass = classTitle
        lastAutoTrackMethod = method
        lastAutoTrackProperties = properties
        lastAutoTrackOptions = options
        _ = resultBlock?(.completed)
        return .success(())
    }

    // MARK: - Utility Methods for Testing
    public func reset() {
        doAutoTrackCalled = false
        lastAutoTrackClass = nil
        lastAutoTrackMethod = nil
        lastAutoTrackProperties = nil
        lastAutoTrackOptions = nil
    }
}