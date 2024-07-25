// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "Testcontainers",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Testcontainers",
            targets: ["Testcontainers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "Testcontainers",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]),
        .testTarget(
            name: "TestcontainersTests",
            dependencies: ["Testcontainers"]),
    ]
)
