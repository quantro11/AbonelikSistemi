import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscription_manager/models/price_history.dart';
import 'package:subscription_manager/models/subscription.dart';
import 'package:subscription_manager/services/analytics_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CurrencyConverter.load();
  });

  test('computePriceIncreases zam yüzdesini ve yıllık ek maliyeti hesaplar', () {
    final netflix = Subscription(
      id: 1,
      name: 'Netflix',
      price: 200,
      currency: 'TRY',
      billingCycle: 'monthly',
      startDate: DateTime(2025, 1, 15),
    );
    final spotify = Subscription(
      id: 2,
      name: 'Spotify',
      price: 50,
      currency: 'TRY',
      billingCycle: 'monthly',
      startDate: DateTime(2025, 1, 15),
    );

    final history = [
      PriceHistory(
        subscriptionId: 1,
        price: 100,
        currency: 'TRY',
        changedAt: DateTime(2025, 1, 15),
      ),
      PriceHistory(
        subscriptionId: 1,
        price: 200,
        currency: 'TRY',
        changedAt: DateTime(2026, 1, 15),
      ),
      // Fiyat düşüşü zam uyarısı üretmemeli.
      PriceHistory(
        subscriptionId: 2,
        price: 60,
        currency: 'TRY',
        changedAt: DateTime(2025, 1, 15),
      ),
      PriceHistory(
        subscriptionId: 2,
        price: 50,
        currency: 'TRY',
        changedAt: DateTime(2026, 1, 15),
      ),
    ];

    final alerts = AnalyticsService.computePriceIncreases(
      activeSubscriptions: [netflix, spotify],
      allPriceHistory: history,
      displayCurrency: 'TRY',
    );

    expect(alerts, hasLength(1));
    expect(alerts.single.subscription.name, 'Netflix');
    expect(alerts.single.percentChange, closeTo(100, 0.001));
    expect(alerts.single.extraYearlyCostDisplay, closeTo(1200, 0.001));
  });

  test('computeMonthlyProjection yıllık abonelikleri yalnızca yenileme ayında yansıtır', () {
    final monthly = Subscription(
      id: 1,
      name: 'Spotify',
      price: 100,
      currency: 'TRY',
      billingCycle: 'monthly',
      startDate: DateTime(2026, 1, 10),
    );
    final yearly = Subscription(
      id: 2,
      name: 'Domain',
      price: 1200,
      currency: 'TRY',
      billingCycle: 'yearly',
      startDate: DateTime(2026, 3, 5),
    );
    final cancelled = Subscription(
      id: 3,
      name: 'İptal',
      price: 500,
      currency: 'TRY',
      billingCycle: 'monthly',
      startDate: DateTime(2026, 1, 1),
      status: Subscription.cancelled,
    );

    final projection = AnalyticsService.computeMonthlyProjection(
      activeSubscriptions: [monthly, yearly, cancelled],
      displayCurrency: 'TRY',
      months: 12,
      now: DateTime(2026, 1, 15),
    );

    expect(projection, hasLength(12));
    // Ocak ve Şubat: sadece aylık (100 TRY)
    expect(projection[0].amount, closeTo(100, 0.001));
    expect(projection[1].amount, closeTo(100, 0.001));
    // Mart (index 2): aylık + yıllık (1300 TRY)
    expect(projection[2].amount, closeTo(1300, 0.001));
    expect(projection[2].renewalCount, 2);
    // Toplam 12 aylık nakit çıkışı: 12*100 + 1200 = 2400 TRY
    final total = projection.fold<double>(0, (sum, m) => sum + m.amount);
    expect(total, closeTo(2400, 0.001));
  });
}
