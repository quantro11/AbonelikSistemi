/// Sık kullanılan abonelikler için tek dokunuşla doldurulabilen şablonlar.
class SubscriptionTemplate {
  final String name;
  final double defaultPrice;
  final String currency;
  final String billingCycle;
  final String category;

  const SubscriptionTemplate({
    required this.name,
    required this.defaultPrice,
    required this.currency,
    required this.billingCycle,
    required this.category,
  });
}

/// Türkiye ve global popüler dijital servis şablonları.
class PopularTemplates {
  static const List<SubscriptionTemplate> all = [
    SubscriptionTemplate(
      name: 'Netflix',
      defaultPrice: 189.99,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'video',
    ),
    SubscriptionTemplate(
      name: 'Spotify',
      defaultPrice: 59.99,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'music',
    ),
    SubscriptionTemplate(
      name: 'YouTube Premium',
      defaultPrice: 79.99,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'video',
    ),
    SubscriptionTemplate(
      name: 'Amazon Prime',
      defaultPrice: 49.90,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'video',
    ),
    SubscriptionTemplate(
      name: 'Disney+',
      defaultPrice: 164.90,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'video',
    ),
    SubscriptionTemplate(
      name: 'Apple Music',
      defaultPrice: 59.99,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'music',
    ),
    SubscriptionTemplate(
      name: 'iCloud+',
      defaultPrice: 39.99,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'cloud',
    ),
    SubscriptionTemplate(
      name: 'Google One',
      defaultPrice: 49.99,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'cloud',
    ),
    SubscriptionTemplate(
      name: 'ChatGPT Plus',
      defaultPrice: 20.00,
      currency: 'USD',
      billingCycle: 'monthly',
      category: 'software',
    ),
    SubscriptionTemplate(
      name: 'Claude Pro',
      defaultPrice: 20.00,
      currency: 'USD',
      billingCycle: 'monthly',
      category: 'software',
    ),
    SubscriptionTemplate(
      name: 'GitHub Copilot',
      defaultPrice: 10.00,
      currency: 'USD',
      billingCycle: 'monthly',
      category: 'software',
    ),
    SubscriptionTemplate(
      name: 'Microsoft 365',
      defaultPrice: 249.99,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'software',
    ),
    SubscriptionTemplate(
      name: 'Xbox Game Pass',
      defaultPrice: 209.00,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'games',
    ),
    SubscriptionTemplate(
      name: 'PlayStation Plus',
      defaultPrice: 240.00,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'games',
    ),
    SubscriptionTemplate(
      name: 'Spor Salonu',
      defaultPrice: 1200.00,
      currency: 'TRY',
      billingCycle: 'monthly',
      category: 'fitness',
    ),
    SubscriptionTemplate(
      name: 'Domain / Sunucu',
      defaultPrice: 15.00,
      currency: 'USD',
      billingCycle: 'yearly',
      category: 'software',
    ),
  ];
}
