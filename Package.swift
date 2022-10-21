// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMonkey",
    platforms: [
        .iOS(.v9)
    ],
    products: [
    .library(
          name: "SwiftMonkey",
          targets: ["SwiftMonkey"]),
    ],
    dependencies:[],
    targets: [
        .target(name: "SwiftMonkey", path: "SwiftMonkey")
    ]
)
