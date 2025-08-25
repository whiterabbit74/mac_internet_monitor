// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "InternetMonitor",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "InternetMonitor", targets: ["InternetMonitor"])
    ],
    targets: [
        .executableTarget(
            name: "InternetMonitor",
            dependencies: []
        )
    ]
)
