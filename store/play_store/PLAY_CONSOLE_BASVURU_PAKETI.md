# Google Play Console Başvuru & Yayın Paketi (`com.quantro.subscription_manager`)

Bu klasör, **Abonelik Yöneticisi (`v2.1.0+5`, `targetSdk 36`)** uygulamasını Google Play Store'a tek seferde, politika reddi almadan yüklemen için gereken **tüm görselleri ve form metinlerini** içerir.

---

## 1. Önemli Ön Koşul (18 Yaş Altı & Play Console Hesabı)

1. **Developer Hesabı ($25 tek seferlik):** Google Play Console hesabı açmak için Google politikası gereği hesap sahibinin **18 yaşından büyük olması** ve kimlik doğrulaması yapması zorunludur. 9. sınıfta olduğun için hesabı **annen veya baban adına (veli onayıyla)** açman gerekir; uygulama geliştirici/marka adı olarak yine `Quantro` veya istediğin stüdyo adını gösterebilirsin.
2. **Kapalı Test Kuralı (12 Testçi × 14 Gün):** Kasım 2023 sonrası açılan kişisel Play Console hesaplarında "Üretime (Production)" açılmadan önce **en az 12 farklı Android kullanıcısının 14 gün kesintisiz** Kapalı Test (Closed Testing) kanalında kayıtlı kalması zorunludur.
   - **En hızlı strateji:** Okuldan 8–10 arkadaşın + aileden 4–5 kişinin Gmail adreslerini bir Google Grubuna ekle (toplam 15–16 kişi olsun ki 1–2 kişi çıkarsa 12'nin altına düşme!). Herkese opt-in linkini at, 14 gün boyunca haftada 1 kez uygulamayı açsınlar.
3. **Özel İmzalama Anahtarı (`.jks` Keystore):** Üretim `.aab` dosyasını imzalamak için tek seferlik kendi cihazında:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias quantro-release
   base64 -w 0 upload-keystore.jks > keystore.b64
   ```
   Sonra `keystore.b64` + şifreleri GitHub Depo → **Settings → Secrets and variables → Actions** altına 4 secret olarak ekle (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`) ve `git tag v2.1.1 && git push origin v2.1.1` yap → GitHub Actions **imzalı `abonelik-yoneticisi-v2.1.1.aab`** dosyasını Release'e bırakır. *(Keystore dosyasını Google Drive / USB'de yedekle — kaybedersen uygulamaya güncelleme atamazsın!)*

---

## 2. Hazır Görsel Varlıklar (`store/play_store/`)

Play Console → **Mağaza varlığı → Ana mağaza girişi** kısmına doğrudan sürükle-bırak:

| Play Console Alanı | Hazır Dosya | Boyut |
| :--- | :--- | :---: |
| **Uygulama Simgesi** | `store/play_store/icon_512x512.png` | `512 × 512 px` |
| **Öne Çıkan Grafik (Feature Graphic)** | `store/play_store/feature_graphic_1024x500.png` | `1024 × 500 px` |
| **Telefon Ekran Görüntüsü 1** | `store/play_store/screenshots/01_ana_ekran.png` | `1080 × 1920 px` |
| **Telefon Ekran Görüntüsü 2** | `store/play_store/screenshots/02_hizli_sablonlar.png` | `1080 × 1920 px` |
| **Telefon Ekran Görüntüsü 3** | `store/play_store/screenshots/03_zam_ve_projeksiyon.png` | `1080 × 1920 px` |
| **Telefon Ekran Görüntüsü 4** | `store/play_store/screenshots/04_takvim.png` | `1080 × 1920 px` |
| **Telefon Ekran Görüntüsü 5** | `store/play_store/screenshots/05_pin_kilidi.png` | `1080 × 1920 px` |
| **Telefon Ekran Görüntüsü 6** | `store/play_store/screenshots/06_ayarlar_yedek.png` | `1080 × 1920 px` |

---

## 3. Kopyala-Yapıştır Mağaza Metinleri (Türkçe — Karakter Limitli)

### Uygulama Adı *(Limit: 30 karakter — kullanılan: 19)*
```text
Abonelik Yöneticisi
```

### Kısa Açıklama *(Limit: 80 karakter — kullanılan: 76)*
```text
%100 çevrimdışı abonelik takibi, zam analizi, bütçe uyarısı ve PIN kilidi.
```

### Tam Açıklama *(Limit: 4000 karakter)*
```text
Netflix, Spotify, YouTube Premium, iCloud+, ChatGPT Plus ve tüm düzenli ödemelerinizi tek yerden takip edin — üstelik hesap açmadan, reklamsız ve %100 çevrimdışı!

Abonelik Yöneticisi, gizliliğinizi merkeze alan hafif ve modern bir kişisel finans asistanıdır. Tüm kayıtlarınız yalnızca kendi cihazınızdaki yerel SQLite veritabanında saklanır; hiçbir sunucuya gönderilmez.

ÖNE ÇIKAN ÖZELLİKLER

• Tek Dokunuşla 16 Hazır Şablon
Netflix, Spotify, YouTube Premium, Amazon Prime, Disney+, Apple Music, iCloud+, Google One, ChatGPT Plus, Claude Pro, GitHub Copilot, Microsoft 365, Xbox Game Pass, PlayStation Plus ve daha fazlasını saniyeler içinde ekleyin.

• Akıllı Yenileme ve Deneme Süresi Hatırlatmaları
Her abonelik için yenilemeden 1, 3 veya 7 gün önce yerel bildirim alın. Ücretsiz deneme süreleri bitip ücretliye geçmeden önce otomatik uyarı alarak gereksiz çekimlerin önüne geçin. Sistem zamanlayıcısıyla çalışır, pil tüketmez.

• Zam Analizi ve Fiyat Geçmişi Grafiği
Bir aboneliğin fiyatını güncellediğinizde eski fiyatlar otomatik olarak kaydedilir. Hangi servisin yüzde kaç zamlandığını ve yıllık ek maliyetini tek ekranda görün.

• 12 Aylık Ödeme Projeksiyonu & Aylık Bütçe Takibi
Yıllık aboneliklerin hangi aylarda yüksek fatura çıkaracağını önceden planlayın. Aylık bütçe hedefi belirleyin, renkli ilerleme çubuğuyla harcamanızı kontrol altında tutun.

• 4 Haneli Yerel PIN Kilidi
Finansal verilerinizi cihaz içi rastgele tuzlu SHA-256 korumasındaki 4 haneli PIN koduyla güvene alın.

• Yenileme Takvimi & Android Ana Ekran Widget'ı
Yaklaşan tüm ödemeleri aylık takvimde görün ve ana ekran widget'ıyla uygulamayı açmadan kontrol edin.

• Tam Veri Taşınabilirliği (TRY / USD / EUR)
Özel çevrimdışı döviz kurları tanımlayın. Verilerinizi JSON yedeklemesi, CSV tablosu veya Google/Apple Takvim (.ics) olarak dışa aktarın ve dilediğiniz zaman geri yükleyin.

GİZLİLİK GARANTİSİ
• Üyelik veya giriş gerekmez.
• Reklam, izleyici veya analiz SDK'sı yoktur.
• Konum, kamera, rehber veya arka plan veri toplama izni istemez.
• Açık kaynak (AGPL-3.0).
```

---

## 4. Play Console Politika Formu Cevapları (Birebir İşaretle)

| Bölüm | Seçilecek Cevap |
| :--- | :--- |
| **Kategori** | `Finans (Finance)` |
| **Ücretlendirme** | `Ücretsiz` |
| **Reklamlar (Ads)** | `Hayır, uygulamamda reklam yok` |
| **Uygulama Erişimi (App Access)** | `Tüm işlevlere özel erişim olmadan erişilebilir` *(PIN kilidi varsayılan olarak kapalıdır)* |
| **Gizlilik Politikası URL** | `https://quantro11.github.io/AbonelikSistemi/privacy.html` *(veya Vercel URL'nin `/privacy` yolu)* |
| **Veri Güvenliği (Data Safety)** | *"Uygulamanız gerekli kullanıcı veri türlerinden herhangi birini topluyor veya paylaşıyor mu?"* → **`Hayır`** (tek tıkla tamam!) |
| **Ön Plan Servisleri (Foreground Service)** | **Gerekli değil!** `v2.1.0` ile `FOREGROUND_SERVICE_DATA_SYNC` tamamen kaldırıldı — video kanıtı veya özel beyan istemez! |
| **Hedef Kitle (Target Audience)** | `13–15, 16–17, 18 ve üzeri` *(Çocuklara yönelik değil — aile politikası ekstra incelemesine takılmaz)* |
| **İçerik Derecelendirmesi (IARC)** | Kategori: `Yardımcı Program, Üretkenlik, İletişim veya Diğer` → Tüm şiddet/kumar/uygunsuz içerik/kullanıcı etkileşimi/konum paylaşımı sorularına **`Hayır`** → Sonuç: **PEGI 3 / Herkes (Everyone)**. |
| **Finansal Özellikler Beyanı** | `Uygulamam herhangi bir finansal özellik sunmuyor` *(Not: Google Play "Financial Features" beyanı kredi, banka, kripto, borsa ve ödeme aracılığı içindir; çevrimdışı manuel harcama/abonelik takipçisi kapsama girmez — "Uygulamam yalnızca manuel bütçe/harcama takibi yapar, finansal işlem veya kredi aracılığı sunmaz" seçilir).* |
| **Haber / Devlet / Sağlık Uygulaması** | Hepsine **`Hayır`**. |
