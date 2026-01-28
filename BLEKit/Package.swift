// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BLEKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "BLEKit", targets: ["BLEKit"]),
    ],
    targets: [
        .target(
            name: "BLEKit",
            dependencies: [],
            path: "Sources/BLEKit"
        ),
    ]
)
