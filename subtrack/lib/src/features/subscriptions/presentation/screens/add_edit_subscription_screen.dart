import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/categories/data/repositories/category_repository_impl.dart'; // Import CategoryRepository
import 'package:subtrack/src/features/categories/domain/entities/category.dart'; // Import Category entity
import 'package:subtrack/src/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:subtrack/src/features/subscriptions/domain/entities/subscription.dart';

class AddEditSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription? subscription;

  const AddEditSubscriptionScreen({super.key, this.subscription});

  @override
  ConsumerState<AddEditSubscriptionScreen> createState() => _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends ConsumerState<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _currencyController;
  late TextEditingController _cycleController;
  late TextEditingController _notesController;
  late DateTime _nextBillingDate;
  Category? _selectedCategory;
  bool _isBusinessExpense = false; // New state for business expense
  String? _selectedScheduleCCategory; // New state for Schedule C category

  // Predefined IRS Schedule C Categories (simplified) - copied from TransactionConfirmationScreen for consistency
  final List<String> _scheduleCCategories = [
    'Advertising', 'Car and truck expenses', 'Commissions and fees', 'Contract labor',
    'Depreciation and Section 179 expense deduction', 'Employee benefit programs',
    'Insurance', 'Interest', 'Legal and professional services', 'Office expense',
    'Rent or lease (vehicles, machinery, equipment)', 'Rent or lease (other business property)',
    'Repairs and maintenance', 'Supplies', 'Taxes and licenses', 'Travel', 'Meals (50%)',
    'Utilities', 'Wages', 'Other expenses',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subscription?.name);
    _amountController = TextEditingController(text: widget.subscription?.amount.toString());
    _currencyController = TextEditingController(text: widget.subscription?.currency ?? 'USD');
    _cycleController = TextEditingController(text: widget.subscription?.cycle ?? 'monthly');
    _notesController = TextEditingController(text: widget.subscription?.notes);
    _nextBillingDate = widget.subscription?.nextBillingDate ?? DateTime.now();
    _isBusinessExpense = widget.subscription?.isBusinessExpense ?? false; // Initialize business expense
    _selectedScheduleCCategory = widget.subscription?.scheduleCCategory; // Initialize schedule C category
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _cycleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _nextBillingDate) {
      setState(() {
        _nextBillingDate = picked;
      });
    }
  }

  void _saveSubscription() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final subscription = Subscription(
        id: widget.subscription?.id ?? 0, // 0 for new subscription, ID for existing
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        currency: _currencyController.text,
        nextBillingDate: _nextBillingDate,
        cycle: _cycleController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        categoryId: _selectedCategory?.id, // Assign selected category ID
        isBusinessExpense: _isBusinessExpense, // Save business expense status
        scheduleCCategory: _selectedScheduleCCategory, // Save Schedule C category
        createdAt: widget.subscription?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(subscriptionRepositoryProvider);

      if (widget.subscription == null) {
        // Add new subscription
        await repository.addSubscription(subscription);
      } else {
        // Update existing subscription
        await repository.updateSubscription(subscription);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoryRepositoryProvider).getCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription == null ? 'Add Subscription' : 'Edit Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _currencyController,
                decoration: const InputDecoration(labelText: 'Currency (e.g., USD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  'Next Billing Date: ${_nextBillingDate.toLocal().toIso8601String().split('T')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: _cycleController,
                decoration: const InputDecoration(labelText: 'Billing Cycle (e.g., monthly, annually)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a billing cycle';
                  }
                  return null;
                },
              ),
              FutureBuilder<List<Category>>(
                future: categoriesAsyncValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading categories: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No categories available.');
                  } else {
                    final categories = snapshot.data!;
                    if (widget.subscription != null && _selectedCategory == null) {
                      _selectedCategory = categories.firstWhere(
                        (cat) => cat.id == widget.subscription!.categoryId,
                        orElse: () => categories.first,
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
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    );
                  }
                },
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
                          _selectedScheduleCCategory = null;
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
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 3,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _saveSubscription,
                  child: Text(widget.subscription == null ? 'Add Subscription' : 'Update Subscription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
