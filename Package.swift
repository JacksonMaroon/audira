// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AikoCanary",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "AikoCanary", targets: ["AikoCanary"]),
    ],
    targets: [
        .executableTarget(
            name: "AikoCanary",
            path: "Sources/AikoCanary"
        ),
    ]
)
