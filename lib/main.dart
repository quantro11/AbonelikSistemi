import 'package:flutter/material.dart';

import 'app_navigation.dart';
import 'models/subscription.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'services/notification_service.dart';
import 'services/pin_lock_service.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yerel bildirimlerin kurulumu ve yaklaşan hatırlatmaların zamanlanması.
  await NotificationService.init();
  await NotificationService.syncAllScheduledAlerts();

  // Kaydedilmiş tema, döviz kuru ve PIN kilidi tercihlerini yükle.
  await ThemeController.instance.load();
  await CurrencyConverter.load();
  final pinEnabled = await PinLockService.isEnabled();

  runApp(SubscriptionManagerApp(initialLocked: pinEnabled));
}

class SubscriptionManagerApp extends StatefulWidget {
  final bool initialLocked;

  const SubscriptionManagerApp({super.key, this.initialLocked = false});

  @override
  State<SubscriptionManagerApp> createState() => _SubscriptionManagerAppState();
}

class _SubscriptionManagerAppState extends State<SubscriptionManagerApp>
    with WidgetsBindingObserver {
  /// Kısa süreli dosya seçici/paylaşım geçişlerinde kullanıcıyı yormamak için
  /// arka planda 30 sn geçtikten sonra yeniden kilitle.
  static const Duration _relockGracePeriod = Duration(seconds: 30);

  late bool _locked;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    _locked = widget.initialLocked;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (pausedAt != null &&
          DateTime.now().difference(pausedAt) >= _relockGracePeriod) {
        _relockIfEnabled();
      }
    }
  }

  Future<void> _relockIfEnabled() async {
    final enabled = await PinLockService.isEnabled();
    if (!enabled || !mounted || _locked) return;
    setState(() => _locked = true);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Abonelik Yöneticisi',
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF3949AB),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF3949AB),
            brightness: Brightness.dark,
          ),
          themeMode: mode,
          home: _locked
              ? PinLockScreen(
                  mode: PinLockMode.unlock,
                  onUnlocked: () => setState(() => _locked = false),
                )
              : const DashboardScreen(),
        );
      },
    );
  }
}
