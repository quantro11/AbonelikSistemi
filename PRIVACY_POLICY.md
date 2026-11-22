# Gizlilik Politikası / Privacy Policy

**Son Güncelleme / Last Updated:** 22 Kasım 2026  
**Uygulama / App:** Abonelik Yöneticisi (`com.quantro.subscription_manager`)  
**Geliştirici / Developer:** Quantro (Faruk Hilmi Akpınar)

---

## Türkçe

**Abonelik Yöneticisi**, gizlilik öncelikli ve **%100 çevrimdışı (offline)** çalışan bir kişisel finans uygulamasıdır.

1. **Toplanan Veriler:** Uygulama hiçbir kişisel veri, finansal kayıt, cihaz kimliği, konum bilgisi veya kullanım analitiği **toplamaz, iletmez veya üçüncü taraflarla paylaşmaz**.
2. **Yerel Depolama:** Eklediğiniz tüm abonelikler, ödeme geçmişi, fiyat geçmişi, bütçe hedefleri ve ayarlar yalnızca kendi cihazınızdaki yerel SQLite veritabanında (`subscriptions.db`) ve cihaz tercihlerinde (`SharedPreferences`) saklanır.
3. **PIN Kilidi Güvenliği:** PIN kilidini etkinleştirdiğinizde girdiğiniz 4 haneli kod hiçbir zaman düz metin olarak saklanmaz; cihazda üretilen rastgele bir tuz (salt) ile birlikte SHA-256 özetine dönüştürülerek yalnızca yerel olarak tutulur.
4. **İnternet ve Sunucu Erişimi:** Uygulamanın herhangi bir uzak sunucusu, kullanıcı hesabı, reklam SDK'sı veya izleyici kütüphanesi yoktur.
5. **Kullanıcı İzinleri:**
   - `POST_NOTIFICATIONS`: Yaklaşan yenileme ve deneme süresi hatırlatmalarını göstermek için.
   - `RECEIVE_BOOT_COMPLETED`: Cihaz yeniden başlatıldığında Android sistem zamanlayıcısındaki yerel hatırlatmaların kaybolmaması için.
   *(Uygulama kalıcı ön plan servisi, konum, kamera, mikrofon veya rehber izni **istemez**.)*
6. **Veri Kontrolü ve Silme:** Ayarlar ekranından tüm verilerinizi JSON/CSV/ICS olarak dışa aktarabilir veya uygulamayı kaldırdığınızda cihazdaki tüm yerel verilerin kalıcı olarak silinmesini sağlayabilirsiniz.
7. **İletişim:** Gizlilikle ilgili sorularınız için GitHub deposu üzerinden iletişime geçebilirsiniz: `https://github.com/quantro11/AbonelikSistemi/issues`

---

## English

**Abonelik Yöneticisi (Subscription Manager)** is a privacy-first, **100% offline** personal finance application.

1. **Data Collection:** The app does **not** collect, transmit, sell, or share any personal data, financial records, device identifiers, location data, or usage analytics.
2. **Local Storage:** All subscriptions, payment logs, price history, budgets, and preferences are stored exclusively on your device using local SQLite storage and `SharedPreferences`.
3. **PIN Lock Security:** When enabled, your 4-digit PIN is never stored in plaintext; it is hashed locally with SHA-256 and a per-device cryptographically random salt.
4. **No Servers / No Trackers:** There is no backend server, account registration, advertising SDK, or third-party analytics library.
5. **Device Permissions:** Android `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED` permissions are used solely to deliver OS-scheduled local renewal and free-trial expiration reminders. No foreground service, location, camera, microphone, or contact permissions are requested.
6. **Data Control & Deletion:** You can export your data anytime (JSON, CSV, ICS) or delete all local data permanently by uninstalling the app or clearing app storage.
7. **Contact:** For privacy questions, open an issue at `https://github.com/quantro11/AbonelikSistemi/issues`.
