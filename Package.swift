// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "NavigationBarHelper",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "NavigationBarHelper", targets: ["NavigationBarHelper"])
    ],
    targets: [
        .target(name: "NavigationBarHelper", path: "NavigationBarHelper")
    ],
    swiftLanguageVersions: [.v5]
)
