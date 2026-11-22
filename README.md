# Abonelik Yöneticisi (`AbonelikSistemi` v2.0)

[![Build & Release](https://github.com/quantro11/AbonelikSistemi/actions/workflows/build-apk.yml/badge.svg)](https://github.com/quantro11/AbonelikSistemi/actions/workflows/build-apk.yml)
[![Latest Release](https://img.shields.io/github/v/release/quantro11/AbonelikSistemi?label=S%C3%BCr%C3%BCm)](https://github.com/quantro11/AbonelikSistemi/releases/latest)
[![License: AGPL v3](https://img.shields.io/badge/Lisans-AGPL--3.0-blue.svg)](LICENSE)
[![Offline First](https://img.shields.io/badge/%C3%87evrimd%C4%B1%C5%9F%C4%B1-%25100%20Yerel-22c55e.svg)](PRIVACY_POLICY.md)

Tamamen **çevrimdışı (offline)**, sunucusuz, reklamsız ve gizlilik öncelikli **Kişisel Finans ve Abonelik Yönetimi** uygulaması (Flutter + SQLite).  
Paket kimliği: `com.quantro.subscription_manager`

> **Hemen İndir (Android APK):** [Son Sürüm APK & AAB İndirme Sayfası](https://github.com/quantro11/AbonelikSistemi/releases/latest)  
> **Gizlilik Politikası:** [PRIVACY_POLICY.md](PRIVACY_POLICY.md) • **Yayınlama Rehberi:** [docs/RELEASE_GUIDE.md](docs/RELEASE_GUIDE.md) • **Değişiklik Günlüğü:** [CHANGELOG.md](CHANGELOG.md)

---

## Özellikler (`v2.0.0`)

| Modül | Özellikler |
| :--- | :--- |
| **Ana Ekran (Dashboard)** | Büyük puntolu aylık toplam gider, aylık bütçe ilerleme çubuğu ve aşım uyarısı, arama, kategori filtreleri, **sıralama (Yaklaşan / En Pahalı / A–Z)**, iptal/geri alma ve bildirim izin banner'ı. |
| **Tek Dokunuşla Şablonlar** | Netflix, Spotify, YouTube Premium, Amazon Prime, Disney+, iCloud+, Google One, ChatGPT Plus, Claude Pro, GitHub Copilot, Xbox Game Pass ve daha fazlası dahil **16 hazır servis şablonu**. |
| **4 Haneli PIN Kilidi** | Cihaz içi rastgele tuzlu **SHA-256** özetleme, 5 hatalı denemede 30 sn koruma kilidi ve arka planda 30 sn sonra otomatik yeniden kilitleme. |
| **Zam Analizi & Fiyat Geçmişi** | Her fiyat değişikliği otomatik kaydedilir; detayda çizgi grafik + `(+%X)` değişim etiketleri, istatistiklerde **Zam Alan Abonelikler** ve yıllık ek maliyet özeti. |
| **12 Aylık Ödeme Projeksiyonu** | Yıllık aboneliklerin yenilendiği yoğun ayları önceden gösteren 12 aylık gerçek nakit çıkışı analizi. |
| **İstatistikler** | Aylık/yıllık toplam, önümüzdeki 7 gün gerçek fatura tutarı, kategori donut grafiği, son 6 ay gerçek ödeme geçmişi ve kur dönüşümlü en pahalı abonelikler. |
| **Yenileme Takvimi & Widget** | Ay sonu taşmasız (31 Ocak → 28/29 Şubat) interaktif yenileme takvimi + **Android ana ekran widget'ı** (`SubscriptionWidgetProvider.kt`). |
| **Akıllı Yerel Bildirimler** | Her aboneliğin kendi **hatırlatma gününe (1/3/7 gün önce)** göre günlük kontrol + ücretsiz deneme bitiş uyarısı + bildirime dokununca derin bağlantı. |
| **Tam Veri Taşınabilirliği** | **JSON v2 tam yedekleme** (abonelikler + ödemeler + fiyat geçmişi; değiştir/birleştir), **CSV içe/dışa aktarma**, **Takvim (.ics) dışa aktarma** ve çevrimdışı özel döviz kurları (TRY / USD / EUR). |

---

## Proje Yapısı

```text
AbonelikSistemi/
├── lib/
│   ├── main.dart                         # Uygulama başlangıcı, tema, kur ve PIN kilidi kapısı
│   ├── app_info.dart                     # Sürüm (2.0.0), paket kimliği ve uygulama meta verisi
│   ├── app_navigation.dart               # Bildirim derin bağlantı yönlendiricisi
│   ├── database/app_database.dart        # SQLite şeması (v5), CRUD, hatırlatma & fiyat geçmişi sorguları
│   ├── models/
│   │   ├── subscription.dart             # Yenileme hesabı (ay sonu güvenli) ve CurrencyConverter
│   │   ├── popular_templates.dart        # 16 popüler servis hızlı ekleme şablonu
│   │   ├── payment.dart                  # Ödeme geçmişi modeli
│   │   ├── price_history.dart            # Fiyat değişim geçmişi modeli
│   │   └── categories.dart               # Kategori renk ve ikon kataloğu
│   ├── screens/
│   │   ├── dashboard_screen.dart         # Ana ekran, bütçe, arama, sıralama ve filtreleme
│   │   ├── add_subscription_screen.dart  # Ekle/düzenle formu + hızlı şablon çubuğu
│   │   ├── subscription_detail_screen.dart # Detay, fiyat grafiği (% değişim) ve ödemeler
│   │   ├── insights_screen.dart          # Zam analizi, 12 aylık projeksiyon, donut ve harcama
│   │   ├── calendar_screen.dart          # Aylık yenileme takvimi
│   │   ├── settings_screen.dart          # Tema, kur, PIN kilidi, bütçe, bildirim ve yedekleme
│   │   └── pin_lock_screen.dart          # 4 haneli PIN giriş/kurulum/kaldırma ekranı
│   ├── services/
│   │   ├── notification_service.dart     # Yerel bildirimler ve arka plan servisi
│   │   ├── pin_lock_service.dart         # Tuzlu SHA-256 PIN doğrulama ve kilitleme
│   │   ├── analytics_service.dart        # Zam tespiti ve 12 aylık nakit projeksiyonu
│   │   ├── export_service.dart           # JSON v2, CSV ve ICS içe/dışa aktarma
│   │   └── widget_service.dart           # Android App Widget köprüsü
│   ├── theme/theme_controller.dart       # Açık/koyu/sistem tema yöneticisi
│   └── widgets/empty_state.dart          # Ortak boş durum bileşeni
├── android/                              # Manifest, uygulama ikonları, splash ve Kotlin App Widget
├── test/                                 # 8 kapsamlı birim test dosyası (SQLite FFI, PIN, Analiz, Export)
├── docs/                                 # Tanıtım/indirme sitesi (index.html, privacy.html) ve Yayın Rehberi
├── .github/workflows/                    # Sıkı CI: analyze + test + Release APK & Play Store AAB
├── PRIVACY_POLICY.md                     # Türkçe + İngilizce Gizlilik Politikası
└── CHANGELOG.md                          # Sürüm geçmişi
```

---

## Geliştirici Kurulumu ve Test

```bash
# 1. Depoyu klonlayın
git clone https://github.com/quantro11/AbonelikSistemi.git
cd AbonelikSistemi

# 2. Android platform dosyalarını oluşturun (mevcut özelleştirmeler korunur)
flutter create --org com.quantro --project-name subscription_manager --platforms=android .
rm -f test/widget_test.dart

# 3. Bağımlılıkları yükleyin, statik analiz ve tüm testleri çalıştırın
flutter pub get
flutter analyze
flutter test

# 4. Android cihazda çalıştırın veya Release APK / AAB üretin
flutter run
flutter build apk --release
flutter build appbundle --release
```

> **Android Arka Plan Notu:** `AndroidManifest.xml` içindeki `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` ve `FOREGROUND_SERVICE_DATA_SYNC` izinleri yalnızca yerel yenileme bildirimleri içindir. Kesintisiz arka plan hatırlatması için cihaz pil ayarlarından uygulamanın pil optimizasyonundan muaf tutulması önerilir.

---

## Otomatik Derleme ve Yayınlama (CI/CD)

Her `main` güncellemesinde ve `v*` etiketinde GitHub Actions otomatik olarak:
1. `flutter analyze` (sıfır hata/uyarı) çalıştırır,
2. `flutter test` tüm birim testlerini geçirir,
3. Release **`.apk`** + Google Play **`.aab`** + **`.zip`** + **`SHA256SUMS.txt`** paketlerini üretir.

Play Store üretim keystore imzalama ve GitHub Pages canlı site kurulumu için bkz. [docs/RELEASE_GUIDE.md](docs/RELEASE_GUIDE.md).

---

## Lisans

Bu proje **GNU Affero General Public License v3.0 (AGPL-3.0)** ile lisanslanmıştır — bkz. [LICENSE](LICENSE).
