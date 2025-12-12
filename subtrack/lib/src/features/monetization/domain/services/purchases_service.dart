import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final purchasesServiceProvider = Provider((ref) => PurchasesService());

class PurchasesService {
  Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('premium_entitlement'); // Replace with your actual Entitlement ID
    } catch (e) {
      print("Error checking premium status: $e");
      return false;
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      print("Error getting offerings: $e");
      return null;
    }
  }

  Future<CustomerInfo> purchaseProduct(Package package) async {
    try {
      return await Purchases.purchasePackage(package);
    } catch (e) {
      print("Error purchasing product: $e");
      rethrow;
    }
  }

  Future<CustomerInfo> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      print("Error restoring purchases: $e");
      rethrow;
    }
  }
}
