// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftMonkey",
    products: [
        .library(name: "SwiftMonkey", targets: ["SwiftMonkey"]),
        .library(name: "SwiftMonkeyPaws", targets: ["SwiftMonkeyPaws"])
    ],
    targets: [
        .target(
            name: "SwiftMonkey",
            path: "SwiftMonkey",
            exclude: ["Documentation", "SwiftMonkey.xcodeproj"]
        ),

        .target(
            name: "SwiftMonkeyPaws",
            path: "SwiftMonkeyPaws",
            exclude: ["Documentation", "SwiftMonkeyPaws.xcodeproj"]
        )
    ]
)
