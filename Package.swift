// swift-tools-version:5.6
//
//  Package.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBaseStage
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "DNSBaseStage",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DNSBaseStage",
            type: .static,
            targets: ["DNSBaseStage"]),
        .library(
            name: "kCustomAlert",
            type: .static,
            targets: ["kCustomAlert"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.2"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: "4.2.0"),
        .package(url: "https://github.com/DoubleNode/DNSAppCore.git", from: "1.9.10"),
        .package(url: "https://github.com/DoubleNode/DNSBaseTheme.git", from: "1.9.23"),
        .package(url: "https://github.com/DoubleNode/DNSCore.git", from: "1.9.34"),
        .package(url: "https://github.com/DoubleNode/DNSCrashSystems.git", from: "1.9.8"),
        .package(url: "https://github.com/DoubleNode/DNSCrashWorkers.git", from: "1.9.53"),
        .package(url: "https://github.com/DoubleNode/DNSNetwork.git", from: "1.8.0"),
        .package(url: "https://github.com/johankool/Drawer.git", from: "0.9.1"),
        .package(url: "https://github.com/futuretap/FTLinearActivityIndicator.git", from: "1.4.3"),
        .package(url: "https://github.com/gabrieltheodoropoulos/GTBlurView.git", from: "1.0.2"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.10"),
        .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", from: "2.2.0"),
        .package(url: "https://github.com/schmidyy/Loaf.git", from: "0.7.0"),
        .package(url: "https://github.com/realm/realm-swift", from: "10.28.5"),
        .package(url: "https://github.com/Nirma/SFSymbol", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DNSBaseStage",
            dependencies: [
                "AlamofireImage",
                "DNSAppCore",
                "DNSBaseTheme",
                "DNSCore",
                "DNSCrashSystems",
                "DNSCrashWorkers",
                "DNSNetwork",
                "FTLinearActivityIndicator",
                "GTBlurView",
                .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
                "JGProgressHUD",
                .product(name: "JKDrawer", package: "Drawer"),
                "kCustomAlert",
                "Loaf",
                "SFSymbol",
                .product(name: "RealmSwift", package: "realm-swift"),
        ]),
        .target(
            name: "kCustomAlert",
            dependencies: ["Alamofire", "AlamofireImage", "DNSCore"],
            resources: [
                .process("CommonAlertVC.xib")
            ]
        ),
        .testTarget(
            name: "DNSBaseStageTests",
            dependencies: ["DNSBaseStage"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
