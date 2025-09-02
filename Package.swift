// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "shvil",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "shvil",
            targets: ["shvil"]),
    ],
    dependencies: [
        // Supabase Swift SDK
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "shvil",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ]),
        .testTarget(
            name: "shvilTests",
            dependencies: ["shvil"]),
    ]
)
