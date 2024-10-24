// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "RedisClientApp",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
        .package(url: "https://github.com/cristianpalomino/testcontainers-swift.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "RedisClientApp", dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Redis", package: "redis")
            ]),
        .testTarget(
            name: "RedisClientAppTests",
            dependencies: [
                "RedisClientApp",
                .product(name: "Testcontainers", package: "testcontainers-swift")
            ]),
    ]
)
