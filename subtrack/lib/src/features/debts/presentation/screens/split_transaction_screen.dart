import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/debts/data/repositories/group_repository_impl.dart';
import 'package:subtrack/src/features/debts/data/services/group_service.dart'; // Assuming GroupService also provides User related operations
import 'package:subtrack/src/features/debts/domain/entities/group.dart';
import 'package:subtrack/src/features/transactions/domain/entities/transaction.dart';
import 'package:subtrack/src/features/users/data/repositories/user_repository_impl.dart'; // For user data

class SplitTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction; // Optional: if splitting an existing transaction

  const SplitTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<SplitTransactionScreen> createState() => _SplitTransactionScreenState();
}

class _SplitTransactionScreenState extends ConsumerState<SplitTransactionScreen> {
  Group? _selectedGroup;
  List<User> _selectedUsers = [];
  Map<User, TextEditingController> _splitAmountControllers = {};
  final TextEditingController _totalAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _totalAmountController.text = widget.transaction!.amount.toStringAsFixed(2);
    }
    // Listen for changes in selected group or users to update split amounts
    // This is a simplified approach. In a real app, you'd use Riverpod providers
    // to manage the state of selected users and dynamically update controllers.
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _splitAmountControllers.forEach((key, value) => value.dispose());
    super.dispose();
  }

  void _updateSplitAmounts(double totalAmount) {
    if (_selectedUsers.isEmpty) return;

    double amountPerUser = totalAmount / _selectedUsers.length;
    _splitAmountControllers.forEach((user, controller) {
      controller.text = amountPerUser.toStringAsFixed(2);
    });
  }

  void _saveSplits() {
    // TODO: Implement actual saving of splits to the database
    // This would involve creating TransactionSplit entries
    print('Saving splits for group: ${_selectedGroup?.name}');
    _splitAmountControllers.forEach((user, controller) {
      print('${user.name} owes: ${controller.text}');
    });

    Navigator.of(context).pop(); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsyncValue = ref.watch(groupRepositoryProvider).getGroups();
    final usersAsyncValue = ref.watch(userRepositoryProvider).getUsers(); // Assuming all users can be part of any group for now

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<List<Group>>(
              future: groupsAsyncValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading groups: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No groups available. Create one first.');
                } else {
                  final groups = snapshot.data!;
                  if (_selectedGroup == null && groups.isNotEmpty) {
                    _selectedGroup = groups.first;
                  }
                  return DropdownButtonFormField<Group>(
                    value: _selectedGroup,
                    decoration: const InputDecoration(labelText: 'Select Group'),
                    items: groups.map((group) => DropdownMenuItem<Group>(
                      value: group,
                      child: Text(group.name),
                    )).toList(),
                    onChanged: (Group? newValue) {
                      setState(() {
                        _selectedGroup = newValue;
                        _selectedUsers = []; // Clear selected users when group changes
                        _splitAmountControllers.clear();
                      });
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<User>>(
              future: usersAsyncValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading users: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No users available.');
                } else {
                  final allUsers = snapshot.data!;
                  // Filter users potentially by group membership later
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Participants:'),
                      ...allUsers.map((user) {
                        return CheckboxListTile(
                          title: Text(user.name),
                          value: _selectedUsers.contains(user),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedUsers.add(user);
                                _splitAmountControllers[user] = TextEditingController();
                              } else {
                                _selectedUsers.remove(user);
                                _splitAmountControllers.remove(user)?.dispose();
                              }
                              _updateSplitAmounts(double.tryParse(_totalAmountController.text) ?? 0.0);
                            });
                          },
                        );
                      }).toList(),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalAmountController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final totalAmount = double.tryParse(value) ?? 0.0;
                _updateSplitAmounts(totalAmount);
              },
            ),
            const SizedBox(height: 16),
            const Text('Individual Splits:'),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedUsers.length,
                itemBuilder: (context, index) {
                  final user = _selectedUsers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(user.name)),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _splitAmountControllers[user],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSplits,
              child: const Text('Save Splits'),
            ),
            const SizedBox(height: 10),
            if (_selectedUsers.isNotEmpty && (double.tryParse(_totalAmountController.text) ?? 0.0) > 0)
              ElevatedButton(
                onPressed: () {
                  // Navigate to DebtSettlementScreen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DebtSettlementScreen(
                        transactions: widget.transaction != null ? [widget.transaction!] : [], // Pass transaction if available
                      ),
                    ),
                  );
                },
                child: const Text('View Debt Settlement Plan'),
              ),
          ],
        ),
      ),
    );
  }
}
