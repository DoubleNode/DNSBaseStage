// swift-tools-version:5.7
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
        .iOS(.v16),
        .tvOS(.v16),
        .macCatalyst(.v16),
        .macOS(.v13),
        .watchOS(.v9),
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
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", .upToNextMajor(from: "4.3.0")),
        .package(url: "https://github.com/alexandreos/UILabel-Copyable.git", .upToNextMajor(from: "2.0.1")),
        .package(url: "https://github.com/DoubleNode/DNSAppCore.git", .upToNextMajor(from: "1.12.0")),
        .package(url: "https://github.com/DoubleNode/DNSCore.git", .upToNextMajor(from: "1.12.1")),
        .package(url: "https://github.com/DoubleNode/DNSCrashSystems.git", .upToNextMajor(from: "1.12.0")),
        .package(url: "https://github.com/DoubleNode/DNSCrashWorkers.git", .upToNextMajor(from: "1.12.1")),
        .package(url: "https://github.com/DoubleNode/DNSNetwork.git", .upToNextMajor(from: "1.12.0")),
        .package(url: "https://github.com/DoubleNode/DNSThemeObjects.git", .upToNextMajor(from: "1.12.1")),
        .package(url: "https://github.com/DoubleNode/DNSThemeTypes.git", .upToNextMajor(from: "1.12.1")),
//        .package(path: "../DNSAppCore"),
//        .package(path: "../DNSCore"),
//        .package(path: "../DNSCrashSystems"),
//        .package(path: "../DNSCrashWorkers"),
//        .package(path: "../DNSNetwork"),
//        .package(path: "../DNSThemeObjects"),
//        .package(path: "../DNSThemeTypes"),
        .package(url: "https://github.com/johankool/Drawer.git", .upToNextMajor(from: "0.9.1")),
        .package(url: "https://github.com/futuretap/FTLinearActivityIndicator.git", .upToNextMajor(from: "1.8.0")),
        .package(url: "https://github.com/gabrieltheodoropoulos/GTBlurView.git", .upToNextMajor(from: "1.0.2")),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", .upToNextMajor(from: "6.5.16")),
        .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/schmidyy/Loaf.git", .upToNextMajor(from: "0.7.0")),
        .package(url: "https://github.com/DoubleNodeOpen/SFSymbol", .upToNextMajor(from: "3.0.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DNSBaseStage",
            dependencies: [
                "AlamofireImage", "DNSAppCore", "DNSCore", "DNSCrashSystems", "DNSCrashWorkers", "DNSNetwork",
                "DNSThemeObjects", "DNSThemeTypes", "FTLinearActivityIndicator", "GTBlurView",
                .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
                "JGProgressHUD",
                .product(name: "JKDrawer", package: "Drawer"),
                "kCustomAlert", "Loaf", "SFSymbol",
                .product(name: "UILabel+Copyable", package: "UILabel-Copyable"),
        ]),
        .target(
            name: "kCustomAlert",
            dependencies: ["Alamofire", "AlamofireImage", "DNSCore", "DNSThemeObjects", "DNSThemeTypes"],
            resources: [
                .process("CommonAlertVC.xib")
            ]
        ),
        .testTarget(
            name: "DNSBaseStageTests",
            dependencies: ["DNSBaseStage", "kCustomAlert"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
