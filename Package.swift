// swift-tools-version:5.3
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
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.3"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: "4.2.0"),
        .package(url: "https://github.com/DoubleNode/DNSAppCore.git", from: "1.4.3"),
        .package(url: "https://github.com/DoubleNode/DNSCore.git", from: "1.5.1"),
        .package(url: "https://github.com/DoubleNode/DNSCrashSystems.git", from: "1.4.2"),
        .package(url: "https://github.com/DoubleNode/DNSCrashWorkers.git", from: "1.5.0"),
        .package(url: "https://github.com/DoubleNode/DNSNetwork.git", from: "1.4.0"),
        .package(url: "https://github.com/futuretap/FTLinearActivityIndicator.git", from: "1.4.1"),
        .package(name: "IQKeyboardManagerSwift",
                 url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.6"),
        .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", from: "2.2.0"),
        .package(url: "https://github.com/schmidyy/Loaf.git", from: "0.7.0"),
        .package(url: "https://github.com/Nirma/SFSymbol", from: "1.0.0"),
        .package(name: "Realm",
                 url: "https://github.com/realm/realm-cocoa.git", from: "10.7.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DNSBaseStage",
            dependencies: [
                "DNSAppCore",
                "DNSCore",
                "DNSCrashSystems",
                "DNSCrashWorkers",
                "DNSNetwork",
                "FTLinearActivityIndicator",
                "IQKeyboardManagerSwift",
                "JGProgressHUD",
                "kCustomAlert",
                "Loaf",
                "SFSymbol",
                .product(name: "RealmSwift", package: "Realm"),
        ]),
        .target(
            name: "kCustomAlert",
            dependencies: ["Alamofire", "AlamofireImage", "DNSCore"]),
        .testTarget(
            name: "DNSBaseStageTests",
            dependencies: ["DNSBaseStage"]),
    ],
    swiftLanguageVersions: [.v5]
)
