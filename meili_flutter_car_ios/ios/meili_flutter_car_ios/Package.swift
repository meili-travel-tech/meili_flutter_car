// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "meili_flutter_ios",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "meili-flutter-ios", targets: ["meili_flutter_ios"])
    ],
    dependencies: [
        // Binary distribution of MeiliSDK. The XCFramework bakes in the
        // third-party SDKs (Stripe, Evervault, HorizonCalendar, Shimmer,
        // PhoneNumberKit, SwiftUIPager), so nothing else is declared here.
        //
        // `from:` tracks the latest 1.x stable. Keep this aligned with the
        // CocoaPods channel (meili_flutter_ios.podspec).
        .package(url: "https://github.com/meili-travel-tech/ux-native-ios", from: "1.11.1")
    ],
    targets: [
        .target(
            name: "meili_flutter_ios",
            dependencies: [
                .product(name: "MeiliSDK", package: "ux-native-ios")
            ]
            // The `Flutter` module is injected by Flutter's build tooling;
            // it is intentionally NOT declared as a SwiftPM dependency.
        )
    ]
)
