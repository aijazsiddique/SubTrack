import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/data/database.dart';
import 'package:subtrack/src/features/transactions/domain/entities/transaction.dart';

part 'transaction_service.g.dart';

@riverpod
TransactionService transactionService(TransactionServiceRef ref) {
  return TransactionService(ref.watch(appDatabaseProvider));
}

class TransactionService {
  final AppDatabase _db;

  TransactionService(this._db);

  Future<List<Transaction>> getTransactions() async {
    final transactions = await _db.select(_db.transactions).get();
    return transactions.map((e) => _mapTransactionDataToEntity(e)).toList();
  }

  Future<Transaction> getTransaction(int id) async {
    final transactionData = await (_db.select(_db.transactions)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
    return _mapTransactionDataToEntity(transactionData);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            description: transaction.description,
            amount: transaction.amount,
            currency: transaction.currency,
            date: transaction.date,
            categoryId: Value(transaction.categoryId),
            subscriptionId: Value(transaction.subscriptionId),
            isBusinessExpense: transaction.isBusinessExpense,
            scheduleCCategory: Value(transaction.scheduleCCategory),
          ),
        );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await (_db.update(_db.transactions)..where((tbl) => tbl.id.equals(transaction.id)))
        .write(
          TransactionsCompanion(
            description: Value(transaction.description),
            amount: Value(transaction.amount),
            currency: Value(transaction.currency),
            date: Value(transaction.date),
            categoryId: Value(transaction.categoryId),
            subscriptionId: Value(transaction.subscriptionId),
            isBusinessExpense: Value(transaction.isBusinessExpense),
            scheduleCCategory: Value(transaction.scheduleCCategory),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteTransaction(int id) async {
    await (_db.delete(_db.transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Transaction>> getTransactionsInDateRange(DateTime startDate, DateTime endDate) async {
    final transactions = await (_db.select(_db.transactions)
          ..where((tbl) => tbl.date.isBetweenValues(startDate, endDate)))
        .get();
    return transactions.map((e) => _mapTransactionDataToEntity(e)).toList();
  }

  Transaction _mapTransactionDataToEntity(TransactionData data) {
    return Transaction(
      id: data.id,
      description: data.description,
      amount: data.amount,
      currency: data.currency,
      date: data.date,
      categoryId: data.categoryId,
      subscriptionId: data.subscriptionId,
      isBusinessExpense: data.isBusinessExpense,
      scheduleCCategory: data.scheduleCCategory,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
