import PackageDescription

let package = Package(
    name: "SwiftMonkeyExample",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/zalando/SwiftMonkey.git/SwiftMonkey", majorVersion: 0, minor: 0),
        .Package(url: "https://github.com/zalando/SwiftMonkey.git/SwiftMonkeyPaws", majorVersion: 0, minor: 0),
    ]
)
