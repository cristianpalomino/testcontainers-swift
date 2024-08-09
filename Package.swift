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
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "Testcontainers",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ]),
        .testTarget(
            name: "TestcontainersTests",
            dependencies: ["Testcontainers"]),
    ]
)
