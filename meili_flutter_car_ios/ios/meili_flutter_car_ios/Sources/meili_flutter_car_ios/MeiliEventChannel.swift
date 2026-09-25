//
//  MeiliEventChannel.swift
//  meili_flutter_car_ios
//
//  Bridges native MeiliCar SDK callbacks to the Dart `meili_flutter_car/events`
//  EventChannel.
//

import Flutter
import Foundation
import MeiliCarSDK

/// Single shared sink for native Meili events. Acts as the EventChannel's
/// stream handler and is fed by the SDK's lifecycle closures
/// (`dismissAction`, `onEndBookingFlow`) and by `MeiliFlutterAnalyticsProvider`.
///
/// Events emitted before Dart subscribes (no sink yet) are dropped.
final class MeiliEventDispatcher: NSObject, FlutterStreamHandler {
    static let shared = MeiliEventDispatcher()

    private var eventSink: FlutterEventSink?
    private var pendingPopToRoot: (() -> Void)?

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    /// Sends an event map to Dart on the platform (main) thread.
    func send(_ event: [String: Any]) {
        if Thread.isMainThread {
            eventSink?(event)
        } else {
            DispatchQueue.main.async { [weak self] in self?.eventSink?(event) }
        }
    }

    /// Retains the `popToRoot` action delivered with the latest end-of-flow
    /// event so it can be triggered later via the `popToRoot` method call.
    func retainPopToRoot(_ action: @escaping () -> Void) {
        pendingPopToRoot = action
    }

    /// Invokes the retained `popToRoot` action, if any.
    func popToRoot() {
        pendingPopToRoot?()
    }

    /// Emits a `flowDismissed` event.
    func sendDismissed() {
        send(["type": "flowDismissed"])
    }

    /// Retains `popToRoot` and emits a `bookingFlowEnded` event.
    func sendBookingFlowEnded(_ popToRoot: @escaping () -> Void) {
        retainPopToRoot(popToRoot)
        send(["type": "bookingFlowEnded"])
    }

    /// Emits an `error` event for an SDK-reported `MeiliCarError`.
    func sendError(_ error: MeiliCarError) {
        send([
            "type": "error",
            "area": error.area.wireValue,
            "kind": error.kind.wireValue,
            "httpCode": error.httpCode.map { $0 as Any } ?? NSNull(),
            "message": error.message,
        ])
    }
}

extension MeiliCarErrorArea {
    /// The wire string sent to Dart, matching `MeiliCarErrorArea`'s values there.
    var wireValue: String {
        switch self {
        case .config: return "config"
        case .availability: return "availability"
        case .costs: return "costs"
        case .checkout: return "checkout"
        case .reservation: return "reservation"
        case .partnerContent: return "partnerContent"
        @unknown default: return "unknown"
        }
    }
}

extension MeiliCarErrorKind {
    /// The wire string sent to Dart, matching `MeiliCarErrorKind`'s values there.
    var wireValue: String {
        switch self {
        case .network: return "network"
        case .http: return "http"
        case .decode: return "decode"
        case .unexpected: return "unexpected"
        @unknown default: return "unknown"
        }
    }
}

/// Forwards every SDK analytics event to the Dart event stream. Registered
/// once via `MeiliCarAnalytics.shared.addProvider(_:)`.
final class MeiliFlutterAnalyticsProvider: MeiliCarAnalyticsProvider {
    func trackEvent(name: String, properties: [String: Any]?) {
        MeiliEventDispatcher.shared.send([
            "type": "analytics",
            "name": name,
            "properties": Self.sanitize(properties),
        ])
    }

    /// Coerces property values to Flutter StandardMessageCodec-safe types so
    /// an exotic value can never crash the channel. Everything is forwarded;
    /// non-primitive values are stringified.
    private static func sanitize(_ properties: [String: Any]?) -> [String: Any] {
        guard let properties else { return [:] }
        var safe: [String: Any] = [:]
        for (key, value) in properties {
            switch value {
            case let value as String:
                safe[key] = value
            case let value as NSNumber:
                safe[key] = value
            default:
                safe[key] = String(describing: value)
            }
        }
        return safe
    }
}
