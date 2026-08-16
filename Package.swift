// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PosturePal",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "PosturePal",
            path: "Sources"
        )
    ]
)
