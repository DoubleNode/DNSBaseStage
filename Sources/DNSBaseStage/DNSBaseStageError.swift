//
//  DNSBaseStageError.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSError
import Foundation

public enum DNSBaseStageError: Error
{
    case unknown(_ codeLocation: DNSCodeLocation)
    case systemError(error: Error, _ codeLocation: DNSCodeLocation)
    case webViewError(error: Error, _ codeLocation: DNSCodeLocation)
    case calendarError(error: Error, _ codeLocation: DNSCodeLocation)
    case calendarDenied(_ codeLocation: DNSCodeLocation)
    case mailError(error: Error, _ codeLocation: DNSCodeLocation)
}
extension DNSBaseStageError: DNSError {
    public static let domain = "DNSBASESTAGE"
    public enum Code: Int
    {
        case unknown = 1001
        case systemError = 1002
        case webViewError = 1003
        case calendarError = 1004
        case calendarDenied = 1005
        case mailError = 1006
    }
    
    public var nsError: NSError! {
        switch self {
        case .unknown(let codeLocation):
            var userInfo = codeLocation.userInfo
            userInfo[NSLocalizedDescriptionKey] = self.errorString
            return NSError.init(domain: Self.domain,
                                code: Self.Code.unknown.rawValue,
                                userInfo: userInfo)
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
        case .unknown:
            return String(format: NSLocalizedString("DNSBASESTAGE-Unknown Error%@", comment: ""),
                          " (\(Self.domain):\(Self.Code.unknown.rawValue))")
        case .systemError(let error, _):
            return String(format: NSLocalizedString("DNSBASESTAGE-System Error: %@%@", comment: ""),
                          error.localizedDescription, " (\(Self.domain):\(Self.Code.systemError.rawValue))")
        case .webViewError(let error, _):
            return String(format: NSLocalizedString("DNSBASESTAGE-WebView Error: %@%@", comment: ""),
                          error.localizedDescription, " (\(Self.domain):\(Self.Code.webViewError.rawValue))")
        case .calendarError(let error, _):
            return String(format: NSLocalizedString("DNSBASESTAGE-Calendar Error: %@%@", comment: ""),
                          error.localizedDescription, " (\(Self.domain):\(Self.Code.calendarError.rawValue))")
        case .calendarDenied(_):
            return String(format: NSLocalizedString("DNSBASESTAGE-Calendar Denied%@", comment: ""),
                          " (\(Self.domain):\(Self.Code.calendarError.rawValue))")
        case .mailError(let error, _):
            return String(format: NSLocalizedString("DNSBASESTAGE-Mail Error: %@%@", comment: ""),
                          error.localizedDescription, " (\(Self.domain):\(Self.Code.mailError.rawValue))")
        }
    }
    public var failureReason: String? {
        switch self {
        case .unknown(let codeLocation),
             .systemError(_, let codeLocation),
             .webViewError(_, let codeLocation),
             .calendarError(_, let codeLocation),
             .calendarDenied(let codeLocation),
             .mailError(_, let codeLocation):
            return codeLocation.failureReason
        }
    }
}
