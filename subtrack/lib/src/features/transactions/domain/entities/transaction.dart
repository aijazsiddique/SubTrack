import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required int id,
    required String description,
    required double amount,
    required String currency,
    required DateTime date,
    int? categoryId,
    int? subscriptionId,
    required bool isBusinessExpense,
    String? scheduleCCategory,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;
}
