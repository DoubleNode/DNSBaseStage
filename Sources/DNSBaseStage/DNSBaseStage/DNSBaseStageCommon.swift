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
        public static let onBlank = "DNSBaseStage_C_onBlank"
        public static let orNoMatch = "DNSBaseStage_C_orNoMatch"
    }
    public enum DisplayOption {
        case navBarRightClose
        case navController
        case navBarHidden
        case navBarHiddenInstant
        case navBarShown
        case navBarShownInstant
    }
    public enum DisplayType {
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
        case navBarRootReplace
        case tabBarAdd
        case tabBarAddInstant
    }
}

public typealias DNSBaseStageDisplayOptions = [DNSBaseStage.DisplayOption]
