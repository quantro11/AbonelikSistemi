import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/pin_lock_service.dart';

/// PIN ekranının çalışma modu.
enum PinLockMode {
  /// Uygulama açılışında / arka plandan dönüşte kilit açma.
  unlock,

  /// Ayarlardan yeni 4 haneli PIN belirleme (iki kez girerek onay).
  setup,

  /// Ayarlardan mevcut PIN'i doğrulayıp kilidi kaldırma.
  disable,
}

/// 4 haneli PIN giriş ve yönetim ekranı.
class PinLockScreen extends StatefulWidget {
  final PinLockMode mode;
  final VoidCallback? onUnlocked;

  const PinLockScreen({
    super.key,
    required this.mode,
    this.onUnlocked,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _entered = '';
  String? _firstSetupPin;
  String? _errorMessage;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode != PinLockMode.setup) {
      _checkLockout();
    }
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLockout() async {
    final remaining = await PinLockService.remainingLockout();
    if (!mounted || remaining <= Duration.zero) return;
    _startLockoutCountdown(remaining.inSeconds + 1);
  }

  void _startLockoutCountdown(int seconds) {
    _lockoutTimer?.cancel();
    setState(() {
      _lockoutSeconds = seconds;
      _errorMessage =
          'Çok fazla hatalı deneme. $_lockoutSeconds sn bekleyin.';
    });
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockoutSeconds <= 1) {
        timer.cancel();
        setState(() {
          _lockoutSeconds = 0;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _lockoutSeconds--;
          _errorMessage =
              'Çok fazla hatalı deneme. $_lockoutSeconds sn bekleyin.';
        });
      }
    });
  }

  String get _title {
    switch (widget.mode) {
      case PinLockMode.unlock:
        return 'Uygulama Kilidi';
      case PinLockMode.setup:
        return _firstSetupPin == null ? 'Yeni PIN Belirle' : 'PIN\'i Doğrula';
      case PinLockMode.disable:
        return 'PIN Kilidini Kaldır';
    }
  }

  String get _subtitle {
    switch (widget.mode) {
      case PinLockMode.unlock:
        return 'Devam etmek için 4 haneli PIN kodunuzu girin.';
      case PinLockMode.setup:
        return _firstSetupPin == null
            ? 'Abonelik verilerinizi korumak için 4 haneli PIN seçin.'
            : 'Onaylamak için aynı 4 haneli PIN\'i tekrar girin.';
      case PinLockMode.disable:
        return 'Kilidi kaldırmak için mevcut PIN kodunuzu girin.';
    }
  }

  Future<void> _onDigitTap(String digit) async {
    if (_busy || _lockoutSeconds > 0) return;
    if (_entered.length >= PinLockService.pinLength) return;

    HapticFeedback.selectionClick();
    setState(() {
      _entered += digit;
      _errorMessage = null;
    });

    if (_entered.length == PinLockService.pinLength) {
      await _handleComplete(_entered);
    }
  }

  void _onBackspace() {
    if (_busy || _entered.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _entered = _entered.substring(0, _entered.length - 1);
    });
  }

  Future<void> _handleComplete(String pin) async {
    setState(() => _busy = true);
    try {
      switch (widget.mode) {
        case PinLockMode.setup:
          if (_firstSetupPin == null) {
            setState(() {
              _firstSetupPin = pin;
              _entered = '';
              _busy = false;
            });
            return;
          }
          if (_firstSetupPin != pin) {
            HapticFeedback.heavyImpact();
            setState(() {
              _firstSetupPin = null;
              _entered = '';
              _errorMessage = 'PIN kodları eşleşmedi. Tekrar deneyin.';
              _busy = false;
            });
            return;
          }
          await PinLockService.setPin(pin);
          HapticFeedback.mediumImpact();
          if (mounted) Navigator.of(context).pop(true);
          return;

        case PinLockMode.unlock:
        case PinLockMode.disable:
          final result = await PinLockService.verifyPin(pin);
          if (!mounted) return;
          if (result.success) {
            if (widget.mode == PinLockMode.disable) {
              await PinLockService.disable();
              HapticFeedback.mediumImpact();
              if (mounted) Navigator.of(context).pop(true);
            } else {
              HapticFeedback.lightImpact();
              widget.onUnlocked?.call();
            }
            return;
          }
          HapticFeedback.heavyImpact();
          setState(() {
            _entered = '';
            _busy = false;
          });
          if (result.lockedOut) {
            _startLockoutCountdown(result.remainingLockout.inSeconds + 1);
          } else {
            setState(() {
              _errorMessage =
                  'Hatalı PIN. Kalan deneme: ${result.remainingAttempts}';
            });
          }
      }
    } finally {
      if (mounted && _busy) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canPop = widget.mode != PinLockMode.unlock;

    return Scaffold(
      appBar: canPop ? AppBar(title: Text(_title)) : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.lock_outline,
                      size: 32,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(PinLockService.pinLength, (index) {
                      final filled = index < _entered.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: _errorMessage != null
                                ? colorScheme.error
                                : colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 22,
                    child: _errorMessage == null
                        ? null
                        : Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  _buildKeypad(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(ColorScheme colorScheme) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map((digit) => _digitButton(digit, colorScheme))
                  .toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72, height: 72),
            _digitButton('0', colorScheme),
            SizedBox(
              width: 72,
              height: 72,
              child: IconButton(
                tooltip: 'Sil',
                onPressed: _entered.isEmpty ? null : _onBackspace,
                icon: const Icon(Icons.backspace_outlined, size: 26),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _digitButton(String digit, ColorScheme colorScheme) {
    return SizedBox(
      width: 72,
      height: 72,
      child: FilledButton.tonal(
        onPressed: _lockoutSeconds > 0 ? null : () => _onDigitTap(digit),
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
