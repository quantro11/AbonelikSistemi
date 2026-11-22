import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/models/subscription.dart';
import 'package:subscription_manager/services/notification_service.dart';

void main() {
  test('computeScheduledAlerts her aboneliğin reminderDays ayarına göre planlar', () {
    final now = DateTime(2026, 11, 22, 8, 0);
    final subs = [
      Subscription(
        id: 1,
        name: 'Netflix',
        price: 189.99,
        currency: 'TRY',
        billingCycle: 'monthly',
        startDate: DateTime(2026, 11, 30),
        reminderDays: 7,
      ),
      Subscription(
        id: 2,
        name: 'Spotify',
        price: 59.99,
        currency: 'TRY',
        billingCycle: 'monthly',
        startDate: DateTime(2026, 11, 28),
        reminderDays: 3,
      ),
      Subscription(
        id: 3,
        name: 'İptal Edilen',
        price: 99,
        currency: 'TRY',
        billingCycle: 'monthly',
        startDate: DateTime(2026, 11, 25),
        status: Subscription.cancelled,
      ),
    ];

    final alerts = NotificationService.computeScheduledAlerts(
      subs,
      alertHour: 9,
      now: now,
    );

    expect(alerts, hasLength(2));
    // Netflix: 30 Kasım - 7 gün = 23 Kasım 09:00
    expect(alerts.first.id, NotificationService.renewalNotificationBaseId + 1);
    expect(alerts.first.scheduledLocalTime, DateTime(2026, 11, 23, 9, 0));
    expect(alerts.first.payload, 'renewal:1');
    expect(alerts.first.body, contains('Netflix'));

    // Spotify: 28 Kasım - 3 gün = 25 Kasım 09:00
    expect(alerts.last.id, NotificationService.renewalNotificationBaseId + 2);
    expect(alerts.last.scheduledLocalTime, DateTime(2026, 11, 25, 9, 0));
    expect(alerts.last.payload, 'renewal:2');
  });

  test('computeScheduledAlerts deneme bitişi için ayrı bildirim üretir', () {
    final now = DateTime(2026, 11, 22, 8, 0);
    final sub = Subscription(
      id: 10,
      name: 'YouTube Premium',
      price: 79.99,
      currency: 'TRY',
      billingCycle: 'monthly',
      startDate: DateTime(2026, 12, 10),
      trialEndDate: DateTime(2026, 11, 27),
      reminderDays: 3,
    );

    final alerts = NotificationService.computeScheduledAlerts(
      [sub],
      alertHour: 10,
      now: now,
    );

    expect(alerts, hasLength(2));
    final trial = alerts.firstWhere((a) => a.payload == 'trial:10');
    expect(trial.id, NotificationService.trialNotificationBaseId + 10);
    // 27 Kasım - 3 gün = 24 Kasım 10:00
    expect(trial.scheduledLocalTime, DateTime(2026, 11, 24, 10, 0));
    expect(trial.title, 'Deneme Süresi Uyarısı');
  });
}
