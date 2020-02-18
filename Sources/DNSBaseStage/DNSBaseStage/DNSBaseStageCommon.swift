//
//  DNSBaseStageCommon.swift
//  DoubleNode Core - DNSBaseScene
//
//  Created by Darren Ehlers on 2019/08/12.
//  Copyright © 2019 - 2016 Darren Ehlers and DoubleNode, LLC. All rights reserved.
//

import Foundation

public enum DNSBaseStage {
    public enum C {
        public static let dnsOnBlank = "DNSBaseStage_C_dnsOnBlank"
        public static let dnsOrNoMatch = "DNSBaseStage_C_dnsOrNoMatch"
    }
}

public enum DNSBaseStageDisplayType {
    case none
    case modal
    case modalCurrentContext
    case modalFormSheet
    case modalFullScreen
    case modalPageSheet
    case modalPopover
    case navBarPush
    case navBarPushInstant
    case navBarRoot
    case navBarRootInstant
    case tabBarAdd
    case tabBarAddInstant
}
