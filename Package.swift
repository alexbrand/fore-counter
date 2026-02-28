// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ForeCounter",
    platforms: [.macOS(.v14), .watchOS(.v10)],
    targets: [
        .target(
            name: "ForeCounterKit",
            path: "ForeCounter",
            sources: ["Models", "Services", "ViewModels"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "ForeCounterTests",
            dependencies: ["ForeCounterKit"],
            path: "ForeCounterTests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
