import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/debts/domain/entities/group.dart';
import 'package:subtrack/src/features/debts/domain/entities/transaction_split.dart';
import 'package:subtrack/src/features/transactions/domain/entities/transaction.dart';
import 'package:subtrack/src/features/users/domain/entities/user.dart'; // Import User entity

final debtSimplificationServiceProvider = Provider((ref) => DebtSimplificationService());

class DebtSimplificationService {
  Map<int, double> simplifyDebts(List<Transaction> transactions, List<TransactionSplit> splits, List<User> users) {
    // 1. Calculate net balance for each user
    Map<int, double> netBalances = {};
    for (var user in users) {
      netBalances[user.id] = 0.0;
    }

    // Apply transaction amounts to net balances (simplified for now - assumes each transaction
    // has a single payer and splits represent who owes what for that transaction)
    // A more robust implementation would need to parse transactions based on splits to determine
    // who initially paid and who owes. For this algorithm, we just need net owed/owing.
    // For demonstration, let's assume `splits` already represent the individual amounts each user owes/is owed for a transaction.
    // In a real scenario, you'd calculate net balances from the transactions and their splits.
    // Example: If Transaction 1 for 100 paid by User A, split equally by A, B, C:
    // A: +100 (paid) - (100/3) (self-share) - (100/3) (B's share) - (100/3) (C's share)
    // B: -(100/3)
    // C: -(100/3)
    // A's net = 100 - 33.33 - 33.33 = +33.34 (B and C each owe A 33.33)

    // For the current structure, we'll assume a simplified input where `splits`
    // already reflect the net amount each user has to pay or receive for a transaction.
    // This is typically the output of a transaction splitting logic.
    // If a Transaction represents an expense of 100, and User 1 pays it,
    // and it's split equally between User 1, 2, 3:
    // User 1 balance += (100 - 100/3) = 66.67
    // User 2 balance -= (100/3) = -33.33
    // User 3 balance -= (100/3) = -33.33

    // For simplicity, let's use a dummy net balance map to demonstrate the algorithm
    // In a real app, `netBalances` would be calculated based on all `transactions` and `splits`.
    final Map<int, double> tempNetBalances = {
      1: -50.0, // User with ID 1 owes 50
      2: 100.0, // User with ID 2 is owed 100
      3: -50.0, // User with ID 3 owes 50
    };


    List<MapEntry<int, double>> debtors = tempNetBalances.entries.where((entry) => entry.value < 0).toList();
    List<MapEntry<int, double>> creditors = tempNetBalances.entries.where((entry) => entry.value > 0).toList();

    // Sort by absolute value (largest first for greedy approach)
    debtors.sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    creditors.sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    Map<String, double> payments = {}; // "PayerId_PayeeId": amount

    while (debtors.isNotEmpty && creditors.isNotEmpty) {
      final debtor = debtors.first;
      final creditor = creditors.first;

      final amountToSettle = min(debtor.value.abs(), creditor.value.abs());

      // Record payment: debtor.key pays amountToSettle to creditor.key
      payments["${debtor.key}_${creditor.key}"] = amountToSettle;

      // Update balances
      debtors[0] = MapEntry(debtor.key, debtor.value + amountToSettle); // Debtor pays, so their debt reduces (becomes less negative)
      creditors[0] = MapEntry(creditor.key, creditor.value - amountToSettle); // Creditor receives, so their credit reduces (becomes less positive)

      // Remove users whose balances become (close to) zero
      if (debtors[0].value.abs() < 0.01) { // Use a small epsilon for floating point comparison
        debtors.removeAt(0);
      }
      if (creditors[0].value.abs() < 0.01) {
        creditors.removeAt(0);
      }

      // Re-sort (optional, but ensures greedy strategy on remaining largest amounts)
      debtors.sort((a, b) => b.value.abs().compareTo(a.value.abs()));
      creditors.sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    }

    return payments;
  }
}

// Helper function for min
double min(double a, double b) {
  return a < b ? a : b;
}
