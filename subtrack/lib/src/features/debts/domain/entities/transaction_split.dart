import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_split.freezed.dart';

@freezed
class TransactionSplit with _$TransactionSplit {
  const factory TransactionSplit({
    required int id,
    required int transactionId,
    required int userId,
    required double amount, // Amount for this specific split (e.g., amount owed by userId)
    int? groupId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionSplit;
}
