import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscription_manager/services/pin_lock_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isValidPin yalnızca 4 rakamı kabul eder', () {
    expect(PinLockService.isValidPin('1234'), isTrue);
    expect(PinLockService.isValidPin('0000'), isTrue);
    expect(PinLockService.isValidPin('123'), isFalse);
    expect(PinLockService.isValidPin('12345'), isFalse);
    expect(PinLockService.isValidPin('12ab'), isFalse);
  });

  test('başlangıçta PIN kilidi kapalıdır', () async {
    expect(await PinLockService.isEnabled(), isFalse);
  });

  test('setPin + verifyPin + disable tam döngüsü', () async {
    await PinLockService.setPin('4829');
    expect(await PinLockService.isEnabled(), isTrue);

    // Düz metin olarak saklanmamalı.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('pin_lock_hash'), isNot(contains('4829')));
    expect(prefs.getString('pin_lock_salt'), isNotEmpty);

    final wrong = await PinLockService.verifyPin('0000');
    expect(wrong.success, isFalse);
    expect(wrong.lockedOut, isFalse);
    expect(wrong.remainingAttempts, PinLockService.maxFailedAttempts - 1);

    final ok = await PinLockService.verifyPin('4829');
    expect(ok.success, isTrue);
    expect(ok.lockedOut, isFalse);

    await PinLockService.disable();
    expect(await PinLockService.isEnabled(), isFalse);
  });

  test('geçersiz PIN ile setPin ArgumentError fırlatır', () async {
    await expectLater(
      PinLockService.setPin('12'),
      throwsArgumentError,
    );
  });

  test('5 hatalı denemede 30 sn kilitleme uygulanır ve süre bitince açılır', () async {
    await PinLockService.setPin('9137');
    final start = DateTime(2026, 11, 22, 12, 0, 0);

    PinVerifyResult? last;
    for (var i = 0; i < PinLockService.maxFailedAttempts; i++) {
      last = await PinLockService.verifyPin('1111', now: start);
    }
    expect(last!.success, isFalse);
    expect(last.lockedOut, isTrue);
    expect(last.remainingAttempts, 0);

    // Kilit süresince doğru PIN bile reddedilir.
    final duringLockout = await PinLockService.verifyPin(
      '9137',
      now: start.add(const Duration(seconds: 10)),
    );
    expect(duringLockout.success, isFalse);
    expect(duringLockout.lockedOut, isTrue);

    // 30 saniye geçtikten sonra doğru PIN kabul edilir.
    final afterLockout = await PinLockService.verifyPin(
      '9137',
      now: start.add(const Duration(seconds: 31)),
    );
    expect(afterLockout.success, isTrue);
    expect(afterLockout.lockedOut, isFalse);
  });
}
