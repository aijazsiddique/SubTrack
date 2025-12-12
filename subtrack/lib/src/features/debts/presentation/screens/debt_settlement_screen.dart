import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/debts/domain/services/debt_simplification_service.dart';
import 'package:subtrack/src/features/transactions/domain/entities/transaction.dart'; // Placeholder
import 'package:subtrack/src/features/users/data/repositories/user_repository_impl.dart'; // To get user names

class DebtSettlementScreen extends ConsumerStatefulWidget {
  final List<Transaction> transactions; // Transactions that need to be settled
  // For simplicity, we'll pass transactions directly. In a real app,
  // these would be fetched or managed via a state provider for a specific group.

  const DebtSettlementScreen({super.key, required this.transactions});

  @override
  ConsumerState<DebtSettlementScreen> createState() => _DebtSettlementScreenState();
}

class _DebtSettlementScreenState extends ConsumerState<DebtSettlementScreen> {
  Map<String, double> _simplifiedPayments = {};

  @override
  void initState() {
    super.initState();
    _calculateSimplifiedDebts();
  }

  Future<void> _calculateSimplifiedDebts() async {
    final users = await ref.read(userRepositoryProvider).getUsers();
    // For a real application, you would pass relevant splits here
    final simplified = ref.read(debtSimplificationServiceProvider).simplifyDebts(widget.transactions, [], users);
    setState(() {
      _simplifiedPayments = simplified;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simplified Debt Settlement'),
      ),
      body: _simplifiedPayments.isEmpty
          ? const Center(child: Text('No debts to settle or calculations in progress.'))
          : ListView.builder(
              itemCount: _simplifiedPayments.length,
              itemBuilder: (context, index) {
                final entry = _simplifiedPayments.entries.elementAt(index);
                final payerId = int.parse(entry.key.split('_')[0]);
                final payeeId = int.parse(entry.key.split('_')[1]);
                final amount = entry.value;

                return FutureBuilder(
                  future: Future.wait([
                    ref.read(userRepositoryProvider).getUser(payerId),
                    ref.read(userRepositoryProvider).getUser(payeeId),
                  ]),
                  builder: (context, AsyncSnapshot<List<User>> userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(title: Text('Loading users...'));
                    } else if (userSnapshot.hasError) {
                      return ListTile(title: Text('Error loading user: ${userSnapshot.error}'));
                    } else if (!userSnapshot.hasData || userSnapshot.data!.length < 2) {
                      return const ListTile(title: Text('User data missing.'));
                    } else {
                      final payer = userSnapshot.data![0];
                      final payee = userSnapshot.data![1];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('${payer.name} pays ${payee.name}'),
                          subtitle: Text('Amount: ${amount.toStringAsFixed(2)}'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
