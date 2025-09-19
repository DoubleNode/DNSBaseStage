//
//  DNSBaseStageCommonTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStageTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import JKDrawer
@testable import DNSBaseStage
@testable import DNSThemeTypes

class DNSBaseStageCommonTests: XCTestCase {

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Type Alias Tests
    func test_typeAliases_exist_and_accessible() {
        // Test that all type aliases are properly defined
        XCTAssertTrue(DNSBaseStage.Configurator.self == DNSBaseStageConfigurator.self)
        XCTAssertTrue(DNSBaseStage.Interactor.self == DNSBaseStageInteractor.self)
        XCTAssertTrue(DNSBaseStage.Models.self == DNSBaseStageModels.self)
        XCTAssertTrue(DNSBaseStage.Presenter.self == DNSBaseStagePresenter.self)
        XCTAssertTrue(DNSBaseStage.ViewController.self == DNSBaseStageViewController.self)
    }

    func test_logicTypeAliases_exist_and_accessible() {
        // Test Logic nested type aliases
        XCTAssertTrue(DNSBaseStage.Logic.Business.self == DNSBaseStageBusinessLogic.self)
        XCTAssertTrue(DNSBaseStage.Logic.Display.self == DNSBaseStageDisplayLogic.self)
        XCTAssertTrue(DNSBaseStage.Logic.Presentation.self == DNSBaseStagePresentationLogic.self)
    }

    // MARK: - Default Button Style Tests
    func test_defaultCancelButton_has_default_value() {
        XCTAssertEqual(DNSBaseStage.defaultCancelButton, DNSThemeButtonStyle.default)
    }

    func test_defaultOkayButton_has_default_value() {
        XCTAssertEqual(DNSBaseStage.defaultOkayButton, DNSThemeButtonStyle.default)
    }

    func test_defaultButtons_can_be_modified() {
        let originalCancel = DNSBaseStage.defaultCancelButton
        let originalOkay = DNSBaseStage.defaultOkayButton

        // Modify values
        DNSBaseStage.defaultCancelButton = .default
        DNSBaseStage.defaultOkayButton = .default

        XCTAssertEqual(DNSBaseStage.defaultCancelButton, .default)
        XCTAssertEqual(DNSBaseStage.defaultOkayButton, .default)

        // Restore original values
        DNSBaseStage.defaultCancelButton = originalCancel
        DNSBaseStage.defaultOkayButton = originalOkay
    }

    // MARK: - Constants Tests
    func test_constantsC_values() {
        XCTAssertEqual(DNSBaseStage.C.onBlank, "DNSBaseStage_C_onBlank")
        XCTAssertEqual(DNSBaseStage.C.onClose, "DNSBaseStage_C_onClose")
        XCTAssertEqual(DNSBaseStage.C.orNoMatch, "DNSBaseStage_C_orNoMatch")
    }

    func test_actionCodes_values() {
        XCTAssertEqual(DNSBaseStage.ActionCodes.cancel, "DNSBaseStage_ActionCodes_cancel")
        XCTAssertEqual(DNSBaseStage.ActionCodes.okay, "DNSBaseStage_ActionCodes_okay")
    }

    func test_baseIntents_values() {
        XCTAssertEqual(DNSBaseStage.BaseIntents.close, "DNSBaseStage_Intents_close")
    }

    // MARK: - Display Option Tests
    func test_displayOption_drawerClosable() {
        let option = DNSBaseStage.Display.Option.drawerClosable
        XCTAssertEqual(option, .drawerClosable)
    }

    func test_displayOption_drawerDraggable() {
        let option = DNSBaseStage.Display.Option.drawerDraggable
        XCTAssertEqual(option, .drawerDraggable)
    }

    func test_displayOption_drawerGravity() {
        let gravity = Gravity.top
        let option = DNSBaseStage.Display.Option.drawerGravity(gravity: gravity)

        if case let .drawerGravity(resultGravity) = option {
            XCTAssertEqual(resultGravity, gravity)
        } else {
            XCTFail("Option should match drawerGravity with correct gravity")
        }
    }

    func test_displayOption_modalNotDismissable() {
        let option = DNSBaseStage.Display.Option.modalNotDismissable
        XCTAssertEqual(option, .modalNotDismissable)
    }

    func test_displayOption_navBarRightClose() {
        let option = DNSBaseStage.Display.Option.navBarRightClose
        XCTAssertEqual(option, .navBarRightClose)
    }

    func test_displayOption_navDrawerController() {
        let option = DNSBaseStage.Display.Option.navDrawerController
        XCTAssertEqual(option, .navDrawerController)
    }

    func test_displayOption_navController() {
        let option = DNSBaseStage.Display.Option.navController
        XCTAssertEqual(option, .navController)
    }

    func test_displayOption_navBarHidden() {
        let animatedOption = DNSBaseStage.Display.Option.navBarHidden(animated: true)
        let nonAnimatedOption = DNSBaseStage.Display.Option.navBarHidden(animated: false)

        if case let .navBarHidden(animated) = animatedOption {
            XCTAssertTrue(animated)
        } else {
            XCTFail("Option should match navBarHidden with animated=true")
        }

        if case let .navBarHidden(animated) = nonAnimatedOption {
            XCTAssertFalse(animated)
        } else {
            XCTFail("Option should match navBarHidden with animated=false")
        }
    }

    func test_displayOption_navBarShown() {
        let animatedOption = DNSBaseStage.Display.Option.navBarShown(animated: true)
        let nonAnimatedOption = DNSBaseStage.Display.Option.navBarShown(animated: false)

        if case let .navBarShown(animated) = animatedOption {
            XCTAssertTrue(animated)
        } else {
            XCTFail("Option should match navBarShown with animated=true")
        }

        if case let .navBarShown(animated) = nonAnimatedOption {
            XCTAssertFalse(animated)
        } else {
            XCTFail("Option should match navBarShown with animated=false")
        }
    }

    func test_displayOptions_array_type() {
        let options: DNSBaseStage.Display.Options = [
            .drawerClosable,
            .modalNotDismissable,
            .navBarRightClose
        ]

        XCTAssertEqual(options.count, 3)
        XCTAssertTrue(options.contains(.drawerClosable))
        XCTAssertTrue(options.contains(.modalNotDismissable))
        XCTAssertTrue(options.contains(.navBarRightClose))
    }

    // MARK: - Display Mode Tests
    func test_displayMode_none() {
        let mode = DNSBaseStage.Display.Mode.none
        XCTAssertEqual(mode, .none)
    }

    func test_displayMode_drawer() {
        let animatedMode = DNSBaseStage.Display.Mode.drawer(animated: true)
        let nonAnimatedMode = DNSBaseStage.Display.Mode.drawer(animated: false)

        if case let .drawer(animated) = animatedMode {
            XCTAssertTrue(animated)
        } else {
            XCTFail("Mode should match drawer with animated=true")
        }

        if case let .drawer(animated) = nonAnimatedMode {
            XCTAssertFalse(animated)
        } else {
            XCTFail("Mode should match drawer with animated=false")
        }
    }

    func test_displayMode_modal_types() {
        let modal = DNSBaseStage.Display.Mode.modal
        let modalCurrentContext = DNSBaseStage.Display.Mode.modalCurrentContext
        let modalFormSheet = DNSBaseStage.Display.Mode.modalFormSheet
        let modalFullScreen = DNSBaseStage.Display.Mode.modalFullScreen
        let modalPageSheet = DNSBaseStage.Display.Mode.modalPageSheet
        let modalPopover = DNSBaseStage.Display.Mode.modalPopover

        XCTAssertEqual(modal, .modal)
        XCTAssertEqual(modalCurrentContext, .modalCurrentContext)
        XCTAssertEqual(modalFormSheet, .modalFormSheet)
        XCTAssertEqual(modalFullScreen, .modalFullScreen)
        XCTAssertEqual(modalPageSheet, .modalPageSheet)
        XCTAssertEqual(modalPopover, .modalPopover)
    }

    func test_displayMode_navBar_types() {
        let pushAnimated = DNSBaseStage.Display.Mode.navBarPush(animated: true)
        let pushNonAnimated = DNSBaseStage.Display.Mode.navBarPush(animated: false)
        let rootAnimated = DNSBaseStage.Display.Mode.navBarRoot(animated: true)
        let rootNonAnimated = DNSBaseStage.Display.Mode.navBarRoot(animated: false)
        let rootReplace = DNSBaseStage.Display.Mode.navBarRootReplace
        let rootReset = DNSBaseStage.Display.Mode.navBarRootReset

        if case let .navBarPush(animated) = pushAnimated {
            XCTAssertTrue(animated)
        } else {
            XCTFail("Mode should match navBarPush with animated=true")
        }

        if case let .navBarPush(animated) = pushNonAnimated {
            XCTAssertFalse(animated)
        } else {
            XCTFail("Mode should match navBarPush with animated=false")
        }

        if case let .navBarRoot(animated) = rootAnimated {
            XCTAssertTrue(animated)
        } else {
            XCTFail("Mode should match navBarRoot with animated=true")
        }

        if case let .navBarRoot(animated) = rootNonAnimated {
            XCTAssertFalse(animated)
        } else {
            XCTFail("Mode should match navBarRoot with animated=false")
        }

        XCTAssertEqual(rootReplace, .navBarRootReplace)
        XCTAssertEqual(rootReset, .navBarRootReset)
    }

    func test_displayMode_tabBar() {
        let tabBarAdd = DNSBaseStage.Display.Mode.tabBarAdd(animated: true, tabNdx: 2)

        if case let .tabBarAdd(animated, tabNdx) = tabBarAdd {
            XCTAssertTrue(animated)
            XCTAssertEqual(tabNdx, 2)
        } else {
            XCTFail("Mode should match tabBarAdd with correct parameters")
        }
    }

    // MARK: - Equatable Tests
    func test_displayOption_equality() {
        let option1 = DNSBaseStage.Display.Option.drawerClosable
        let option2 = DNSBaseStage.Display.Option.drawerClosable
        let option3 = DNSBaseStage.Display.Option.modalNotDismissable

        XCTAssertEqual(option1, option2)
        XCTAssertNotEqual(option1, option3)
    }

    func test_displayOption_gravity_equality() {
        let gravity1 = DNSBaseStage.Display.Option.drawerGravity(gravity: .top)
        let gravity2 = DNSBaseStage.Display.Option.drawerGravity(gravity: .top)
        let gravity3 = DNSBaseStage.Display.Option.drawerGravity(gravity: .bottom)

        XCTAssertEqual(gravity1, gravity2)
        XCTAssertNotEqual(gravity1, gravity3)
    }

    func test_displayOption_navBar_equality() {
        let navBar1 = DNSBaseStage.Display.Option.navBarHidden(animated: true)
        let navBar2 = DNSBaseStage.Display.Option.navBarHidden(animated: true)
        let navBar3 = DNSBaseStage.Display.Option.navBarHidden(animated: false)

        XCTAssertEqual(navBar1, navBar2)
        XCTAssertNotEqual(navBar1, navBar3)
    }

    func test_displayMode_equality() {
        let mode1 = DNSBaseStage.Display.Mode.drawer(animated: true)
        let mode2 = DNSBaseStage.Display.Mode.drawer(animated: true)
        let mode3 = DNSBaseStage.Display.Mode.drawer(animated: false)

        XCTAssertEqual(mode1, mode2)
        XCTAssertNotEqual(mode1, mode3)
    }

    func test_displayMode_tabBar_equality() {
        let tabBar1 = DNSBaseStage.Display.Mode.tabBarAdd(animated: true, tabNdx: 1)
        let tabBar2 = DNSBaseStage.Display.Mode.tabBarAdd(animated: true, tabNdx: 1)
        let tabBar3 = DNSBaseStage.Display.Mode.tabBarAdd(animated: true, tabNdx: 2)
        let tabBar4 = DNSBaseStage.Display.Mode.tabBarAdd(animated: false, tabNdx: 1)

        XCTAssertEqual(tabBar1, tabBar2)
        XCTAssertNotEqual(tabBar1, tabBar3)
        XCTAssertNotEqual(tabBar1, tabBar4)
    }

    // MARK: - Edge Case Tests
    func test_displayOptions_empty_array() {
        let emptyOptions: DNSBaseStage.Display.Options = []
        XCTAssertTrue(emptyOptions.isEmpty)
        XCTAssertEqual(emptyOptions.count, 0)
    }

    func test_displayOptions_large_array() {
        let largeOptions: DNSBaseStage.Display.Options = [
            .drawerClosable,
            .drawerDraggable,
            .modalNotDismissable,
            .navBarRightClose,
            .navDrawerController,
            .navController,
            .navBarHidden(animated: true),
            .navBarShown(animated: false)
        ]

        XCTAssertEqual(largeOptions.count, 8)
        XCTAssertTrue(largeOptions.contains(.drawerClosable))
        XCTAssertTrue(largeOptions.contains(.navController))
    }

    func test_constants_are_strings() {
        // Verify all constants are proper strings
        XCTAssertTrue(DNSBaseStage.C.onBlank is String)
        XCTAssertTrue(DNSBaseStage.C.onClose is String)
        XCTAssertTrue(DNSBaseStage.C.orNoMatch is String)
        XCTAssertTrue(DNSBaseStage.ActionCodes.cancel is String)
        XCTAssertTrue(DNSBaseStage.ActionCodes.okay is String)
        XCTAssertTrue(DNSBaseStage.BaseIntents.close is String)
    }

    func test_constants_are_not_empty() {
        // Verify all constants have non-empty values
        XCTAssertFalse(DNSBaseStage.C.onBlank.isEmpty)
        XCTAssertFalse(DNSBaseStage.C.onClose.isEmpty)
        XCTAssertFalse(DNSBaseStage.C.orNoMatch.isEmpty)
        XCTAssertFalse(DNSBaseStage.ActionCodes.cancel.isEmpty)
        XCTAssertFalse(DNSBaseStage.ActionCodes.okay.isEmpty)
        XCTAssertFalse(DNSBaseStage.BaseIntents.close.isEmpty)
    }

    // MARK: - Performance Tests
    func test_performance_option_creation() {
        measure {
            for _ in 0..<1000 {
                let _ = DNSBaseStage.Display.Option.drawerGravity(gravity: .top)
                let _ = DNSBaseStage.Display.Option.navBarHidden(animated: true)
            }
        }
    }

    func test_performance_mode_creation() {
        measure {
            for _ in 0..<1000 {
                let _ = DNSBaseStage.Display.Mode.drawer(animated: true)
                let _ = DNSBaseStage.Display.Mode.tabBarAdd(animated: false, tabNdx: 3)
            }
        }
    }
}