//
//  DNSBaseStageCommon.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
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
        case navBarHidden(animated: Bool)
        case navBarShown(animated: Bool)
    }
    public enum DisplayType: Equatable {
        case none
        case modal
        case modalCurrentContext
        case modalFormSheet
        case modalFullScreen
        case modalPageSheet
        case modalPopover
        case navBarPush(animated: Bool)
        case navBarRoot(animated: Bool)
        case navBarRootReplace
        case tabBarAdd(animated: Bool, tabNdx: Int)
    }
}

public typealias DNSBaseStageDisplayOptions = [DNSBaseStage.DisplayOption]
