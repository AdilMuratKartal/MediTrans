# MediTrans — Proje Mimarisi ve Tasarım Dokümanı

**MediTrans**, nefes egzersizleri, beden/yoga akışları, Hz frekans rezonansları, uyku sesleri/hikayeleri, haftalık duygu durumu takibi ve analiz grafiklerini bir araya getiren çapraz platform (iOS/Android/Web) Flutter meditasyon uygulamasıdır.

> Paket bilgisi: `meditrans` (`version: 1.0.0+1`, Dart SDK `^3.13.5`, paket kimliği `com.example.meditrans`, Firebase projesi `meditrans-2ff48`).  
> Tasarım ilkesi: Uygulamada **maskot veya GIF karakter kullanılmaz**; tüm görsel dil Stitch **Ethereal Aura Mind** cam yüzeyleri, ortam ışık küreleri ve sade emoji/ikon anlatımı üzerine kuruludur.

---

## 1. Mevcut Altyapı ve Başlangıç Durumu

Depoda hâlihazırda bulunan çekirdek bileşenler:

| Bileşen                 | Dosya / Konum                                                                          | Mevcut Durum                                                                                                                                                                                                                                                                 |
| :---------------------- | :------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Giriş noktası           | [lib/main.dart](lib/main.dart)                                                         | `MediTransApp`, Material 3, **Ethereal Aura Mind** gündüz yüzeyi (`#FBF8FF`) ve birincil ton (`#60538D`)                                                                                                                                                                     |
| Ana sayfa ekranı        | [lib/screens/home_screen.dart](lib/screens/home_screen.dart)                           | Stitch `ana_sayfa_duygu_durumu` tasarımına uyumlu haftalık ritim takvimi, emoji duygu çipleri, modal bottom sheet, not girişi, devam kartı ve 3 sekmeli yüzen alt navigasyon                                                                                                 |
| Firebase yapılandırması | [lib/firebase_options.dart](lib/firebase_options.dart), [firebase.json](firebase.json) | `meditrans-2ff48` projesi (`android`, `ios`, `macos`, `web`, `windows`) — **Spark ücretsiz plan** (`firebase_auth`, `cloud_firestore`, `firebase_messaging`; ücretli Blaze gerektiren `firebase_storage` kullanılmaz; `pubspec.yaml`'da `firebase_core` henüz ekli değildir) |
| Android ayarları        | [android/app/build.gradle.kts](android/app/build.gradle.kts)                           | `com.example.meditrans`, `com.google.gms.google-services`, JVM 17                                                                                                                                                                                                            |
| Testler                 | [test/widget_test.dart](test/widget_test.dart)                                         | Stitch Ana Sayfa, emoji duygu modalı ve 3 sekmeli navigasyon widget testi                                                                                                                                                                                                    |

---

## 2. Görsel Tasarım Sistemi — _Ethereal Aura Mind_

Tasarım dili `stitch_meditasyon_uygulamas_aray_z/stitch_meditasyon_uygulamas_aray_z/ethereal_aura_mind/DESIGN.md` dokümanına dayanır.

### 2.1 Temel İlkeler

1. **Aura Camı (Aura Glass):** Sayfalar sert bloklar değil, arkadan gelen pastel suluboya ışık kürelerinin (`lavender`, `sage`, `peach`, `sunset`) üzerine oturan yarı saydam buzlu cam (`BackdropFilter` / `sigmaX: 20–24`) yüzeylerden oluşur.
2. **"No-Line" (Çizgisiz Derinlik) Kuralı:** Katmanları ayırmak için `1px` katı çerçeve veya `Divider` yerine yüzey tonu basamakları, geniş köşe yarıçapları (`16px`–`28px`) ve çok düşük opaklıklı cam kenar ışığı (`rgba(255, 255, 255, 0.65)`) kullanılır.
3. **Gündüz vs. Gece Modu Ayrımı:**
   - **Gündüz (Aura Light):** Ana Sayfa, Meditasyon Portalı, Nefes Egzersizleri, Beden Egzersizleri, Profil.
   - **Gece / Kozmik Mod (Deep Sleep):** Uyku Portalı, Doğa Sesleri, Gürültüler, Uyku Hikayeleri ve Tam Ekran Hz Rezonans modu.

### 2.2 Renk Token'ları

#### Gündüz Paleti (Surface & Semantic)

| Token                                   | Değer                       | Kullanım                                 |
| :-------------------------------------- | :-------------------------- | :--------------------------------------- |
| `surface` / `background`                | `#FBF8FF`                   | Ana gündüz tuvali                        |
| `surface-dim`                           | `#D6D8F2`                   | Vurgulu pasif arka planlar               |
| `surface-container-lowest`              | `#FFFFFF`                   | En temiz kart / seçili öğe katmanı       |
| `surface-container-low`                 | `#F3F2FF`                   | Yumuşak liste / bölüm arka planı         |
| `surface-container`                     | `#ECECFF`                   | Standart konteyner                       |
| `surface-container-high`                | `#E4E7FF`                   | Aktif/vurgulu kart zemini                |
| `surface-container-highest`             | `#DEE1FB`                   | En yoğun gündüz yüzey tonu               |
| `on-surface` / `text-primary`           | `#161B2D` / `#1A1D2B`       | Ana başlık ve okuma metinleri            |
| `on-surface-variant` / `text-secondary` | `#48454F` / `#6A7188`       | İkincil açıklamalar ve etiketler         |
| `text-muted`                            | `#9BA3B7`                   | Yardımcı ipuçları ve pasif tarih/saatler |
| `primary`                               | `#60538D` _(öz: `#8A7CB9`)_ | Birincil etkileşimler, aktif navigasyon  |
| `primary-container`                     | `#796CA8`                   | Düğme dolgu ve geçişler                  |
| `primary-fixed`                         | `#E7DEFF`                   | Açık lavanta rozet/çip zemini            |
| `secondary`                             | `#4A6550` _(öz: `#88A58D`)_ | Nefes, doğa ve denge vurguları           |
| `secondary-container`                   | `#C9E7CD`                   | Dinginlik/tamamlanma rozetleri           |
| `tertiary`                              | `#8A4B2D` _(öz: `#F4A27E`)_ | Sıcak enerji ve şefkatli vurgular        |
| `tertiary-fixed`                        | `#FFDBCD`                   | Sıcak şeftali çip zemini                 |
| `error` / `error-container`             | `#BA1A1A` / `#FFDAD6`       | Hata ve uyarı durumları                  |

#### Aura, Cam ve Gece Token'ları

| Token                  | Değer                                     | Kullanım                    |
| :--------------------- | :---------------------------------------- | :-------------------------- |
| `aura-lavender`        | `#B8A9E3`                                 | Üst/orta ortam ışık küresi  |
| `aura-sage`            | `#A3C4AB`                                 | Denge ve nefes küresi       |
| `aura-peach`           | `#FFC0A0`                                 | Sıcaklık ve ruh hali küresi |
| `aura-sunset`          | `#F4937A`                                 | Enerji/gün batımı vurgusu   |
| `aura-mist`            | `#EBF0F5`                                 | Yumuşak sis geçişi          |
| `glass-surface`        | `rgba(255, 255, 255, 0.45)`               | Ana buzlu cam kart dolgu    |
| `glass-surface-subtle` | `rgba(255, 255, 255, 0.25)`               | İkincil cam yüzeyler        |
| `glass-border`         | `rgba(255, 255, 255, 0.65)`               | Cam üst-sol parlak kenar    |
| `glass-border-dark`    | `rgba(255, 255, 255, 0.20)`               | Gece modu cam kenar         |
| `night-deep`           | `#0E111C` _(ayrıca `#0B081B`, `#060814`)_ | Uyku & kozmik arka plan     |
| `night-card`           | `#181D2D`                                 | Gece modu cam kart temeli   |

### 2.3 Tipografi ve Ölçü Kuralları

- **Font Aileleri:**
  - Başlıklar & Rakamlar: `Plus Jakarta Sans`
  - Gövde & Arayüz: `Inter`
  - Uyku Hikayeleri Uzun Okuma Metni: `Cormorant Garamond`
- **Ölçekler:**
  - `display-hero`: `40px` / `700` (mobil: `32px`)
  - `headline-lg`: `26px` / `600` | `headline-md`: `20px` / `600` | `headline-sm`: `17px` / `600`
  - `body-lg`: `16px` / `400` | `body-md`: `14px` / `400` | `body-sm`: `12px` / `400`
  - `label-lg`: `14px` / `600` | `label-md`: `12px` / `600` | `label-sm`: `11px` / `500`
  - `numeric-timer`: `48px` / `300` (`FontFeature.tabularFigures()`)
- **Boşluk & Yarıçaplar:**
  - Yatay kenar boşluğu: `20px`, ızgara aralığı: `16px`.
  - Yüzen alt navigasyon tamponu: tüm kaydırılabilir sayfalarda en az `80px–104px` alt `SizedBox` / padding bırakılır.
  - Köşe yarıçapları: kartlar `16px–28px`, yüzen alt navigasyon `28px`, alt açılır sheet üst köşeleri `32px`, rozet/çip `9999px` (pill).

---

## 3. Navigasyon Mimarisi ve Evrensel Kurallar

### 3.1 Ana Kabuk (3 Sekme)

Alt kısımda yer alan yüzen cam navigasyon barı (`radius: 28px`) tam olarak **3 ana sekme** içerir (`sayfa_ak_s_tasar_mlar.md`):

1. **Ana Sayfa** (`home`) — Haftalık ritim takvimi, emoji bazlı duygu kaydı, hızlı not ve frekansa devam oynatıcısı
2. **Meditasyon** (`meditation`) — 4 ana kategorili meditasyon portalı
3. **Profil** (`profile`) — Kişisel bilgiler, alışkanlıklar, haftalık duygu eğri grafiği, hesap ayarları ve çıkış

> **Odak Modu Kuralı:** Meditasyon alt akışlarına (Nefes, Beden Poz Detayı, Hz Tam Ekran, Doğa/Gürültü/Hikaye oynatıcıları) girildiğinde tam ekran veya kompakt oynatıcı deneyimi korunur; alttaki yüzen 3'lü bar gizlenerek dikkat dağıtmayan bir alan açılır.

### 3.2 Evrensel Medya / Ses Oynatıcı Kontratı

`sayfa_ak_s_tasar_mlar.md` gereği uygulamadaki **tüm sesli ekranlar** ortak bir kalıcı arka plan ses servisi (`GlobalAudioController`) üzerinden çalışır:

- **Standart Kontroller:** `Başlat / Duraklat` (Play/Pause), `İleri / Geri Sar` (±10/15 sn veya önceki/sonraki parça), aktif süre / toplam süre (`04:18 / 17:00`) ve sürüklenebilir ilerleme çubuğu (seek bar), favori / uyku zamanlayıcısı / ses seviyesi / kapatma aksiyonu.
- **Kesintisiz Arka Plan Çalımı:** Kullanıcı bir doğa sesi, gürültü veya Hz frekansı başlattıktan sonra başka bir sekmeye veya sayfaya geçtiğinde ses çalmaya devam eder; Ana Sayfa'daki **"Frekansa devam et"** kartı veya kompakt kontrol barı ile yönetilebilir.

### 3.3 Kimlik Doğrulama (Firebase Auth)

- Uygulama açılışında veya Profil sekmesinde hesap yönetimi bulunur (`Email/Şifre`, `Google` vb. sağlayıcılar — `meditrans-2ff48`).
- Profil sayfasında kullanıcının güvenli **Çıkış Yap (Sign Out)** aksiyonu ve Firestore duygu/profil senkronizasyonu yer alır.

---

## 4. Ekran Spesifikasyonları (13 Stitch Tasarımı)

### Modül A: Ana Sayfa & Duygu Durumu

- **Stitch Klasörü:** `ana_sayfa_duygu_durumu`
- **Tasarım ve Akış:**
  - **Üst Bar & Karşılama:** Tarih bilgisi (`12 Ekim 2024, Cumartesi`), kişiselleştirilmiş selamlama (`Merhaba, Adil`), alt metin (`Bugün ruhunun nefes almasına izin ver.`) ve bildirim/profil ikonları.
  - **Haftalık Ritim Takvimi:** `P S Ç P C C P` (Pazartesi–Pazar) gün sırası, tarih numaraları, her günün altında ruh haline göre renkli nokta göstergesi; seçili/bugünkü gün birincil vurgu kapsülü (`#60538D`) içinde öne çıkar.
  - **Nasıl Hissediyorsun? Kartı (Emoji Odaklı, Maskotsuz):**
    - Başlık ve alt açıklama (`Şu anki içsel durumunu yansıt`).
    - Seçili duygular `×` ile kaldırılabilen cam çipler halinde gösterilir (ör. `🔥 Kızgın`, `🌧️ Üzgün`).
    - **`+ Duygu Ekle`** düğmesi alttan açılan modal bottom sheet'i (`Bugün Ne Hissediyorsun?`) tetikler. Modalda 6 **emoji + etiket** seçeneği (`☀️ Mutlu`, `🌿 Dingin`, `🕊️ Huzurlu`, `🌪️ Kaygılı`, `🌙 Yorgun`, `🔥 Kızgın`), isteğe bağlı kısa yansıma notu (`Bugün zihnimi meşgul eden...`) ve `Duygu Durumunu Kaydet` düğmesi bulunur.
    - Kartın alt kısmında doğrudan hızlı yazım için `+ Eklemek istediklerim...` not girişi yer alır.
  - **Frekansa Devam Et Kartı:** Son/önerilen seans (`Zihinsel Dinginlik & Teslimiyet` — `432 Hz Solfeggio`) için satır içi oynatıcı önizlemesi sunar.

### Modül B: Meditasyon Portalı

- **Stitch Klasörü:** `meditasyon_portali_4_kategori`
- **İçerik:** Aralarında nefes alan boşluklara sahip 4 büyük Aura Camı kategori kartı:
  1. **Nefes Egzersizleri**
  2. **Beden Egzersizleri**
  3. **Hz Frekansları**
  4. **Uyku**

### Modül C: Nefes Egzersizleri

- **Stitch Klasörü:** `nefes_egzersizleri_kompakt_oynat_c`
- **Tasarım ve Akış:**
  - Merkezde genişleyen/daralan ışıltılı nefes küresi (Aura Breathing Orb).
  - Tasarımdaki birincil ritim **`4-1-4` döngüsü**dür: `Nefes Al (4 sn)` → `Nefesini Tut (1 sn)` → `Yavaşça Ver (4 sn)`.
  - Veri modeli ritmi parametrik (`inhaleSeconds`, `holdSeconds`, `exhaleSeconds`) tutar; böylece depodaki `4-7-8_Nefes_Egzersizi.mp3` ses rehberi de isteğe bağlı `4-7-8` seçeneğiyle doğrudan desteklenir.
  - Altta kompakt evrensel oynatıcı barı (`Play/Pause`, `±10sn`, süre ve döngü sayacı) yer alır.

### Modül D: Beden Egzersizleri (Yoga Portalı & Tekil Poz Sayacı)

- **Stitch Klasörleri:** `beden_egzersizleri_yoga_portal`, `sasangasana_egzersiz_ve_saya_detay`
- **Portal Görünümü:**
  - Çerçevesiz, kenarlıksız (borderless) yüksek görselli resim kartları halinde **8 poz** listelenir (`BEDEN-EGZERSIZI-POZISYON1.png` .. `8.png`):
    1. `01 Virasana` — Kahraman Oturuşu
    2. `02 Padmasana` — Lotus Duruşu
    3. `03 Sukhasana` — Huzur Bağdaşı
    4. `04 Sasangasana` — Tavşan & Esneme Pozu
    5. `05 Vrikshasana` — Ağaç Dengesi
    6. `06 Phalakasana` — Plank & Güç
    7. `07 Paschimottanasana` — Oturarak Öne Katlanma
    8. `08 Savasana` — Derin Gevşeme & Bitiş
- **Tekil Poz & Sayaç Ekranı (`sasangasana_egzersiz_ve_saya_detay`):**
  - Liste kartına dokunulduğunda poz görseli `Hero` animasyonu ile büyür.
  - Sağa/sola kaydırma (`PageView`) veya `Önceki / Sonraki` oklarıyla pozlar arası geçiş yapılır.
  - **Ayarlanabilir 1 Dakikalık Geri Sayım Sayacı:** Varsayılan `60 sn` dairesel zamanlayıcı; hızlı süre seçicileri (`10 sn`, `20 sn`, `30 sn`, `60 sn`, `90 sn`), `+5 sn` ekleme düğmesi, bitiş zil sesi aç-kapa anahtarı ve süre dolduğunda **Sonraki Poza Geç** akışı.
  - Pozun altında 3 adımlı kısa uygulama rehberi yer alır.

### Modül E: Hz Frekansları & Tam Ekran Rezonans

- **Stitch Klasörleri:** `hz_frekanslar_ve_meditasyon_tonlar`, `hz_frekans_oynat_c`, `hz_frekans_oynat_c_tam_ekran_rezonans`
- **Liste Ekranı (`hz_frekanslar_ve_meditasyon_tonlar`):**
  - `HZ'LER-ANA-SAYFA.png` ve `HZLER-TARZ-VE-RENKLER.jpg` kararlarına uygun olarak, **her Hz kartının kendi arka plan görselinin/dokusunun bir kısmı köşeleri yuvarlak kart içinde önizleme olarak görünür**.
  - Desteklenen setler:
    - **Solfeggio & Rezonans:** `7.83 Hz` (Schumann Rezonansı), `174 Hz`, `285 Hz`, `396 Hz` (Kök Çakra), `432 Hz` (Evrensel Uyum), `528 Hz` (Mucize Frekansı), `639 Hz` (Kalp Çakrası), `741 Hz` (Boğaz Çakrası), `852 Hz` (Üçüncü Göz), `963 Hz` (Tepe Çakra), `44 Hz`.
    - **Melek Sayıları (3x3 Izgara Stili):** `111` (Sezgi), `222` (Uyum), `333` (Destek), `444` (Koruma), `555` (Değişim), `666` (Yansıma), `777` (Şans), `888` (Denge), `999` (Arınma/Bırakma).
- **Tekil Oynatıcı & Tam Ekran Rezonans:**
  - Liste kartına dokunulduğunda o Hz'nin kendine özgü hareketli/katmanlı arka planı tüm ekrana yayılır ve ilgili frekans çalmaya başlar.
  - `PageView` ile **sağa/sola kaydırılabilir**: kullanıcı kaydırdıkça yeni Hz'nin arka plan teması, metinleri ve frekans sesi senkronize değişir.

### Modül F: Uyku Portalı & Alt Oynatıcılar

- **Stitch Klasörleri:** `uyku_portal_kategoriler`, `do_a_sesleri_ses_oynat_c`, `g_r_lt_mikseri_beyaz_kahverengi_g_r_lt`, `uyku_hikayeleri_sabit_kompakt_oynat_c`
- **Uyku Portalı (`uyku_portal_kategoriler`):**
  - Kozmik gece teması (`#0E111C` / `#0B081B`).
  - `Hikaye`, `Doğa Sesleri`, `Beyaz Gürültü`, `Kahverengi Gürültü` kategorilerine doğrudan erişim sunar (Gürültüler kartından tek dokunuşla Beyaz/Kahverengi ton seçimi yapılabilir).
- **Doğa Sesleri (`do_a_sesleri_ses_oynat_c`):**
  - **Gece Yağmuru** ve **Derin Okyanus** arasında hızlı anahtar (segmented toggle). Seçim değiştiğinde arka plan görseli (`DOGA-SESLERI-YAGMUR-BACKGROUND.jpg` ↔ `DOGA-SESLERI-DEEP-OCEAN-SAYFA-BACKGROUND.jpg`) ve ses kaynağı anında değişir.
- **Gürültüler (`g_r_lt_mikseri_beyaz_kahverengi_g_r_lt`):**
  - **Beyaz Gürültü** ve **Kahverengi Gürültü** arasında tek kanallı geçiş; arka plan (`BEYAZ-GURULTU-SAYFA-BACKGROUND.jpg` ↔ `KAHVERENGI-GURULTU-SAYFA-BACKGROUND.jpg`) ve ses anında güncellenir.
- **Uyku Hikayeleri (`uyku_hikayeleri_sabit_kompakt_oynat_c`):**
  - Hikaye başlığı medya oynatıcının üstünde, kaydırılabilir hikaye metni (`Cormorant Garamond`) ise oynatıcıyla çakışmadan altında/sabit kompakt oynatıcının yukarısında akıcı okuma deneyimiyle sunulur.
  - Mevcut Hikayeler:
    - **Hikaye 1:** _Ay Işığında Gizli Orman ve Sakin Göl_ (`HIKAYE-1.txt` + `HIKAYE_1.mp3`)
    - **Hikaye 2:** _Yıldızların Altında Gizli Dağ Kulübesi_ (`HIKAYE-2.txt` + `HIKAYE_2.mp3`)

### Modül G: Profil & Duygu Analizi

- **Stitch Klasörü:** `profil_ve_duygu_analizi`
- Kullanıcı kimlik & vital kartı (`Mindful Gezgin`, **Yaş**, **Kilo**), **Alışkanlıklar & Rutinler** rozetleri (`Günlük 15 dk meditasyon`, `Gece doğa sesleri ile uyku`, `4-1-4 nefes rutini`), hesap ayarları ve **Çıkış Yap**.
- **Haftalık Analiz — Duygu Grafiği:** Aura degrade dolgulu yumuşak spline eğrisi ve altında `P - S - Ç - P - C - C - P` günleri için emoji + puan (`4.8`..`9.4` / `Bugün`) özetleri.

---

## 5. Varlık (Asset) Envanteri, Boyut Optimizasyonu ve Eksikler

### 5.1 Mevcut Tasarım & Ses Varlıkları (`mediTrack-tasarım-ve-assetler/` → `assets/` taşınacak)

- **Arka Plan Görselleri (`SAYFALAR-ARKA-PLAN/`):**
  - `ANA-SAYFA/ANA-SAYFA-BACKGROUND.jpg`
  - `MEDITASYON/MEDITASYON-SAYFASI-BACKGROUND.jpg`
  - `MEDITASYON/NEFES-EGZERSIZI/NEFES-EGZERSIZI-SAYFA-BACKGROUND.jpg`
  - `MEDITASYON/BEDEN-EGZERSIZLERI/`: `BEDEN-EGZERSIZLERI-SAYFA-BACKGROUND-ANA.jpg`, `BEDEN-EGZERSIZLERI-SAYFA-BACKGROUND.jpg`, `BEDEN-EGZERSIZI-POZISYON1.png` .. `POZISYON8.png`
  - `MEDITASYON/UYKU/UYKU-SAYFA-BACKGROUND.jpg`
  - `MEDITASYON/UYKU/DOGA-SESLERI/`: `DOGA-SESLERI-DEEP-OCEAN-SAYFA-BACKGROUND.jpg`, `DOGA-SESLERI-YAGMUR-BACKGROUND.jpg`
  - `MEDITASYON/UYKU/GURULTU/`: `BEYAZ-GURULTU-SAYFA-BACKGROUND.jpg`, `KAHVERENGI-GURULTU-SAYFA-BACKGROUND.jpg`
  - `MEDITASYON/UYKU/HIKAYELER/`: `HIKAYE-1-AY-ISIGI-BACKGROUND.jpg`, `HIKAYE-2-YILDIZIN-ALTINDAKI-KULUBE-BACKGROUND.jpg`
  - `PROFIL/PROFIL-SAYFA-BACKGROUND.jpg`
- **Hz Video Arka Planları (`SAYFALAR-ARKA-PLAN/MEDITASYON/HZ/`):**
  - `396-HZ-KOK-CAKRA-BACKGROUND.mp4`, `432-HZ-EVRENSEL-UYUM-BACKGROUND.mp4`, `528-HZ-MUCIZE-FREKANSI-BACKGROUND.mp4`, `639-HZ-KALP-CAKRASI-BACKGROUND.mp4`, `7.83-HZ-SCHUMANN-REZONANSI-BACKGROUND.mp4`, `741-HZ-BOGAZ-CAKRASI-BACKGROUND.mp4`, `852-HZ-UCUNCU-GOZ-BACKGROUND.mp4`, `963-HZ-TEPE-CAKRA-BACKGROUND.mp4`, `999-STIL-ARINMA-RELEASE-BACKGROUND.mp4`
- **Sesler ve Hikaye Metinleri (`UYGULAMA-ICI-SESLER/`):**
  - Doğa Sesleri: `DOGA-SESLERI/5_dakika_sakin_yağmur_sesi.mp3`, `DOGA-SESLERI/deep-ocean-shortened.m4a`
  - Gürültüler: `GURULTU-SESLERI/Beyaz_Gürültü.mp3`, `GURULTU-SESLERI/kahverengi-gurultu-ses.m4a`
  - Hikayeler: `HIKAYELER/HIKAYE_1.mp3`, `HIKAYE_2.mp3` ve `HIKAYELERIN-METNI/HIKAYE-1.txt`, `HIKAYE-2.txt`
  - Nefes: `NEFES-EGZERSIZLERI/4-7-8_Nefes_Egzersizi.mp3`

### 5.2 Uygulama Boyutu ve Dosya Adı Kuralları (`MB-HESAPLAMA-UYGULAMA.txt`)

1. **Ham Video Paketleme Yasağı:** `MB-HESAPLAMA-UYGULAMA.txt` uyarısına göre ham `.mp4` dosyalarını (ör. 120+ MB) doğrudan uygulama paketine gömmek APK/IPA boyutunu aşırı büyütür ve belleği zorlar.
2. **Önerilen Hibrit Strateji:**
   - Sesleri (`mp3` / `m4a`, ~2 MB) görselden ayrı yükle.
   - Hz arka planları için öncelikle **statik yüksek kaliteli WebP/JPG + Flutter GPU animasyonu (CustomPainter / yavaş zoom-pan & aura parıltısı)** kullan; video gerekiyorsa 1 MB altı optimize döngü (loop) dosyalarını **Supabase Storage Free** (`meditation-visuals`) üzerinden önbellekli akışla sun.
3. **ASCII `snake_case` Normalizasyonu:** `assets/` altına alınacak tüm dosya adlarındaki Türkçe karakterler ve boşluklar kaldırılmalıdır (ör. `5_dakika_sakin_yağmur_sesi.mp3` → `assets/audio/nature/sakin_yagmur_5dk.mp3`, `Beyaz_Gürültü.mp3` → `assets/audio/noise/beyaz_gurultu.mp3`).

### 5.3 Tespit Edilen Eksikler (Gap Listesi)

- **Hz Frekans Sesleri:** `UYGULAMA-ICI-SESLER/` içinde henüz Hz/Melek sayısı `.mp3`/`.m4a` dosyaları yok (Supabase Storage `meditation-audio/frequencies/` veya sentezlenmiş döngü ton ile bağlanmalı).
- **4-1-4 Nefes Ses Rehberi:** Tasarımda `4-1-4`, mevcut ses klasöründe `4-7-8_Nefes_Egzersizi.mp3` (`1.37 MB`) var; hem görsel zamanlayıcıya bağlı hafif nefes ipucu hem de `4-7-8` seçeneği desteklenmeli.
- **Beden Egzersizi Bitiş Zili:** Geri sayım bittiğinde çalacak kısa çan (`chime.mp3` / `.wav`) asset'i eklenecek.
- **Paket Bağımlılıkları (Henüz Eklenmedi — Önce Mimari Onaylı):** `pubspec.yaml` içine aşamalı olarak Firebase Spark paketleri (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging` — _ücretli Blaze gerektiren `firebase_storage` ve Cloud Functions hariç_), Supabase (`supabase_flutter`), Yerel DB (`drift`, `drift_flutter`, opsiyonel `hive_ce_flutter`), Bildirim (`flutter_local_notifications`, `timezone`) ve ses oynatıcı paketleri eklenecek.
- **macOS Entitlements Eksiği:** `macos/Runner/DebugProfile.entitlements` ve `macos/Runner/Release.entitlements` dosyalarında şu an giden ağ izni (`com.apple.security.network.client`) bulunmamaktadır; bulut servisleri için zorunludur.

---

## 6. Hedef Flutter Klasör Mimarisi (Feature-First & Platform-Safe)

Tüm veri modelleri ve şema sözleşmeleri [data_referance.md](data_referance.md) dosyasında tanımlanmıştır.

```text
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── theme/          # Ethereal Aura Mind renkler, tipografi, glass/orb yardımcıları
│   ├── audio/          # GlobalAudioController, evrensel mini & tam oynatıcı widget'ları
│   ├── navigation/     # 3 sekmeli AuraShell + rota isimleri (GoRouter)
│   ├── data/
│   │   ├── local/      # Drift veritabanı, DAO'lar, Outbox ve opsiyonel hive_ce tercihleri
│   │   └── remote/     # Firestore sync servisi + SupabaseStorageGateway (ücretsiz medya akışı)
│   ├── platform/       # Koşullu importlar: media_cache_(io|web).dart, notification_(io|web).dart
│   ├── services/       # Auth, Reminder/Push orchestrator, LRU cache yöneticisi
│   └── widgets/        # AuraBackground, GlassCard, CountdownRing, EmojiMoodChip
└── features/
    ├── home_mood/      # Haftalık ritim takvimi, emoji duygu çipleri, modal, not & devam kartı
    ├── meditation/     # 4 kategorili meditasyon portalı
    ├── breathwork/     # 4-1-4 / 4-7-8 nefes küresi ve kompakt oynatıcı
    ├── body_exercises/ # 8 poz listesi, Hero detay, ayarlanabilir sayaç
    ├── frequencies/    # Hz & Melek sayıları listesi, kaydırılabilir Tam Ekran Rezonans
    ├── sleep/          # Uyku portalı, Doğa Sesleri, Gürültü, Hikayeler (okuma + oynatıcı)
    └── profile/        # Yaş/Kilo/Alışkanlıklar, haftalık spline duygu grafiği, Çıkış Yap
```

---

## 7. Geliştirme Fazları

1. **Faz 1 — Çekirdek Tema, Platform Hazırlığı ve 3-Sekme Kabuk:**
   - `Ethereal Aura Mind` Light & Night tema sınıflarının yazılması, macOS entitlements (`network.client`) + Web (`Chrome`/`web-server`) temel ayarlarının yapılması ve yüzen 3 sekmeli cam navigasyon kabuğunun kurulması.
2. **Faz 2 — Yerel Veritabanı (`Drift`), Evrensel Ses Motoru & Ana Sayfa:**
   - [data_referance.md](data_referance.md) şemalarına göre çevrimdışı-öncelikli yerel kayıt (`mood_logs`, `sync_outbox`), `GlobalAudioController`, Ana Sayfa haftalık ritim takvimi, emoji çipleri, `Bugün Ne Hissediyorsun?` modalı ve `Frekansa devam et` kartının bağlanması.
3. **Faz 3 — Meditasyon Portalı, Nefes & Beden Egzersizleri:**
   - 4 kartlı Meditasyon Portalı, `4-1-4` (+ `4-7-8`) Nefes Küresi ekranı, 8 pozlu Yoga/Beden akışı (`Hero` geçişi, 1 dk varsayılan ayarlanabilir geri sayım, zil ve sonraki poz akışı).
4. **Faz 4 — Ücretsiz Bulut Medya (`Supabase Storage`), Cache & Hz Rezonans:**
   - ~49.17 MB'lık ses kataloğunun Supabase Storage (`meditation-audio`, ücretsiz 1 GB kota) üzerine taşınması, macOS/mobil disk cache (`cached_media` ile tek indirme) + Web stream çözümleyicisinin kurulması ve kaydırılabilir Tam Ekran Rezonans.
5. **Faz 5 — Uyku Modülü, Profil Analizi & Çift Kanal Bildirim Sistemi:**
   - Doğa Sesleri, Gürültü, Uyku Hikayeleri okuma deneyimi; Profil analizi + Firebase Auth giriş/çıkış; `flutter_local_notifications` + `firebase_messaging` (ücretsiz FCM) bildirim yönlendiricisinin devreye alınması.

---

## 8. Çok Platformlu Depolama, Bildirim ve Hedef Platform Mimarisi

> Bu bölüm, paketler `pubspec.yaml` içine eklenmeden önce sistem sınırlarını, **%100 ücretsiz plan (kredi kartsız Spark + Supabase Free)** uyumunu ve macOS + Windows Web (`Chrome` / `web-server`) uyumluluğunu garanti altına almak için hazırlanmıştır. Tüm tablo/JSON şemaları için bkz. [data_referance.md](data_referance.md).

### 8.1 Ücretsiz Bulut Kotası Sınırları (`Firebase Spark` + `Supabase Free`)

| Hizmet                                           | Kullanılacak / Hariç | Ücretsiz Plan Sınırı                                               | Mimari Not                                                              |
| :----------------------------------------------- | :------------------: | :----------------------------------------------------------------- | :---------------------------------------------------------------------- |
| **Firebase Auth** _(Email/Şifre, Google, Apple)_ |      **Dahil**       | 50.000 MAU                                                         | Telefon/SMS doğrulaması Blaze istediği için kullanılmaz                 |
| **Cloud Firestore**                              |      **Dahil**       | 1 GiB veri, 50K okuma/gün, 20K yazma/gün, 10 GiB/ay                | İlk okuma her zaman yerel `Drift`'ten yapılır; kota korunur             |
| **Firebase Cloud Messaging (FCM)**               |      **Dahil**       | Sınırsız mesaj hacmi (ücretsiz)                                    | Push bildirimleri ücretsizdir                                           |
| **Cloud Storage for Firebase**                   |      **HARİÇ**       | Ücretsiz Spark planında kullanılamaz _(Blaze zorunlu)_             | `firebase_storage` projeye eklenmez; yerine Supabase Storage kullanılır |
| **Supabase Storage**                             |      **Dahil**       | **1 GB depolama**, **10 GB/ay bant** (5 GB uncached + 5 GB cached) | Tek uzak ses/görsel deposudur; native disk cache ile egress korunur     |

### 8.2 Yerel Depolama Kararı: `Drift` vs. `Hive` vs. `Isar`

| Kriter                                    | **Drift** (`drift` + `drift_flutter`)                               | **Hive** (`hive_ce` / `hive_ce_flutter`)                        | **Isar**                                                                                |
| :---------------------------------------- | :------------------------------------------------------------------ | :-------------------------------------------------------------- | :-------------------------------------------------------------------------------------- |
| **macOS Desteği**                         | Mükemmel — Sandbox içindeki App Support klasöründe native `sqlite3` | Mükemmel — Saf Dart binary box dosyaları                        | Sorunlu — `libisar.dylib` imzalama/sandbox ve güncel Dart `^3.13.5` codegen kırılmaları |
| **Windows Web (`Chrome` / `web-server`)** | İyi — `sqlite3.wasm` + `drift_worker.js` ile OPFS / IndexedDB       | Mükemmel — Sıfır ek WASM dosyasıyla doğrudan `IndexedDB`        | Kısıtlı/Eski — Web WASM/IndexedDB tarafı kararsız ve bakım dışı riskler içerir          |
| **İlişkisel / Tarih Sorguları**           | Güçlü (haftalık aralık, `sync_outbox` FIFO, önbellek boyutu `SUM`)  | Zayıf (tüm box'ı belleğe okuyup filtrelemek gerekir)            | Güçlü ama çoklu platform sürekliliği zayıf                                              |
| **Mimari Karar**                          | **Birincil Yerel DB (Önerilen)**                                    | **Opsiyonel Hafif Tercih Kutusu** _(veya `shared_preferences`)_ | **Kullanılmayacak**                                                                     |

- **Önerilen Hibrit Yapı:** Yapılandırılmış tüm veriler (`user_profiles`, `mood_logs`, `habit_routines`, `media_catalog`, `cached_media`, `reminder_schedules`, `sync_outbox`) **`Drift`** içinde tutulur. Son çalınan ses ID'si, ses pozisyonu (`ms`), seçili uyku sayacı gibi basit anahtar-değerler için **`hive_ce`** (veya `shared_preferences`) kullanılır.

### 8.3 Tek Ücretsiz Medya Bulutu: `Supabase Storage` + Yerel Disk Önbelleği

Mevcut ses dosyalarının toplamı şimdiden **~49.17 MB** tutmaktadır (`5_dakika_sakin_yağmur_sesi.mp3` `6.87 MB`, `deep-ocean-shortened.m4a` `14.44 MB`, `Beyaz_Gürültü.mp3` `2.75 MB`, `kahverengi-gurultu-ses.m4a` `14.25 MB`, `HIKAYE_1.mp3` `5.47 MB`, `HIKAYE_2.mp3` `4.02 MB`, `4-7-8_Nefes_Egzersizi.mp3` `1.37 MB`). `firebase_storage` Blaze gerektirdiğinden tüm uzak medya **Supabase Storage** üzerinde tek bir **`MediaStorageGateway`** arayüzüyle yönetilir:

```text
UI / GlobalAudioController
         │
         ▼
MediaResolverService
   ├── 1. Paket İçi Acil/Küçük Varlıklar (`bundledAsset`)
   │      └── Yoga poz PNG'leri, arayüz ikonları, kısa zil sesi
   ├── 2. Native Disk Cache Kontrolü (macOS/iOS/Android -> Drift cached_media)
   │      └── Varsa doğrudan yerelden (`file://`) çalar -> Supabase egress harcamaz
   └── 3. Uzak Medya Deposu: Supabase Storage (`meditation-audio` / `meditation-visuals`)
          └── Native'de arka planda diske önbellekler; Web'de HTTP Range ile stream eder
```

- **Bant Genişliği & Güvenlik Kuralları:**
  - **5 GB Uncached + 5 GB Cached / ay** Supabase sınırını korumak için indirilen ses dosyaları `cached_media` altında LRU politikasıyla (ör. 300 MB tavan) cihazda saklanır; tekrar çalmalarda sunucudan yeniden indirilmez.
  - İstemcide yalnızca `SUPABASE_URL` ve `publishable` (`anon`) anahtar tutulur; RLS'de `auth.role()` yerine `TO authenticated` / `TO anon` kullanılır ve son kullanıcıya yükleme/değiştirme açılmaz (katalog salt okunur CDN).
  - **Sıfır `dart:io` Sızıntısı Kuralı:** Yerel ses önbelleği koşullu import (`if (dart.library.io) 'media_cache_io.dart' else 'media_cache_web.dart'`) ile ayrılır.

### 8.4 Çift Bildirim Mimarisi: `firebase_messaging` + `flutter_local_notifications`

| Katman / Paket                            | Görev                                                                                                                  | Ön Plan (Uygulama Açık)                                                         | Arka Plan / Kapalı                                                                |
| :---------------------------------------- | :--------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------ | :-------------------------------------------------------------------------------- |
| **`firebase_messaging` (FCM — Ücretsiz)** | Sunucudan gelen push mesajları (yeni hikaye, motivasyon, seri hatırlatması)                                            | `onMessage` stream ile yakalar → `NotificationGateway` yerel banner/toast basar | OS bildirim merkezinde doğrudan gösterir; tıklanınca `deep_link_route` açar       |
| **`flutter_local_notifications`**         | Kullanıcının cihazda kurduğu tekrarlayan saatli hatırlatıcılar (_"Her gün 21:30 Uyku Zamanı"_) + ön plan FCM gösterimi | Doğrudan `show()` ile sistem bildirimi gösterir                                 | `zonedSchedule` + cihaz yerel saat dilimi (`timezone`) ile internetsiz tetiklenir |

- **`NotificationGateway` Platform Davranışı:**
  - **macOS (`MACOSX_DEPLOYMENT_TARGET = 12.0`):** `DarwinInitializationSettings` ile `UNUserNotificationCenter` izni ister. Yerel zamanlanmış bildirimler çalışır; FCM için Apple Developer hesabında Push Notifications + APNs Key (`aps-environment`) yapılandırması gerekir.
  - **Web — Windows `Chrome` / `web-server`:** `flutter_local_notifications` Web platformunu desteklemez! Web hedefinde `NotificationGateway`:
    1. Uzak push için `firebase_messaging` + `web/firebase-messaging-sw.js` + VAPID anahtarı kullanır (`localhost` veya HTTPS gerektirir).
    2. Zamanlanmış hatırlatıcı/ön plan uyarısı için tarayıcı `Notification` API (sekme açıksa) + uygulama içi Aura banner (`SnackBar`/toast) olarak çalışır; hatırlatıcı tercihi yine `Drift` + `Firestore`'a kaydedilip diğer cihazlara (macOS/mobil) senkronize olur.
  - **Native Windows (eğer desktop build alınırsa):** `firebase_messaging` native Windows'ta desteklenmediğinden başlatma kodunda `if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows)` koruması uygulanır.

### 8.5 Hedef Platform Hazırlık Listesi (macOS + Windows Web)

1. **macOS Özel Gereksinimleri:**
   - [DebugProfile.entitlements](macos/Runner/DebugProfile.entitlements) ve [Release.entitlements](macos/Runner/Release.entitlements) dosyalarına `<key>com.apple.security.network.client</key><true/>` eklenmeli (şu an eksik; eklenmeden Firebase/Supabase ağ istekleri sandbox tarafından engellenir).
   - Uzak FCM push için Xcode Signing & Capabilities -> `Push Notifications` ve `Background Modes (Remote notifications)` eklenmeli.
   - `AppInfo.xcconfig` içindeki `com.example.meditrans` kimliği mağaza/APNs öncesi gerçek bundle ID ile güncellenmeli.
2. **Windows Geliştirme Ortamı (`flutter run -d chrome` veya `web-server`):**
   - **CORS Yapılandırması:** Supabase Storage kovalarında `http://localhost:*` ve canlı alan adı için `GET`, `HEAD`, `Range` CORS başlıkları açılmalı; aksi hâlde ses oynatıcı ve Web `Audio` hata verir.
   - **Web Worker & WASM:** `Drift` Web kullanımı için `web/sqlite3.wasm` ve `web/drift_worker.js` dosyaları eklenir (standart `web-server` başlıklarında OPFS mevcut değilse otomatik IndexedDB moduna düşer). Uzak Web Push için `web/firebase-messaging-sw.js` eklenir.
   - **Cam (Blur) Performans Kuralı:** `BackdropFilter` Web'de yüksek maliyetli olduğu için yalnızca odak kartlarında/alt navigasyonda/modalda gerçek blur kullanılır; çok elemanlı listelerde yarı saydam pastel gradient yüzeyi tercih edilir.

### 9 Yapılanları Kaydetme

Yapılan işlerin özetini anlatan hangi dosya ne değiştirildi sonuç ne oldu kaydedilsin. Eğer dosya var ise üzerine eklesin, yok ise oluştursun. Dosya isimleri Tarih_Yapılanlar.md olsun
