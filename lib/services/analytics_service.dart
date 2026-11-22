import '../models/price_history.dart';
import '../models/subscription.dart';

/// Fiyat artışı (zam) özeti.
class PriceIncreaseAlert {
  final Subscription subscription;
  final double initialPrice;
  final double currentPrice;
  final double percentChange;
  final double extraYearlyCostDisplay;

  const PriceIncreaseAlert({
    required this.subscription,
    required this.initialPrice,
    required this.currentPrice,
    required this.percentChange,
    required this.extraYearlyCostDisplay,
  });
}

/// Gelecek bir ay için tahmini nakit akışı.
class MonthlyProjection {
  final int year;
  final int month;
  final double amount;
  final int renewalCount;

  const MonthlyProjection({
    required this.year,
    required this.month,
    required this.amount,
    required this.renewalCount,
  });
}

/// Saf finansal analiz fonksiyonları (zam tespiti ve 12 aylık nakit projeksiyonu).
class AnalyticsService {
  /// Aktif abonelikler içinde ilk kayda göre fiyatı artanları tespit eder
  /// ve yüzde artışa göre büyükten küçüğe sıralar.
  static List<PriceIncreaseAlert> computePriceIncreases({
    required List<Subscription> activeSubscriptions,
    required List<PriceHistory> allPriceHistory,
    required String displayCurrency,
  }) {
    final bySub = <int, List<PriceHistory>>{};
    for (final entry in allPriceHistory) {
      bySub.putIfAbsent(entry.subscriptionId, () => []).add(entry);
    }

    final alerts = <PriceIncreaseAlert>[];
    for (final s in activeSubscriptions) {
      final id = s.id;
      if (id == null) continue;
      final entries = bySub[id];
      if (entries == null || entries.length < 2) continue;

      final sorted = [...entries]
        ..sort((a, b) => a.changedAt.compareTo(b.changedAt));
      final first = sorted.first;
      final latest = sorted.last;

      final initialInCurrent = CurrencyConverter.convert(
        first.price,
        first.currency,
        s.currency,
      );
      if (initialInCurrent <= 0) continue;

      final currentPrice = CurrencyConverter.convert(
        latest.price,
        latest.currency,
        s.currency,
      );
      final diff = currentPrice - initialInCurrent;
      if (diff <= 0.009) continue;

      final percent = (diff / initialInCurrent) * 100;
      final yearlyDiffOriginal =
          s.billingCycle == 'yearly' ? diff : diff * 12;
      final extraYearlyDisplay = CurrencyConverter.convert(
        yearlyDiffOriginal,
        s.currency,
        displayCurrency,
      );

      alerts.add(PriceIncreaseAlert(
        subscription: s,
        initialPrice: initialInCurrent,
        currentPrice: currentPrice,
        percentChange: percent,
        extraYearlyCostDisplay: extraYearlyDisplay,
      ));
    }

    alerts.sort((a, b) => b.percentChange.compareTo(a.percentChange));
    return alerts;
  }

  /// Önümüzdeki [months] ay için (bu ay dahil) gerçek nakit çıkış
  /// projeksiyonunu hesaplar. Yıllık abonelikler yalnızca yenilendikleri ayda
  /// tam tutarlarıyla yansır.
  static List<MonthlyProjection> computeMonthlyProjection({
    required List<Subscription> activeSubscriptions,
    required String displayCurrency,
    int months = 12,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final startMonth = DateTime(reference.year, reference.month);
    final result = <MonthlyProjection>[];

    for (var i = 0; i < months; i++) {
      final monthStart = DateTime(startMonth.year, startMonth.month + i);
      var total = 0.0;
      var count = 0;

      for (final s in activeSubscriptions) {
        if (s.isCancelled) continue;
        final hitsMonth = _renewsInMonth(s, monthStart.year, monthStart.month);
        if (!hitsMonth) continue;
        total += CurrencyConverter.convert(
          s.price,
          s.currency,
          displayCurrency,
        );
        count++;
      }

      result.add(MonthlyProjection(
        year: monthStart.year,
        month: monthStart.month,
        amount: total,
        renewalCount: count,
      ));
    }

    return result;
  }

  static bool _renewsInMonth(Subscription s, int year, int month) {
    final targetIndex = year * 12 + month;
    final startIndex = s.startDate.year * 12 + s.startDate.month;
    if (targetIndex < startIndex) return false;
    if (s.billingCycle == 'yearly') {
      return (targetIndex - startIndex) % 12 == 0;
    }
    return true;
  }
}
