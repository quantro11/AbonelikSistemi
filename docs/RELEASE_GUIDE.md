# Yayınlama ve Google Play Rehberi (Release Guide)

Bu belge, **Abonelik Yöneticisi (`com.quantro.subscription_manager`)** uygulamasını hem **GitHub Releases (doğrudan APK)** hem de **Google Play Store (`.aab`)** üzerinden güvenle yayınlamak için gereken adımları açıklar.

---

## 1. Doğrudan APK Dağıtımı (GitHub Releases — Otomatik)

Depoya yeni bir sürüm etiketi (`v2.0.0` gibi) itildiğinde `.github/workflows/build-apk.yml` otomatik olarak çalışır ve şu 4 dosyayı GitHub Release sayfasına ekler:

1. `abonelik-yoneticisi-v2.0.0.apk` — Android cihazlara doğrudan kurulabilir APK.
2. `abonelik-yoneticisi-v2.0.0.aab` — Google Play Console yüklemesi için App Bundle.
3. `subscription_manager-v2.0.0.zip` — Kaynak kod + APK arşivi.
4. `SHA256SUMS.txt` — Dosya bütünlük doğrulama özetleri.

```bash
git tag v2.0.0
git push origin v2.0.0
```

---

## 2. Google Play İçin Üretim İmzalama Anahtarı (Keystore) Kurulumu

Google Play Store, uygulamanın kendi özel anahtarınızla imzalanmış `.aab` dosyasını zorunlu kılar. **Keystore dosyasını asla git deposuna eklemeyin!**

### Adım 1: Keystore oluşturun (tek seferlik)

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias quantro-release
```

### Adım 2: Base64'e çevirin

```bash
base64 -w 0 upload-keystore.jks > keystore.b64
```

### Adım 3: GitHub Repository Secrets ekleyin

GitHub Depo → **Settings → Secrets and variables → Actions → New repository secret** bölümüne şu 4 anahtarı ekleyin:

| Secret Adı | Değer |
| :--- | :--- |
| `ANDROID_KEYSTORE_BASE64` | `keystore.b64` içeriği (tek satır base64) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore şifreniz |
| `ANDROID_KEY_ALIAS` | `quantro-release` |
| `ANDROID_KEY_PASSWORD` | Anahtar şifreniz |

Bu 4 secret tanımlandığında GitHub Actions bir sonraki build'de **otomatik olarak üretim anahtarınızla imzalı `.apk` ve `.aab`** üretir.

---

## 3. Google Play Console Kontrol Listesi

- **Paket Kimliği:** `com.quantro.subscription_manager`
- **Gizlilik Politikası URL'si:** `https://quantro11.github.io/AbonelikSistemi/privacy.html` (veya repodaki `PRIVACY_POLICY.md`)
- **Veri Güvenliği Formu (Data Safety):** *"Hiçbir kullanıcı verisi toplanmaz ve üçüncü taraflarla paylaşılmaz"* (%100 çevrimdışı).
- **Yüklenecek Dosya:** Release sayfasındaki imzalı `abonelik-yoneticisi-v2.0.0.aab`.

---

## 4. Tanıtım & İndirme Sitesini Canlıya Alma (GitHub Pages)

1. GitHub Depo → **Settings → Pages** → Source olarak **GitHub Actions** seçin.
2. **Actions → Deploy Landing Page (GitHub Pages) → Run workflow** butonuna basın.
3. Site `https://quantro11.github.io/AbonelikSistemi/` adresinde yayına girer ve her zaman en son GitHub Release APK'sını otomatik sunar.
