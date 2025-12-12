import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/android_automation/domain/services/notification_listener_service.dart';

class PermissionRequestScreen extends ConsumerStatefulWidget {
  final Widget child; // The main app content to show after permission is granted

  const PermissionRequestScreen({super.key, required this.child});

  @override
  ConsumerState<PermissionRequestScreen> createState() => _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends ConsumerState<PermissionRequestScreen> with WidgetsBindingObserver {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus(); // Recheck permission when app resumes
    }
  }

  Future<void> _checkPermissionStatus() async {
    final service = ref.read(androidNotificationListenerProvider);
    final granted = await service.checkPermission();
    if (mounted) {
      setState(() {
        _permissionGranted = granted;
      });
    }
  }

  Future<void> _openSettings() async {
    final service = ref.read(androidNotificationListenerProvider);
    await service.openNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionGranted) {
      return widget.child;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Permission Required'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_off,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'SubTrack needs Notification Access to automatically track subscriptions and expenses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _openSettings,
                  child: const Text('Grant Notification Access'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Optionally provide a way to proceed manually or show more info
                    print('User chose to proceed without permission or needs more info.');
                  },
                  child: const Text('I will do this later'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
