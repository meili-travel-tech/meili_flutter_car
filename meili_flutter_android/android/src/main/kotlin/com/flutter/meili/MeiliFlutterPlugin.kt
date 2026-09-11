package com.flutter.meili

import android.app.Activity
import android.util.Log
import androidx.activity.ComponentActivity
import com.meili.travel.api.AvailParams
import com.meili.travel.api.MeiliActivity
import com.meili.travel.api.MeiliComposeListener
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
    private var rawActivity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "meili_flutter")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "meili_flutter/events")
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
                    val message = if (rawActivity != null) {
                        "Your MainActivity must extend FlutterFragmentActivity. The Meili plugin needs " +
                            "an androidx ComponentActivity host, but the attached activity " +
                            "(${rawActivity?.javaClass?.name}) is not one."
                    } else {
                        "No Android Activity is attached to the Flutter engine."
                    }
                    result.error("NO_ACTIVITY", message, null)
                    return
                }
                @Suppress("UNCHECKED_CAST")
                val args = call.arguments as Map<String, Any?>
                val ptid = args["ptid"] as? String ?: run {
                    result.error("MISSING_PTID", "ptid is required", null)
                    return
                }

                MeiliActivity.start(
                    context = act,
                    ptid = ptid,
                    env = parseEnv(args["env"] as? String),
                    flow = parseFlow(args["flow"] as? String),
                    availParams = parseAvailParams(args["availParams"] as? Map<*, *>)
                        ?: AvailParams(null, null, null, null, null, null, null, null, null),
                    additionalParams = parseAdditionalParams(args["additionalParams"] as? Map<*, *>),
                    listener = object : MeiliComposeListener {
                        override fun onEndBookingFlow(callback: (() -> Unit)?) {
                            eventSink?.success(mapOf("type" to "bookingFlowEnded"))
                            callback?.invoke()
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
        bindActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        clearActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        bindActivity(binding)
    }

    override fun onDetachedFromActivity() {
        clearActivity()
    }

    private fun bindActivity(binding: ActivityPluginBinding) {
        rawActivity = binding.activity
        activity = binding.activity as? ComponentActivity
        if (activity == null) {
            Log.w(
                "MeiliFlutterPlugin",
                "Host activity ${binding.activity.javaClass.name} is not a ComponentActivity; " +
                    "MainActivity must extend FlutterFragmentActivity for the Meili plugin to work.",
            )
        }
    }

    private fun clearActivity() {
        activity = null
        rawActivity = null
    }
}
