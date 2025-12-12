import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getSubscriptions();
  Future<Subscription> getSubscription(int id);
  Future<void> addSubscription(Subscription subscription);
  Future<void> updateSubscription(Subscription subscription);
  Future<void> deleteSubscription(int id);
}
