//
//  DNSBaseStageError.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSError
import Foundation

public extension DNSError {
    typealias BaseStage = DNSBaseStageError
}
public enum DNSBaseStageError: DNSError {
    // Common Errors
    case unknown(_ codeLocation: DNSCodeLocation)
    case notImplemented(_ codeLocation: DNSCodeLocation)
    case notFound(field: String, value: String, _ codeLocation: DNSCodeLocation)
    case invalidParameters(parameters: [String], _ codeLocation: DNSCodeLocation)
    case lowerError(error: Error, _ codeLocation: DNSCodeLocation)
    // Domain-Specific Errors
    case systemError(error: Error, _ codeLocation: DNSCodeLocation)
    case webViewError(error: Error, _ codeLocation: DNSCodeLocation)
    case calendarError(error: Error, _ codeLocation: DNSCodeLocation)
    case calendarDenied(_ codeLocation: DNSCodeLocation)
    case mailError(error: Error, _ codeLocation: DNSCodeLocation)

    public static let domain = "BASESTAGE"
    public enum Code: Int
    {
        // Common Errors
        case unknown = 1001
        case notImplemented = 1002
        case notFound = 1003
        case invalidParameters = 1004
        case lowerError = 1005
        // Domain-Specific Errors
        case systemError = 2001
        case webViewError = 2002
        case calendarError = 2003
        case calendarDenied = 2004
        case mailError = 2005
    }
    
    public var nsError: NSError! {
        switch self {
            // Common Errors
        case .unknown(let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.unknown.rawValue,
                                userInfo: userInfo)
        case .notImplemented(let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.notImplemented.rawValue,
                                userInfo: userInfo)
        case .notFound(let field, let value, let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo["field"] = field
            userInfo["value"] = value
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.notFound.rawValue,
                                userInfo: userInfo)
        case .invalidParameters(let parameters, let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            userInfo["Parameters"] = parameters
            return NSError.init(domain: Self.domain,
                                code: Self.Code.invalidParameters.rawValue,
                                userInfo: userInfo)
        case .lowerError(let error, let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo["Error"] = error
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.lowerError.rawValue,
                                userInfo: userInfo)
            // Domain-Specific Errors
        case .systemError(let error, let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo["Error"] = error
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.systemError.rawValue,
                                userInfo: userInfo)
        case .webViewError(let error, let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo["Error"] = error
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.webViewError.rawValue,
                                userInfo: userInfo)
        case .calendarError(let error, let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo["Error"] = error
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.calendarError.rawValue,
                                userInfo: userInfo)
        case .calendarDenied(let codeLocation):
            let userInfo = codeLocation.userInfo
            return NSError.init(domain: Self.domain,
                                code: Self.Code.calendarDenied.rawValue,
                                userInfo: userInfo)
        case .mailError(let error, let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo["Error"] = error
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.mailError.rawValue,
                                userInfo: userInfo)
        }
    }
    public var errorDescription: String? {
        return self.errorString
    }
    public var errorString: String {
        switch self {
            // Common Errors
        case .unknown:
            return String(format: NSLocalizedString("BASESTAGE-Unknown Error%@", comment: ""),
                          " (\(Self.domain):\(Self.Code.unknown.rawValue))")
        case .notImplemented:
            return String(format: NSLocalizedString("BASESTAGE-Not Implemented%@", comment: ""),
                          " (\(Self.domain):\(Self.Code.notImplemented.rawValue))")
        case .notFound(let field, let value, _):
            return String(format: NSLocalizedString("BASESTAGE-Not Found%@%@%@", comment: ""),
                          "\(field)", "\(value)",
                          "(\(Self.domain):\(Self.Code.notFound.rawValue))")
        case .invalidParameters(let parameters, _):
            let parametersString = parameters.reduce("") { $0 + ($0.isEmpty ? "" : ", ") + $1 }
            return String(format: NSLocalizedString("BASESTAGE-Invalid Parameters%@%@", comment: ""),
                          "\(parametersString)",
                          " (\(Self.domain):\(Self.Code.invalidParameters.rawValue))")
        case .lowerError(let error, _):
            return String(format: NSLocalizedString("BASESTAGE-Lower Error%@%@", comment: ""),
                          error.localizedDescription,
                          " (\(Self.domain):\(Self.Code.lowerError.rawValue))")
            // Domain-Specific Errors
        case .systemError(let error, _):
            return String(format: NSLocalizedString("BASESTAGE-System Error%@%@", comment: ""),
                          error.localizedDescription,
                          " (\(Self.domain):\(Self.Code.systemError.rawValue))")
        case .webViewError(let error, _):
            return String(format: NSLocalizedString("BASESTAGE-WebView Error%@%@", comment: ""),
                          error.localizedDescription,
                          " (\(Self.domain):\(Self.Code.webViewError.rawValue))")
        case .calendarError(let error, _):
            return String(format: NSLocalizedString("BASESTAGE-Calendar Error%@%@", comment: ""),
                          error.localizedDescription,
                          " (\(Self.domain):\(Self.Code.calendarError.rawValue))")
        case .calendarDenied(_):
            return String(format: NSLocalizedString("BASESTAGE-Calendar Denied%@", comment: ""),
                          " (\(Self.domain):\(Self.Code.calendarError.rawValue))")
        case .mailError(let error, _):
            return String(format: NSLocalizedString("BASESTAGE-Mail Error%@%@", comment: ""),
                          error.localizedDescription,
                          " (\(Self.domain):\(Self.Code.mailError.rawValue))")
        }
    }
    public var failureReason: String? {
        switch self {
            // Common Errors
        case .unknown(let codeLocation),
             .notImplemented(let codeLocation),
             .notFound(_, _, let codeLocation),
             .invalidParameters(_, let codeLocation),
             .lowerError(_, let codeLocation),
            // Domain-Specific Errors
             .systemError(_, let codeLocation),
             .webViewError(_, let codeLocation),
             .calendarError(_, let codeLocation),
             .calendarDenied(let codeLocation),
             .mailError(_, let codeLocation):
            return codeLocation.failureReason
        }
    }
}
