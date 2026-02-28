// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ForeCounter",
    platforms: [.macOS(.v14), .watchOS(.v10)],
    targets: [
        .target(
            name: "ForeCounterKit",
            path: "ForeCounter",
            sources: ["Models", "Services", "ViewModels"]
        ),
        .testTarget(
            name: "ForeCounterTests",
            dependencies: ["ForeCounterKit"],
            path: "ForeCounterTests"
        ),
    ]
)
