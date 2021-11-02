// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftMonkey",
    products: [
        .library(name: "SwiftMonkey", targets: ["SwiftMonkey"])
    ],
    targets: [
        .target(
            name: "SwiftMonkey",
            path: "SwiftMonkey",
            exclude: ["Documentation", "SwiftMonkey.xcodeproj"]
        ),
    ]
)
