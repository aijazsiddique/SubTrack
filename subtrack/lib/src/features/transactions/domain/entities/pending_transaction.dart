import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_transaction.freezed.dart';

@freezed
class PendingTransaction with _$PendingTransaction {
  const factory PendingTransaction({
    required String source,
    String? packageName,
    required double amount,
    required String merchant,
    required DateTime date,
    required String originalText,
    int? categoryId,
    int? subscriptionId,
  }) = _PendingTransaction;
}
