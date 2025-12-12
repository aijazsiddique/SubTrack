import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/security/domain/services/biometric_auth_service.dart';
import 'package:subtrack/src/features/subscriptions/presentation/screens/subscriptions_screen.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _didAuthenticateOnLaunch = false; // Track if authentication happened on launch

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricsOnLaunch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkBiometricsOnLaunch() async {
    final biometricAuthService = ref.read(biometricAuthServiceProvider);
    final isAvailable = await biometricAuthService.isBiometricAvailable();
    if (isAvailable) {
      final authenticated = await biometricAuthService.authenticate();
      if (mounted) {
        setState(() {
          _isLocked = !authenticated;
          _didAuthenticateOnLaunch = authenticated;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Only re-authenticate on resume if not already authenticated on launch
      // or if app was already in a locked state
      if (!_didAuthenticateOnLaunch || _isLocked) {
        _authenticate();
      }
      _didAuthenticateOnLaunch = false; // Reset for subsequent resumes
    }
  }

  Future<void> _authenticate() async {
    final biometricAuthService = ref.read(biometricAuthServiceProvider);
    final isAvailable = await biometricAuthService.isBiometricAvailable();
    if (isAvailable) {
      final authenticated = await biometricAuthService.authenticate();
      if (mounted) {
        setState(() {
          _isLocked = !authenticated;
        });
      }
    } else {
      // If biometrics are not available, unlock the app
      if (mounted) {
        setState(() {
          _isLocked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _isLocked
          ? _LockScreen(
              onUnlock: _authenticate,
            )
          : const SubscriptionsScreen(),
    );
  }
}

class _LockScreen extends StatelessWidget {
  final VoidCallback onUnlock;

  const _LockScreen({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'SubTrack is locked',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onUnlock,
              child: const Text('Unlock with Biometrics'),
            ),
          ],
        ),
      ),
    );
  }
}
