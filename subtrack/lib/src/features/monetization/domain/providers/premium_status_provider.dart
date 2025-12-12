import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:subtrack/src/features/monetization/domain/services/purchases_service.dart';

part 'premium_status_provider.g.dart';

@riverpod
Stream<bool> premiumStatus(PremiumStatusRef ref) async* {
  final purchasesService = ref.watch(purchasesServiceProvider);

  // Initial check
  yield await purchasesService.isPremium();

  // Listen for changes in customer info (e.g., after a purchase or restore)
  await for (final customerInfo in Purchases.getCustomerInfoStream()) {
    yield customerInfo.entitlements.active.containsKey('premium_entitlement');
  }
}
