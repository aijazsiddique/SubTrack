import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/categories/data/repositories/category_repository_impl.dart';
import 'package:subtrack/src/features/categories/domain/entities/category.dart';
import 'package:subtrack/src/features/transactions/domain/entities/pending_transaction.dart';
import 'package:subtrack/src/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:subtrack/src/features/subscriptions/domain/entities/subscription.dart';
import 'package:subtrack/src/features/transactions/domain/entities/transaction.dart'; // Import Transaction entity

class TransactionConfirmationScreen extends ConsumerStatefulWidget {
  final PendingTransaction pendingTransaction;

  const TransactionConfirmationScreen({super.key, required this.pendingTransaction});

  @override
  ConsumerState<TransactionConfirmationScreen> createState() => _TransactionConfirmationScreenState();
}

class _TransactionConfirmationScreenState extends ConsumerState<TransactionConfirmationScreen> {
  Category? _selectedCategory;
  bool _isRecurring = false;
  bool _isBusinessExpense = false; // New state for business expense
  String? _selectedScheduleCCategory; // New state for Schedule C category
  final TextEditingController _cycleController = TextEditingController(text: 'monthly');

  // Predefined IRS Schedule C Categories (simplified)
  final List<String> _scheduleCCategories = [
    'Advertising',
    'Car and truck expenses',
    'Commissions and fees',
    'Contract labor',
    'Depreciation and Section 179 expense deduction',
    'Employee benefit programs',
    'Insurance',
    'Interest',
    'Legal and professional services',
    'Office expense',
    'Rent or lease (vehicles, machinery, equipment)',
    'Rent or lease (other business property)',
    'Repairs and maintenance',
    'Supplies',
    'Taxes and licenses',
    'Travel',
    'Meals (50%)',
    'Utilities',
    'Wages',
    'Other expenses',
  ];

  @override
  void initState() {
    super.initState();
    _initializeCategory();
  }

  Future<void> _initializeCategory() async {
    if (widget.pendingTransaction.categoryId != null) {
      final categories = await ref.read(categoryRepositoryProvider).getCategories();
      if (mounted) {
        setState(() {
          _selectedCategory = categories.firstWhere(
              (cat) => cat.id == widget.pendingTransaction.categoryId,
              orElse: () => categories.first // Fallback
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _cycleController.dispose();
    super.dispose();
  }

  void _confirmTransaction() async {
    // TODO: Implement actual transaction saving logic for a one-time transaction
    print('Transaction confirmed: ${widget.pendingTransaction.merchant}');
    print('Category: ${_selectedCategory?.name}');
    print('Is Recurring: $_isRecurring');
    print('Is Business Expense: $_isBusinessExpense');
    if (_isBusinessExpense) {
      print('Schedule C Category: $_selectedScheduleCCategory');
    }

    if (_isRecurring) {
      // Create a new subscription
      final newSubscription = Subscription(
        id: 0, // Will be auto-incremented by Drift
        name: widget.pendingTransaction.merchant,
        amount: widget.pendingTransaction.amount,
        currency: 'USD', // TODO: Currency detection from notification
        nextBillingDate: widget.pendingTransaction.date.add(const Duration(days: 30)), // Example
        cycle: _cycleController.text,
        notes: widget.pendingTransaction.originalText,
        categoryId: _selectedCategory?.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(subscriptionRepositoryProvider).addSubscription(newSubscription);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New subscription added!')),
      );
    } else {
      // Save as a one-time transaction
      final newTransaction = Transaction(
        id: 0, // Will be auto-incremented by Drift
        description: widget.pendingTransaction.merchant,
        amount: widget.pendingTransaction.amount,
        currency: 'USD', // Placeholder
        date: widget.pendingTransaction.date,
        categoryId: _selectedCategory?.id,
        isBusinessExpense: _isBusinessExpense,
        scheduleCCategory: _selectedScheduleCCategory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // TODO: Call a transaction repository to add this
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('One-time transaction saved!')),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoryRepositoryProvider).getCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Merchant'),
              subtitle: Text(widget.pendingTransaction.merchant),
            ),
            ListTile(
              title: const Text('Amount'),
              subtitle: Text('${widget.pendingTransaction.amount} USD'), // TODO: Currency
            ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(widget.pendingTransaction.date.toLocal().toIso8601String().split('T')[0]),
            ),
            ListTile(
              title: const Text('Source'),
              subtitle: Text(widget.pendingTransaction.source),
            ),
            categoriesAsyncValue.when(
              data: (categories) {
                if (_selectedCategory == null && categories.isNotEmpty) {
                  _selectedCategory = categories.firstWhere(
                          (cat) => cat.id == widget.pendingTransaction.categoryId,
                      orElse: () => categories.first // Fallback
                  );
                }
                return DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map((category) => DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  ))
                      .toList(),
                  onChanged: (Category? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading categories: $error'),
            ),
            Row(
              children: [
                const Text('Is this a recurring payment?'),
                Switch(
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                    });
                  },
                ),
              ],
            ),
            if (_isRecurring)
              TextFormField(
                controller: _cycleController,
                decoration: const InputDecoration(labelText: 'Billing Cycle (e.g., monthly, annually)'),
              ),
            Row(
              children: [
                const Text('Is this a business expense?'),
                Switch(
                  value: _isBusinessExpense,
                  onChanged: (value) {
                    setState(() {
                      _isBusinessExpense = value;
                      if (!value) {
                        _selectedScheduleCCategory = null; // Clear if not business
                      }
                    });
                  },
                ),
              ],
            ),
            if (_isBusinessExpense)
              DropdownButtonFormField<String>(
                value: _selectedScheduleCCategory,
                decoration: const InputDecoration(labelText: 'Schedule C Category'),
                items: _scheduleCCategories
                    .map((category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedScheduleCCategory = newValue;
                  });
                },
                validator: (value) {
                  if (_isBusinessExpense && (value == null || value.isEmpty)) {
                    return 'Please select a Schedule C category';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmTransaction,
              child: const Text('Confirm Transaction'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to SplitTransactionScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SplitTransactionScreen(
                      transaction: Transaction( // Create a dummy transaction from pending for splitting
                        id: 0, // Placeholder, actual ID will be generated
                        description: widget.pendingTransaction.merchant,
                        amount: widget.pendingTransaction.amount,
                        currency: 'USD', // Placeholder, needs actual detection
                        date: widget.pendingTransaction.date,
                        isBusinessExpense: _isBusinessExpense, // Pass business expense status
                        scheduleCCategory: _selectedScheduleCCategory, // Pass Schedule C category
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Split Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
