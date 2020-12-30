// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "stran",
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "stran",
            dependencies: []),
        .testTarget(
            name: "stranTests",
            dependencies: ["stran"]),
        // .target(
        //     name: "utils"),
    ]
)
