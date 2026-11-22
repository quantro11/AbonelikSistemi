import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yerel 4 haneli PIN kilidi servisi.
///
/// PIN düz metin olarak saklanmaz; cihazda üretilen rastgele bir tuz (salt)
/// ile birleştirilip SHA-256 özeti olarak `SharedPreferences` içinde tutulur.
class PinLockService {
  static const int pinLength = 4;
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(seconds: 30);

  static const String _keyHash = 'pin_lock_hash';
  static const String _keySalt = 'pin_lock_salt';
  static const String _keyFailedAttempts = 'pin_lock_failed_attempts';
  static const String _keyLockoutUntil = 'pin_lock_until_ms';

  static final RegExp _pinPattern = RegExp(r'^\d{4}$');

  /// Verilen metnin geçerli 4 haneli sayısal PIN olup olmadığını kontrol eder.
  static bool isValidPin(String pin) => _pinPattern.hasMatch(pin);

  /// Uygulamada PIN kilidi etkin mi?
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_keyHash);
    final salt = prefs.getString(_keySalt);
    return hash != null && hash.isNotEmpty && salt != null && salt.isNotEmpty;
  }

  /// Yeni 4 haneli PIN ayarlar veya mevcut PIN'i günceller.
  static Future<void> setPin(String pin) async {
    if (!isValidPin(pin)) {
      throw ArgumentError('PIN tam olarak 4 rakamdan oluşmalıdır.');
    }
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySalt, salt);
    await prefs.setString(_keyHash, hash);
    await prefs.remove(_keyFailedAttempts);
    await prefs.remove(_keyLockoutUntil);
  }

  /// PIN kilidini tamamen kaldırır.
  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHash);
    await prefs.remove(_keySalt);
    await prefs.remove(_keyFailedAttempts);
    await prefs.remove(_keyLockoutUntil);
  }

  /// Çok fazla hatalı deneme sonrası bekleme süresi kaldıysa döndürür.
  static Future<Duration> remainingLockout({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final untilMs = prefs.getInt(_keyLockoutUntil);
    if (untilMs == null) return Duration.zero;
    final current = now ?? DateTime.now();
    final diffMs = untilMs - current.millisecondsSinceEpoch;
    if (diffMs <= 0) {
      await prefs.remove(_keyLockoutUntil);
      await prefs.remove(_keyFailedAttempts);
      return Duration.zero;
    }
    return Duration(milliseconds: diffMs);
  }

  /// Girilen PIN'i doğrular; hatalı denemeleri sayar ve 5 hatada kısa
  /// bekleme kilidi uygular.
  static Future<PinVerifyResult> verifyPin(String pin, {DateTime? now}) async {
    final current = now ?? DateTime.now();
    final lockout = await remainingLockout(now: current);
    if (lockout > Duration.zero) {
      return PinVerifyResult(
        success: false,
        lockedOut: true,
        remainingLockout: lockout,
        remainingAttempts: 0,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(_keyHash);
    final savedSalt = prefs.getString(_keySalt);
    if (savedHash == null || savedSalt == null) {
      return const PinVerifyResult(
        success: true,
        lockedOut: false,
        remainingLockout: Duration.zero,
        remainingAttempts: maxFailedAttempts,
      );
    }

    final candidate = _hashPin(pin, savedSalt);
    if (_constantTimeEquals(candidate, savedHash)) {
      await prefs.remove(_keyFailedAttempts);
      await prefs.remove(_keyLockoutUntil);
      return const PinVerifyResult(
        success: true,
        lockedOut: false,
        remainingLockout: Duration.zero,
        remainingAttempts: maxFailedAttempts,
      );
    }

    final attempts = (prefs.getInt(_keyFailedAttempts) ?? 0) + 1;
    if (attempts >= maxFailedAttempts) {
      final until = current.add(lockoutDuration);
      await prefs.setInt(_keyFailedAttempts, attempts);
      await prefs.setInt(_keyLockoutUntil, until.millisecondsSinceEpoch);
      return const PinVerifyResult(
        success: false,
        lockedOut: true,
        remainingLockout: lockoutDuration,
        remainingAttempts: 0,
      );
    }

    await prefs.setInt(_keyFailedAttempts, attempts);
    return PinVerifyResult(
      success: false,
      lockedOut: false,
      remainingLockout: Duration.zero,
      remainingAttempts: maxFailedAttempts - attempts,
    );
  }

  static String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt::$pin::subscription_manager');
    return sha256.convert(bytes).toString();
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

/// PIN doğrulama sonucu.
class PinVerifyResult {
  final bool success;
  final bool lockedOut;
  final Duration remainingLockout;
  final int remainingAttempts;

  const PinVerifyResult({
    required this.success,
    required this.lockedOut,
    required this.remainingLockout,
    required this.remainingAttempts,
  });
}
