import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required int id,
    required String name,
    required double amount,
    required String currency,
    required DateTime nextBillingDate,
    required String cycle,
    String? notes,
    int? categoryId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subscription;
}
