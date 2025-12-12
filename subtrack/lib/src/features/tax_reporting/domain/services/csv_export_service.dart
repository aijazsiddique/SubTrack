import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/transactions/data/repositories/transaction_repository_impl.dart'; // Assuming TransactionRepository exists
import 'package:subtrack/src/features/transactions/domain/entities/transaction.dart';
import 'package:csv/csv.dart'; // Add csv dependency to pubspec.yaml
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final csvExportServiceProvider = Provider((ref) => CsvExportService(ref.read(transactionRepositoryProvider)));

class CsvExportService {
  final TransactionRepository _transactionRepository;

  CsvExportService(this._transactionRepository);

  Future<String> exportTransactionsToCsv(DateTime startDate, DateTime endDate) async {
    final transactions = await _transactionRepository.getTransactionsInDateRange(startDate, endDate);

    List<List<dynamic>> rows = [];
    rows.add([
      'ID',
      'Description',
      'Amount',
      'Currency',
      'Date',
      'Category ID',
      'Subscription ID',
      'Is Business Expense',
      'Schedule C Category',
      'Created At',
      'Updated At'
    ]); // CSV Header

    for (var transaction in transactions) {
      rows.add([
        transaction.id,
        transaction.description,
        transaction.amount,
        transaction.currency,
        transaction.date.toIso8601String(),
        transaction.categoryId,
        transaction.subscriptionId,
        transaction.isBusinessExpense,
        transaction.scheduleCCategory,
        transaction.createdAt.toIso8601String(),
        transaction.updatedAt.toIso8601String(),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Save the CSV to a file (example)
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/tax_report_${DateTime.now().toIso8601String().split('T')[0]}.csv';
    final file = File(path);
    await file.writeAsString(csv);

    return path; // Return the path to the saved CSV file
  }
}
