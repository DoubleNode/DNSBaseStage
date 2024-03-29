//
//  DNSBaseStageCommon.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSBaseTheme
import Foundation
import JKDrawer

public enum DNSBaseStage {
    public typealias Configurator = DNSBaseStageConfigurator
    public typealias Interactor = DNSBaseStageInteractor
    public enum Logic {
        public typealias Business = DNSBaseStageBusinessLogic
        public typealias Display = DNSBaseStageDisplayLogic
        public typealias Presentation = DNSBaseStagePresentationLogic
    }
    public typealias Models = DNSBaseStageModels
    public typealias Presenter = DNSBaseStagePresenter
    public typealias ViewController = DNSBaseStageViewController
    
    public static var defaultCancelButton = DNSThemeButtonStyle.default
    public static var defaultOkayButton = DNSThemeButtonStyle.default

    public enum C {
        public static let onBlank = "DNSBaseStage_C_onBlank"
        public static let onClose = "DNSBaseStage_C_onClose"
        public static let orNoMatch = "DNSBaseStage_C_orNoMatch"
    }
    public enum ActionCodes {
        public static let cancel = "DNSBaseStage_ActionCodes_cancel"
        public static let okay = "DNSBaseStage_ActionCodes_okay"
    }
    public enum BaseIntents {
        public static let close = "DNSBaseStage_Intents_close"
    }
    public enum Display {
        public enum Option: Equatable {
            case drawerClosable
            case drawerDraggable
            case drawerGravity(gravity: Gravity)
            case modalNotDismissable
            case navBarRightClose
            case navDrawerController
            case navController
            case navBarHidden(animated: Bool)
            case navBarShown(animated: Bool)
        }
        public typealias Options = [DNSBaseStage.Display.Option]
        public enum Mode: Equatable {
            case none
            case drawer(animated: Bool)
            case modal
            case modalCurrentContext
            case modalFormSheet
            case modalFullScreen
            case modalPageSheet
            case modalPopover
            case navBarPush(animated: Bool)
            case navBarRoot(animated: Bool)
            case navBarRootReplace
            case navBarRootReset
            case tabBarAdd(animated: Bool, tabNdx: Int)
        }
    }
}
//public typealias DNSBaseStageDisplayOptions = [DNSBaseStage.Display.Option]
