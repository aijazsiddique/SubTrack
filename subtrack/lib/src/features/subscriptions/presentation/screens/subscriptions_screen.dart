import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/android_automation/domain/services/notification_listener_service.dart';
import 'package:subtrack/src/features/android_automation/domain/services/regex_parser_service.dart';
import 'package:subtrack/src/features/ios_automation/domain/services/ios_ocr_service.dart'; // New Import for iOS OCR
import 'package:subtrack/src/features/ios_automation/domain/services/ocr_parser_service.dart'; // New Import for OCR parsing
import 'package:subtrack/src/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:subtrack/src/features/subscriptions/presentation/screens/add_edit_subscription_screen.dart';
import 'package:subtrack/src/features/transactions/domain/entities/pending_transaction.dart'; // Import PendingTransaction
import 'package:subtrack/src/features/transactions/presentation/screens/transaction_confirmation_screen.dart'; // Import TransactionConfirmationScreen

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    _listenForNotifications();
  }

  void _listenForNotifications() {
    ref.read(androidNotificationListenerProvider).notificationStream.listen((notificationData) {
      final String? packageName = notificationData['packageName'];
      final String? title = notificationData['title'];
      final String? text = notificationData['text'];
      final String? bigText = notificationData['bigText'];

      if (packageName != null && title != null && text != null) {
        final parsedTransaction = ref.read(regexParserServiceProvider).parseNotification(title, text, packageName);

        if (parsedTransaction != null) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionConfirmationScreen(
                  pendingTransaction: parsedTransaction,
                ),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _scanDocument() async {
    final ocrService = ref.read(iosOcrServiceProvider);
    final scannedTexts = await ocrService.scanDocument();

    if (scannedTexts != null && scannedTexts.isNotEmpty) {
      final parsedTransaction = ref.read(ocrParserServiceProvider).parseOcrResult(scannedTexts);
      if (parsedTransaction != null) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TransactionConfirmationScreen(
                pendingTransaction: parsedTransaction,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not parse transaction from scanned document.')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text scanned from document.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch a provider that invalidates to trigger a refresh
    final subscriptionsAsyncValue = ref.watch(subscriptionRepositoryProvider).getSubscriptions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GroupsScreen(),
                ),
              );
            },
          ),
          IconButton( // New button for Settings
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: subscriptionsAsyncValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subscriptions found.'));
          } else {
            final subscriptions = snapshot.data!;
            return ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: InkWell(
                    // Added InkWell for tap functionality
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEditSubscriptionScreen(
                            subscription: subscription,
                          ),
                        ),
                      );
                      // Refresh the list after returning from edit screen
                      ref.invalidate(subscriptionRepositoryProvider);
                    },
                    child: Padding(
                      padding: const EdgeInsets(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Amount: ${subscription.amount.toStringAsFixed(2)} ${subscription.currency}'),
                          Text(
                              'Next Billing: ${subscription.nextBillingDate
                                  .toLocal()
                                  .toIso8601String()
                                  .split('T')[0]}'),
                          Text('Cycle: ${subscription.cycle}'),
                          if (subscription.notes != null &&
                              subscription.notes!.isNotEmpty)
                            Text('Notes: ${subscription.notes}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Column( // Use Column to stack multiple FABs
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addSubscriptionFab', // Unique tag
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditSubscriptionScreen(),
                ),
              );
              ref.invalidate(subscriptionRepositoryProvider);
            },
            label: const Text('Add Subscription'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 10), // Spacing between FABs
          FloatingActionButton.extended(
            heroTag: 'scanDocumentFab', // Unique tag
            onPressed: () async {
              await _scanDocument();
              ref.invalidate(subscriptionRepositoryProvider); // Refresh list after scan/confirm
            },
            label: const Text('Scan Document (iOS)'),
            icon: const Icon(Icons.camera_alt),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
