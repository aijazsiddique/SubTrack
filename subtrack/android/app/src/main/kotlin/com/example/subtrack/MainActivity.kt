package com.example.subtrack

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain

class MainActivity : FlutterActivity() {
    companion object {
        private const val BACKGROUND_CHANNEL_NAME = "com.subtrack.app/background"
        @JvmStatic
        var backgroundFlutterEngine: FlutterEngine? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Set up the foreground channel if needed (e.g., to trigger background tasks)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_CHANNEL_NAME).setMethodCallHandler { call, result ->
            if (call.method == "startBackgroundService") {
                // This might be called from Dart to ensure the background service starts/is running
                // For now, the service starts automatically.
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        // Initialize the background FlutterEngine if it's not already running
        if (backgroundFlutterEngine == null) {
            backgroundFlutterEngine = FlutterEngine(context)
            val callbackHandle = FlutterMain.findAppBundlePath(context)
            if (callbackHandle != null) {
                val callbackInfo = FlutterCallbackInformation.getCallbackInformation(
                    callbackHandle
                )
                if (callbackInfo != null) {
                    backgroundFlutterEngine?.dartExecutor?.executeDartCallback(
                        DartExecutor.DartCallback(
                            context.assets,
                            callbackHandle,
                            callbackInfo
                        )
                    )
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        // Optionally clean up backgroundFlutterEngine here if lifecycle matches.
        // For persistent background, it might not be destroyed with main activity.
    }
}
