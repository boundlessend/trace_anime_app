// swift-tools-version: 5.9

import PackageDescription

let package: Package = Package(
    name: "TraceAnime",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TraceAnime", targets: ["TraceAnime"])
    ],
    targets: [
        .executableTarget(name: "TraceAnime"),
        .testTarget(name: "TraceAnimeTests", dependencies: ["TraceAnime"])
    ]
)
