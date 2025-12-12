import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/features/transactions/data/services/transaction_service.dart';
import 'package:subtrack/src/features/transactions/domain/entities/transaction.dart';
import 'package:subtrack/src/features/transactions/domain/repositories/transaction_repository.dart';

part 'transaction_repository_impl.g.dart';

@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return TransactionRepositoryImpl(ref.watch(transactionServiceProvider));
}

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionService _transactionService;

  TransactionRepositoryImpl(this._transactionService);

  @override
  Future<void> addTransaction(Transaction transaction) {
    return _transactionService.addTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(int id) {
    return _transactionService.deleteTransaction(id);
  }

  @override
  Future<Transaction> getTransaction(int id) {
    return _transactionService.getTransaction(id);
  }

  @override
  Future<List<Transaction>> getTransactions() {
    return _transactionService.getTransactions();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) {
    return _transactionService.updateTransaction(transaction);
  }

  @override
  Future<List<Transaction>> getTransactionsInDateRange(DateTime startDate, DateTime endDate) {
    return _transactionService.getTransactionsInDateRange(startDate, endDate);
  }
}
