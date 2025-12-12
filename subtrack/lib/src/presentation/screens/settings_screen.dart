import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/monetization/presentation/screens/paywall_screen.dart'; // Import PaywallScreen
import 'package:subtrack/src/features/tax_reporting/domain/services/csv_export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monetization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PaywallScreen(),
                  ),
                );
              },
              child: const Text('Go Premium'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tax Reporting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final startDate = DateTime(2023, 1, 1); // Example range
                final endDate = DateTime(2023, 12, 31);
                final csvPath = await ref.read(csvExportServiceProvider).exportTransactionsToCsv(startDate, endDate);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('CSV exported to: $csvPath'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
              child: const Text('Export Transactions to CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
