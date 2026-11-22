import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../app_navigation.dart';
import '../database/app_database.dart';
import '../models/subscription.dart';

/// Zamanlanacak tek bir yerel bildirim görevi (birim testlerinde doğrulanır).
class ScheduledAlert {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledLocalTime;
  final String payload;

  const ScheduledAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledLocalTime,
    required this.payload,
  });
}

/// Google Play uyumlu yerel zamanlanmış bildirim servisi.
///
/// Kalıcı ön plan servisi (`FOREGROUND_SERVICE_DATA_SYNC`) kullanmaz; bunun
/// yerine işletim sisteminin doğal zamanlayıcısı (`inexactAllowWhileIdle`) ile
/// yenileme ve deneme süresi bildirimlerini sıfır pil tüketimiyle zamanlar.
class NotificationService {
  static const int renewalNotificationBaseId = 10000;
  static const int trialNotificationBaseId = 20000;
  static const int _maxScheduledNotifications = 60;

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _tzInitialized = false;

  static const AndroidNotificationChannel _renewalChannel =
      AndroidNotificationChannel(
    'renewal_alerts',
    'Yenileme Uyarıları',
    description: 'Yaklaşan abonelik yenileme ve deneme süresi bildirimleri',
    importance: Importance.high,
  );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'renewal_alerts',
      'Yenileme Uyarıları',
      channelDescription:
          'Yaklaşan abonelik yenileme ve deneme süresi bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(),
  );

  // ---------- Kurulum ----------

  static void _ensureTimeZones() {
    if (_tzInitialized) return;
    tz_data.initializeTimeZones();
    _tzInitialized = true;
  }

  static Future<void> init() async {
    _ensureTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_renewalChannel);

    // Android 13+ için çalışma zamanı izni.
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Bildirime dokunulduğunda ilgili aboneliğin detay ekranını açar.
  /// Payload biçimi: `renewal:<id>` veya `trial:<id>`.
  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    final parts = payload.split(':');
    if (parts.length != 2) return;
    final id = int.tryParse(parts[1]);
    if (id == null) return;
    openSubscriptionFromNotification(id);
  }

  /// Android 13+ için çalışma zamanı izni ister.
  static Future<void> requestNotificationPermission() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Bildirim izni verilmiş mi? (Android'de denetler)
  static Future<bool> notificationsPermissionGranted() async {
    final enabled = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return enabled ?? true;
  }

  // ---------- Saf Zamanlama Hesabı (Test Edilebilir) ----------

  /// Aktif abonelikler için zamanlanacak tüm yaklaşan yenileme ve deneme
  /// bildirimlerini hesaplar.
  static List<ScheduledAlert> computeScheduledAlerts(
    List<Subscription> subscriptions, {
    required int alertHour,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final alerts = <ScheduledAlert>[];

    for (final s in subscriptions) {
      if (s.isCancelled || s.id == null) continue;
      final subId = s.id!;
      final symbol = CurrencyConverter.symbols[s.currency] ?? '';

      // 1) Yenileme hatırlatması: yenileme tarihinden `reminderDays` gün önce.
      final renewalDate = s.nextRenewalDateFrom(today);
      final reminderDay = renewalDate.subtract(Duration(days: s.reminderDays));
      DateTime fireAt = DateTime(
        reminderDay.year,
        reminderDay.month,
        reminderDay.day,
        alertHour,
      );
      // Hatırlatma günü geçtiyse ama yenileme hâlâ bugün/gelecekteyse,
      // bir sonraki uygun gün saatine (bugün saat geçmediyse bugün, geçtiyse yarın) planla.
      if (!fireAt.isAfter(current)) {
        final todayFire = DateTime(today.year, today.month, today.day, alertHour);
        final candidate =
            todayFire.isAfter(current) ? todayFire : todayFire.add(const Duration(days: 1));
        final renewalEndOfDay =
            DateTime(renewalDate.year, renewalDate.month, renewalDate.day, 23, 59);
        if (!candidate.isAfter(renewalEndOfDay)) {
          fireAt = candidate;
        }
      }

      if (fireAt.isAfter(current)) {
        final fireDay = DateTime(fireAt.year, fireAt.month, fireAt.day);
        final daysLeft = renewalDate.difference(fireDay).inDays;
        final when = daysLeft <= 0
            ? 'bugün'
            : daysLeft == 1
                ? 'yarın'
                : '$daysLeft gün sonra';
        alerts.add(ScheduledAlert(
          id: renewalNotificationBaseId + subId,
          title: 'Yenileme Uyarısı',
          body: 'Dikkat: ${s.name} yenilemesine $when kaldı! '
              '($symbol${s.price.toStringAsFixed(2)} ${s.currency})',
          scheduledLocalTime: fireAt,
          payload: 'renewal:$subId',
        ));
      }

      // 2) Deneme süresi bitiş uyarısı: bitişten 3 gün önce.
      final trialEnd = s.trialEndDate;
      if (trialEnd != null) {
        final trialDay = DateTime(trialEnd.year, trialEnd.month, trialEnd.day);
        if (!trialDay.isBefore(today)) {
          final trialRemind = trialDay.subtract(const Duration(days: 3));
          DateTime trialFire = DateTime(
            trialRemind.year,
            trialRemind.month,
            trialRemind.day,
            alertHour,
          );
          if (!trialFire.isAfter(current)) {
            final todayFire =
                DateTime(today.year, today.month, today.day, alertHour);
            final candidate = todayFire.isAfter(current)
                ? todayFire
                : todayFire.add(const Duration(days: 1));
            final trialEndOfDay =
                DateTime(trialDay.year, trialDay.month, trialDay.day, 23, 59);
            if (!candidate.isAfter(trialEndOfDay)) {
              trialFire = candidate;
            }
          }

          if (trialFire.isAfter(current)) {
            final fireDay =
                DateTime(trialFire.year, trialFire.month, trialFire.day);
            final daysLeft = trialDay.difference(fireDay).inDays;
            final when = daysLeft <= 0
                ? 'bugün'
                : daysLeft == 1
                    ? 'yarın'
                    : '$daysLeft gün sonra';
            alerts.add(ScheduledAlert(
              id: trialNotificationBaseId + subId,
              title: 'Deneme Süresi Uyarısı',
              body: 'Dikkat: ${s.name} deneme süresi $when sona eriyor! '
                  'İptal etmezseniz ücretlendirilir.',
              scheduledLocalTime: trialFire,
              payload: 'trial:$subId',
            ));
          }
        }
      }
    }

    alerts.sort((a, b) => a.scheduledLocalTime.compareTo(b.scheduledLocalTime));
    if (alerts.length > _maxScheduledNotifications) {
      return alerts.sublist(0, _maxScheduledNotifications);
    }
    return alerts;
  }

  // ---------- Zamanlama Senkronizasyonu ----------

  /// Tüm bekleyen yerel bildirimleri iptal eder ve aktif aboneliklere göre
  /// yeniden zamanlar. Veri her değiştiğinde güvenle çağrılabilir.
  static Future<void> syncAllScheduledAlerts() async {
    try {
      _ensureTimeZones();
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? true;

      await _notifications.cancelAll();
      if (!enabled) return;

      final alertHour = prefs.getInt('alert_hour') ?? 9;
      final active = await AppDatabase.instance.getActiveSubscriptions();
      final alerts = computeScheduledAlerts(active, alertHour: alertHour);

      for (final alert in alerts) {
        final scheduledUtc =
            tz.TZDateTime.from(alert.scheduledLocalTime.toUtc(), tz.UTC);
        await _notifications.zonedSchedule(
          alert.id,
          alert.title,
          alert.body,
          scheduledUtc,
          _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: alert.payload,
        );
      }
    } catch (_) {
      // Platform desteklemiyorsa (ör. test ortamı) uygulama akışı bozulmasın.
    }
  }

  /// Tüm zamanlanmış yerel bildirimleri iptal eder.
  static Future<void> cancelAllScheduledAlerts() async {
    try {
      await _notifications.cancelAll();
    } catch (_) {
      // Yoksay.
    }
  }
}
