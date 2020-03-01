// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
            targets: ["DNSBaseStage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/DoubleNode/DNSAppCore.git", from: "1.0.4"),
        .package(url: "https://github.com/DoubleNode/DNSCore.git", from: "1.0.32"),
        .package(url: "https://github.com/DoubleNode/DNSCrashSystems.git", from: "1.0.0"),
        .package(url: "https://github.com/DoubleNode/DNSCrashWorkers.git", from: "1.0.0"),
        .package(url: "https://github.com/DoubleNode/DNSNetwork.git", from: "1.0.8"),
        .package(url: "https://github.com/futuretap/FTLinearActivityIndicator.git", from: "1.2.1"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.5"),
        .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", from: "2.1.0"),
        .package(url: "https://github.com/schmidyy/Loaf.git", from: "0.5.0"),
        .package(url: "https://github.com/Nirma/SFSymbol", from: "0.2.0"),
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
                "Loaf",
                "SFSymbol",
        ]),
        .testTarget(
            name: "DNSBaseStageTests",
            dependencies: ["DNSBaseStage"]),
    ]
)
