//
//  DNSBaseStageCodeLocation.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSError

public extension DNSCodeLocation {
    typealias baseStage = DNSBaseStageCodeLocation
}
open class DNSBaseStageCodeLocation: DNSCodeLocation {
    override open class var domainPreface: String { "com.doublenode.baseStage." }
}
