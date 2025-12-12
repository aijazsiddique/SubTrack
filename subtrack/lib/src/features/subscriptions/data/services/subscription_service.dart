import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/data/database.dart';
import 'package:subtrack/src/features/subscriptions/domain/entities/subscription.dart';

part 'subscription_service.g.dart';

@riverpod
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  return SubscriptionService(ref.watch(appDatabaseProvider));
}

class SubscriptionService {
  final AppDatabase _db;

  SubscriptionService(this._db);

  Future<List<Subscription>> getSubscriptions() async {
    final subscriptions = await _db.select(_db.subscriptions).get();
    return subscriptions.map((e) => _mapSubscriptionDataToEntity(e)).toList();
  }

  Future<Subscription> getSubscription(int id) async {
    final subscriptionData = await (_db.select(_db.subscriptions)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
    return _mapSubscriptionDataToEntity(subscriptionData);
  }

  Future<void> addSubscription(Subscription subscription) async {
    await _db.into(_db.subscriptions).insert(
          SubscriptionsCompanion.insert(
            name: subscription.name,
            amount: subscription.amount,
            currency: subscription.currency,
            nextBillingDate: subscription.nextBillingDate,
            cycle: subscription.cycle,
            notes: Value(subscription.notes),
            categoryId: Value(subscription.categoryId),
          ),
        );
  }

  Future<void> updateSubscription(Subscription subscription) async {
    await (_db.update(_db.subscriptions)
          ..where((tbl) => tbl.id.equals(subscription.id)))
        .write(
          SubscriptionsCompanion(
            name: Value(subscription.name),
            amount: Value(subscription.amount),
            currency: Value(subscription.currency),
            nextBillingDate: Value(subscription.nextBillingDate),
            cycle: Value(subscription.cycle),
            notes: Value(subscription.notes),
            categoryId: Value(subscription.categoryId),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteSubscription(int id) async {
    await (_db.delete(_db.subscriptions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Subscription _mapSubscriptionDataToEntity(SubscriptionData data) {
    return Subscription(
      id: data.id,
      name: data.name,
      amount: data.amount,
      currency: data.currency,
      nextBillingDate: data.nextBillingDate,
      cycle: data.cycle,
      notes: data.notes,
      categoryId: data.categoryId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
