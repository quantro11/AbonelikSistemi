# Değişiklik Günlüğü (Changelog)

Bu proje [Semantic Versioning](https://semver.org/) standartlarını takip eder.

## [2.1.0] — 2026-11-22 (Google Play Store Uyum Sürümü)

### Google Play Politika ve Teknik Uyumu
- **Ön Plan Servisi (`FOREGROUND_SERVICE_DATA_SYNC`) Kaldırıldı:** Google Play 2026 ön plan servisi reddi riskini sıfırlamak için 7/24 çalışan `flutter_background_service` kaldırıldı; yerine işletim sistemi düzeyinde pil dostu yerel zamanlanmış bildirimler (`zonedSchedule` + `inexactAllowWhileIdle` + `ScheduledNotificationBootReceiver`) getirildi.
- **Android 16 (`targetSdk = 36` / `compileSdk = 36`):** Google Play 2026 yeni uygulama API 36 zorunluluğu CI/Gradle hattında doğrudan sabitlendi.
- **Google Play Mağaza Başvuru Paketi (`store/play_store/`):** Zorunlu `512×512` mağaza ikonu, `1024×500` öne çıkan grafik, 6 adet `1080×1920` telefon ekran görüntüsü ve kopyala-yapıştır Play Console başvuru rehberi eklendi.
- **Canlı Çevrimdışı PWA Web Uygulaması:** `docs/app.html` (Android v2.0/v2.1 ile birebir JSON v2 uyumlu).

## [2.0.0] — 2026-11-22

### Yeni Özellikler
- **Tek Dokunuşla Hızlı Şablonlar:** Netflix, Spotify, YouTube Premium, Amazon Prime, Disney+, iCloud+, Google One, ChatGPT Plus, Claude Pro, GitHub Copilot, Xbox Game Pass ve daha fazlası dahil 16 hazır şablon.
- **4 Haneli Yerel PIN Uygulama Kilidi:** Rastgele tuzlu (salted) SHA-256 doğrulama, 5 hatalı denemede 30 sn bekleme koruması ve arka planda 30 sn sonrası otomatik yeniden kilitleme.
- **Zam Analizi (Fiyat Artışları):** İstatistikler ekranında ilk fiyata göre zamlanan abonelikleri yüzde artışı ve yıllık ek maliyetiyle otomatik listeler.
- **12 Aylık Ödeme Projeksiyonu:** Yıllık aboneliklerin yenilendiği yoğun ayları önceden gösteren 12 aylık gerçek nakit çıkışı grafiği.
- **Ana Ekran Sıralama Seçici:** Yaklaşan yenileme, en yüksek fiyat veya isme göre (A–Z) anlık sıralama.
- **Fiyat Geçmişi Yüzde Değişim Etiketleri:** Detay ekranında her fiyat değişiminin yanında `(+%X)` / `(-%X)` göstergesi.
- **JSON v2 Tam Yedekleme:** Artık abonelikler ve ödemelerle birlikte `price_history` kayıtları da yedeklenir ve geri yüklenir (v1 yedeklerle geriye uyumlu).
- **Yayın & Dağıtım Paketi:** `com.quantro.subscription_manager` paket kimliği, doğrudan indirilebilir `.apk` + Google Play `.aab` + `SHA256SUMS.txt` üretimi, `PRIVACY_POLICY.md`, tanıtım/indirme sitesi (`docs/index.html`) ve Play Store yayın rehberi (`docs/RELEASE_GUIDE.md`).

### Hata Düzeltmeleri
- **Ayarlar Çökmesi Düzeltildi:** Döviz kuru ve aylık bütçe düzenleme diyaloglarındaki `TextEditingController` erken `dispose()` hatası giderildi.
- **Kişisel Hatırlatma Günleri Aktif Edildi:** Arka plan bildirimi artık sabit 3 gün yerine her aboneliğin kendi `reminderDays` (1/3/7 gün) ayarına göre çalışır.
- **İstatistik Para Birimi ve Sıralama Düzeltmeleri:** Önümüzdeki 7 gün kartında yanlış para birimi simgesi ve yıllık aboneliklerin 1/12 hesaplanması düzeltildi; En Pahalı Abonelikler kartı artık görüntüleme para birimine çevrilerek doğru sıralanır.
- **Ay Sonu Tarih Taşması Düzeltildi:** 31 Ocak başlayan aylık abonelikler artık 3 Mart yerine 28/29 Şubat'a sabitlenir.
- **Arama Temizleme & Kopya İptal UX Düzeltmeleri:** Arama kutusu temizleme butonu metni gerçekten sıfırlar; kopya uyarısından vazgeçildiğinde Kaydet butonu artık kilitli kalmaz.
- **Sıkı CI Kalite Kapısı:** `.github/workflows/build-apk.yml` içindeki tüm `continue-on-error: true` maskeleri kaldırıldı; `flutter analyze`, `flutter test`, APK ve AAB derlemeleri zorunlu hâle getirildi.

## [1.2.0] — 2026-08-03
- Fiyat geçmişi çizgi grafiği, aylık yenileme takvimi, aylık bütçe ilerleme çubuğu ve Android ana ekran widget'ı eklendi.

## [1.1.0] — 2026-08-02
- Çevrimdışı döviz kuru yönetimi, bildirim derin bağlantısı, son 6 ay gerçek harcama analizi, CSV içe/dışa aktarma, kopya abonelik uyarısı ve Hakkında ekranı eklendi.

## [1.0.1] — 2026-08-01
- İlk sürüm: çevrimdışı SQLite abonelik takibi, yerel sabah 09:00 bildirimleri, kategori filtresi, ödeme geçmişi, JSON/CSV/ICS dışa aktarma.
