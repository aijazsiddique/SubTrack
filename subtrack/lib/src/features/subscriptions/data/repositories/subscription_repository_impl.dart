import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/features/subscriptions/data/services/subscription_service.dart';
import 'package:subtrack/src/features/subscriptions/domain/entities/subscription.dart';
import 'package:subtrack/src/features/subscriptions/domain/repositories/subscription_repository.dart';

part 'subscription_repository_impl.g.dart';

@riverpod
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  return SubscriptionRepositoryImpl(ref.watch(subscriptionServiceProvider));
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionService _subscriptionService;

  SubscriptionRepositoryImpl(this._subscriptionService);

  @override
  Future<void> addSubscription(Subscription subscription) {
    return _subscriptionService.addSubscription(subscription);
  }

  @override
  Future<void> deleteSubscription(int id) {
    return _subscriptionService.deleteSubscription(id);
  }

  @override
  Future<Subscription> getSubscription(int id) {
    return _subscriptionService.getSubscription(id);
  }

  @override
  Future<List<Subscription>> getSubscriptions() {
    return _subscriptionService.getSubscriptions();
  }

  @override
  Future<void> updateSubscription(Subscription subscription) {
    return _subscriptionService.updateSubscription(subscription);
  }
}
