import Flutter
import UIKit
import MeiliSDK
import CoreText

public class MeiliFlutterPlugin: NSObject, FlutterPlugin {
    private var window: UIWindow?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        registerAllFonts()
        let channel = FlutterMethodChannel(name: "meili_flutter", binaryMessenger: registrar.messenger())
        let instance = MeiliFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)

        // Event channel: forwards SDK lifecycle + analytics events to Dart.
        let eventChannel = FlutterEventChannel(name: "meili_flutter/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(MeiliEventDispatcher.shared)
        // Plugin registration runs on the main thread. The SDK's
        // MeiliAnalyticsProvider protocol is @MainActor, so the provider's init
        // and `addProvider` must run on the main actor.
        MainActor.assumeIsolated {
            MeiliAnalytics.shared.addProvider(MeiliFlutterAnalyticsProvider())
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "openMeiliViewController":
                if let args = call.arguments as? [String: Any] {
                    openMeiliViewController(arguments: args, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are missing", details: nil))
                }
            case "popToRoot":
                MeiliEventDispatcher.shared.popToRoot()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
        }
    }
    
    private func openMeiliViewController(arguments: [String: Any], result: @escaping FlutterResult) {
        let viewController = MeiliViewController()

        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            result(FlutterError(code: "UNAVAILABLE", message: "Root view controller is unavailable", details: nil))
            return
        }
        
        guard let ptid = arguments["ptid"] as? String,
              let flow = arguments["flow"] as? String,
              let env = arguments["env"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Required arguments are missing", details: nil))
            return
        }
        
        let meiliFlow = MeiliFlow(rawValue: flow) ?? .direct
        let environment = MeiliEnvironment(rawValue: env) ?? .dev
        let availParams = (arguments["availParams"] as? [String: Any]).flatMap(parseAvailParams)
        let additionalParams = (arguments["additionalParams"] as? [String: Any]).flatMap(parseBookingParams)
        
        let meiliParams = MeiliParams(
            ptid: ptid,
            flow: meiliFlow,
            env: environment,
            availParams: availParams,
            additionalParams: additionalParams
        )
        
        viewController.meiliParams = meiliParams
        
        if MeiliSupport.isNativeFunnelAvailable {
            viewController.modalPresentationStyle = .pageSheet
            rootViewController.present(viewController, animated: true, completion: nil)
        } else {
            // iOS 15: MeiliView is a placeholder that immediately presents the web funnel over
            // this controller, so animating a page sheet in first would show an empty card.
            // Full-screen, not .overFullScreen — the SDK's message state needs an opaque backdrop.
            viewController.modalPresentationStyle = .fullScreen
            rootViewController.present(viewController, animated: false, completion: nil)
        }
        result(nil)
    }
}


func registerAllFonts() {
    guard let resourcePath = Bundle.main.resourcePath else {
        print("Resource path not found")
        return
    }
    
    let fontPath = resourcePath + "/fonts"
    
    do {
        let fileManager = FileManager.default
        let fontFiles = try fileManager.contentsOfDirectory(atPath: fontPath)
        
        for fontFile in fontFiles {
            let fontURL = URL(fileURLWithPath: fontPath).appendingPathComponent(fontFile)
            guard let fontData = try? Data(contentsOf: fontURL) else {
                print("Failed to load font data for \(fontFile)")
                continue
            }
            
            guard let dataProvider = CGDataProvider(data: fontData as CFData) else {
                print("Failed to create data provider for \(fontFile)")
                continue
            }
            
            let fontRef = CGFont(dataProvider)
            var errorRef: Unmanaged<CFError>? = nil
            if let fr = fontRef {
                if CTFontManagerRegisterGraphicsFont(fr, &errorRef) {
                } else {
                    print("Failed to register font: \(fontFile)")
                }
            }
        }
    } catch {
        print("Failed to list fonts in directory: \(error)")
    }
}
