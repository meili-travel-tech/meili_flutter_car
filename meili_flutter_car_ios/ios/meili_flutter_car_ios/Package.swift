// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "meili_flutter_car_ios",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "meili-flutter-car-ios", targets: ["meili_flutter_car_ios"])
    ],
    dependencies: [
        // Binary distribution of MeiliCarSDK. The XCFramework bakes in the
        // third-party SDKs (HorizonCalendar, Shimmer, PhoneNumberKit,
        // SwiftUIPager), so nothing else is declared here.
        //
        // `from:` tracks the latest 1.x stable. Keep this aligned with the
        // CocoaPods channel (meili_flutter_car_ios.podspec).
        .package(url: "https://github.com/meili-travel-tech/ux-native-ios", from: "1.12.0")
    ],
    targets: [
        .target(
            name: "meili_flutter_car_ios",
            dependencies: [
                .product(name: "MeiliCarSDK", package: "ux-native-ios")
            ]
            // The `Flutter` module is injected by Flutter's build tooling;
            // it is intentionally NOT declared as a SwiftPM dependency.
        )
    ]
)
