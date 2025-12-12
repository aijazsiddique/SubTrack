import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final androidNotificationListenerProvider = Provider((ref) => AndroidNotificationListenerService());

class AndroidNotificationListenerService {
  static const MethodChannel _methodChannel = MethodChannel('com.subtrack.app/control');
  static const EventChannel _eventChannel = EventChannel('com.subtrack.app/stream');

  Stream<Map<String, dynamic>> get notificationStream => _eventChannel
      .receiveBroadcastStream()
      .map((event) => Map<String, dynamic>.from(event as Map));

  Future<bool> checkPermission() async {
    try {
      final bool? isEnabled = await _methodChannel.invokeMethod('checkPermission');
      return isEnabled ?? false;
    } on PlatformException catch (e) {
      print("Failed to check permission: '${e.message}'.");
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      await _methodChannel.invokeMethod('openSettings');
    } on PlatformException catch (e) {
      print("Failed to open settings: '${e.message}'.");
    }
  }
}
