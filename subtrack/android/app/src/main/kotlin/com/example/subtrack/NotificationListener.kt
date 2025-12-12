package com.example.subtrack

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService(), MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val TAG = "NotificationListener"
    private var flutterEngine: FlutterEngine? = null // Will be assigned in onCreate
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    companion object {
        private const val METHOD_CHANNEL_NAME = "com.subtrack.app/control"
        private const val EVENT_CHANNEL_NAME = "com.subtrack.app/stream"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "NotificationListenerService created")
        flutterEngine = MainActivity.backgroundFlutterEngine
        if (flutterEngine == null) {
            Log.e(TAG, "Background FlutterEngine is null in NotificationListenerService onCreate. The service might not function correctly.")
            // Consider adding retry logic or a way to notify the user/main activity
            return
        }
        setupChannels()
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "NotificationListenerService destroyed")
        tearDownChannels()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        sbn?.let {
            val packageName = it.packageName
            val title = it.notification.extras.getString("android.title")
            val text = it.notification.extras.getString("android.text")
            val bigText = it.notification.extras.getString("android.bigText")

            Log.d(TAG, "Notification Posted: " +
                    "Package: $packageName, " +
                    "Title: $title, " +
                    "Text: $text, " +
                    "Big Text: $bigText")

            // Send notification data to Flutter
            val notificationData = mapOf(
                "packageName" to packageName,
                "title" to title,
                "text" to text,
                "bigText" to bigText
            )
            eventSink?.success(notificationData)
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
        sbn?.let {
            Log.d(TAG, "Notification Removed: ${it.packageName}")
        }
    }

    private fun setupChannels() {
        if (flutterEngine == null) {
            Log.e(TAG, "FlutterEngine is null, cannot set up channels.")
            return
        }
        methodChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterEngine!!.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel?.setStreamHandler(this)
    }

    private fun tearDownChannels() {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermission" -> {
                val isEnabled = isNotificationServiceEnabled(this)
                result.success(isEnabled)
            }
            "openSettings" -> {
                openNotificationSettings(this)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun isNotificationServiceEnabled(context: Context): Boolean {
        val packageName = context.packageName
        val flat = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
        return flat != null && flat.contains(packageName)
    }

    private fun openNotificationSettings(context: Context) {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
}
