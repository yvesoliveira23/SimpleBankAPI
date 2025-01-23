// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SimpleBankAPI",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "Run",
            targets: ["Run"]
        ),
        .library(
            name: "SimpleBankAPI",
            targets: ["SimpleBankAPI"]
        )
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors.
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🔒 A Swift library for cryptographic operations.
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SimpleBankAPI",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Crypto", package: "swift-crypto")
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "SimpleBankAPI")]),
        .testTarget(name: "SimpleBankAPITests", dependencies: ["SimpleBankAPI"]),
    ]
)