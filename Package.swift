// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Audira",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Audira", targets: ["Audira"]),
    ],
    targets: [
        .executableTarget(
            name: "Audira",
            path: "Sources/Audira"
        ),
    ]
)
