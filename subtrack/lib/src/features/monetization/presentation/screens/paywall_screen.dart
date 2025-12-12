import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:subtrack/src/features/monetization/domain/services/purchases_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Offerings? _offerings;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _offerings = await ref.read(purchasesServiceProvider).getOfferings();
      if (_offerings == null || _offerings!.current == null) {
        _errorMessage = 'No offerings found.';
      }
    } catch (e) {
      _errorMessage = 'Failed to load offerings: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final customerInfo = await ref.read(purchasesServiceProvider).purchaseProduct(package);
      if (customerInfo.entitlements.active.containsKey('premium_entitlement')) {
        if (mounted) {
          Navigator.of(context).pop(); // Go back after successful purchase
        }
      } else {
        _errorMessage = 'Purchase successful but entitlement not found.';
      }
    } catch (e) {
      _errorMessage = 'Purchase failed: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final customerInfo = await ref.read(purchasesServiceProvider).restorePurchases();
      if (customerInfo.entitlements.active.containsKey('premium_entitlement')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        _errorMessage = 'No active purchases found to restore.';
      }
    } catch (e) {
      _errorMessage = 'Restore failed: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchOfferings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _offerings!.current != null
                  ? ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        Text(
                          _offerings!.current!.serverDescription,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ..._offerings!.current!.availablePackages.map((package) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(package.storeProduct.title),
                              subtitle: Text(package.storeProduct.description),
                              trailing: ElevatedButton(
                                onPressed: () => _purchasePackage(package),
                                child: Text(package.storeProduct.priceString),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _restorePurchases,
                          child: const Text('Restore Purchases'),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('No current offerings available.'),
                    ),
    );
  }
}
