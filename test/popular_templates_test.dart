import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/models/categories.dart';
import 'package:subscription_manager/models/popular_templates.dart';
import 'package:subscription_manager/models/subscription.dart';

void main() {
  test('tüm hızlı şablonlar geçerli alanlara ve benzersiz adlara sahiptir', () {
    expect(PopularTemplates.all, isNotEmpty);
    final names = <String>{};
    final validCategories = {for (final c in CategoryCatalog.all) c.key};

    for (final t in PopularTemplates.all) {
      expect(t.name.trim(), isNotEmpty);
      expect(names.add(t.name.toLowerCase()), isTrue,
          reason: 'Tekrarlayan şablon adı: ${t.name}');
      expect(t.defaultPrice, greaterThan(0));
      expect(CurrencyConverter.supportedCurrencies, contains(t.currency));
      expect(['monthly', 'yearly'], contains(t.billingCycle));
      expect(validCategories, contains(t.category));
    }
  });
}
