import PackageDescription

let package = Package(
    name: "SwiftMonkeyExample",
    targets: [],
    dependencies: [
        .Package(url: "git@github.bus.zalan.do:dagren/SwiftMonkey.git", majorVersion: 0, minor: 0),
        .Package(url: "git@github.bus.zalan.do:dagren/SwiftMonkeyPaws.git", majorVersion: 0, minor: 0),
    ]
)
