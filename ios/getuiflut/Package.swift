// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "getuiflut",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "getuiflut",
            type: .static,
            targets: ["getuiflut"]
        ),
    ],
    dependencies: [
        // Flutter-generated local framework package.
        // Flutter resolves this path at build time.
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // GTSDK (个推 SDK)
        .package(name: "GTSDK", url: "https://github.com/GetuiLaboratory/getui-sdk-ios-cocoapods.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "getuiflut",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "GTSDK", package: "GTSDK"),
            ],
            // Point to parent ios/ directory so existing Classes/ sources are compiled in-place.
            path: "..",
            sources: ["Classes/GetuiflutPlugin.m"],
            publicHeadersPath: "Classes",
            cSettings: [
                .headerSearchPath("Classes")
            ]
        ),
    ]
)
