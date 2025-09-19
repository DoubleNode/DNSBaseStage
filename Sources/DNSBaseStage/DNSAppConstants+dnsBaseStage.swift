//
//  DNSAppConstants+dnsBaseStage.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2025 - 2016 DoubleNode.com. All rights reserved.
//

import DNSCore
import Foundation

public extension DNSAppConstants {
    static var baseStageDefaults: DNSBaseStageModels.Defaults = {
        var defaults = DNSBaseStageModels.Defaults()
        defaults.error.dismissingDirection = .left
        defaults.error.duration = .long
        defaults.error.location = .bottom
        defaults.error.presentingDirection = .right
        defaults.message.dismissingDirection = .right
        defaults.message.duration = .custom(6)
        defaults.message.location = .bottom
        defaults.message.presentingDirection = .left
        return defaults
    }()
}
