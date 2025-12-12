import 'package:freezed_annotation/freezed_annotation.dart';

part 'parsed_transaction.freezed.dart';

@freezed
class ParsedTransaction with _$ParsedTransaction {
  const factory ParsedTransaction({
    required String source, // e.g., 'Notification', 'OCR'
    String? packageName, // For notifications
    required double amount,
    required String merchant,
    required DateTime date,
    required String originalText,
  }) = _ParsedTransaction;
}
