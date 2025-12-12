import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/android_automation/presentation/screens/permission_request_screen.dart'; // Import PermissionRequestScreen
import 'package:subtrack/src/features/categories/domain/services/initialization_service.dart'; // Import the service
import 'package:subtrack/src/presentation/app.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // Import RevenueCat
import 'package:flutter/foundation.dart'; // Import for defaultTargetPlatform

// Replace with your actual RevenueCat API keys
const String _revenueCatAppleApiKey = 'appl_YOUR_APPLE_API_KEY';
const String _revenueCatGoogleApiKey = 'goog_YOUR_GOOGLE_API_KEY';

@pragma('vm:entry-point')
void notificationListenerBackgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();
  // This is where you might set up a separate FlutterEngine to handle background tasks
  // For now, we just print to console.
  debugPrint("NotificationListenerService running in background isolate.");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized

  await Purchases.setLogLevel(LogLevel.debug); // Set log level for debugging
  
  PurchasesConfiguration configuration;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    configuration = PurchasesConfiguration(_revenueCatAppleApiKey);
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    configuration = PurchasesConfiguration(_revenueCatGoogleApiKey);
  } else {
    configuration = PurchasesConfiguration(_revenueCatGoogleApiKey); // Default or handle other platforms
  }
  await Purchases.configure(configuration);
  print('RevenueCat configured!');

  final container = ProviderContainer();
  await container.read(initializationServiceProvider).initializeApp(); // Initialize app

  runApp(
    ProviderScope(
      parent: container, // Provide the initialized container
      child: const PermissionRequestScreen( // Wrap with PermissionRequestScreen
        child: App(),
      ),
    ),
  );
}
