package com.meili.travel.flutter.car

import androidx.activity.ComponentActivity
import com.meili.travel.car.api.AvailParams
import com.meili.travel.car.api.MeiliCarActivity
import com.meili.travel.car.api.MeiliCarComposeListener
import com.meili.travel.car.api.MeiliCarError
import com.meili.travel.car.api.MeiliCarErrorArea
import com.meili.travel.car.api.MeiliCarErrorKind
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MeiliFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activity: ComponentActivity? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "meili_flutter_car")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "meili_flutter_car/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "openMeiliViewController" -> {
                val act = activity ?: run {
                    result.error("NO_ACTIVITY", "Activity not available", null)
                    return
                }
                @Suppress("UNCHECKED_CAST")
                val args = call.arguments as Map<String, Any?>
                val ptid = args["ptid"] as? String ?: run {
                    result.error("MISSING_PTID", "ptid is required", null)
                    return
                }

                MeiliCarActivity.start(
                    context = act,
                    ptid = ptid,
                    env = parseEnv(args["env"] as? String),
                    flow = parseFlow(args["flow"] as? String),
                    availParams = parseAvailParams(args["availParams"] as? Map<*, *>)
                        ?: AvailParams(null, null, null, null, null, null, null, null, null),
                    additionalParams = parseAdditionalParams(args["additionalParams"] as? Map<*, *>),
                    listener = object : MeiliCarComposeListener {
                        override fun onEndBookingFlow(callback: (() -> Unit)?) {
                            eventSink?.success(mapOf("type" to "bookingFlowEnded"))
                            callback?.invoke()
                        }

                        override fun onError(error: MeiliCarError) {
                            eventSink?.success(
                                mapOf(
                                    "type" to "error",
                                    "area" to error.area.wireValue(),
                                    "kind" to error.kind.wireValue(),
                                    "httpCode" to error.httpCode,
                                    "message" to error.message,
                                ),
                            )
                        }
                    },
                    onBack = {
                        eventSink?.success(mapOf("type" to "flowDismissed"))
                    },
                )
                result.success(null)
            }
            "popToRoot" -> result.success(null)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as? ComponentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? ComponentActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}

/** The wire string sent to Dart, matching `MeiliCarErrorArea`'s values there. */
private fun MeiliCarErrorArea.wireValue(): String = when (this) {
    MeiliCarErrorArea.CONFIG -> "config"
    MeiliCarErrorArea.AVAILABILITY -> "availability"
    MeiliCarErrorArea.COSTS -> "costs"
    MeiliCarErrorArea.CHECKOUT -> "checkout"
    MeiliCarErrorArea.RESERVATION -> "reservation"
    MeiliCarErrorArea.PARTNER_CONTENT -> "partnerContent"
}

/** The wire string sent to Dart, matching `MeiliCarErrorKind`'s values there. */
private fun MeiliCarErrorKind.wireValue(): String = when (this) {
    MeiliCarErrorKind.NETWORK -> "network"
    MeiliCarErrorKind.HTTP -> "http"
    MeiliCarErrorKind.DECODE -> "decode"
    MeiliCarErrorKind.UNEXPECTED -> "unexpected"
}
