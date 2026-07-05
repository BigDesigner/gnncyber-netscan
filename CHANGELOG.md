# Changelog

## v2.10.2
**Setup Installer UI and Dependency Checks Update**
- **VCRedist Installation:** Windows yükleyici (setup) programı artık kullanıcı makinesinde Visual C++ Redistributable (x64) kurulu olup olmadığını denetler. Eksikse otomatik kurar.
- **Installer UX/UI Update:** `setup.iss` üzerinden sessiz (silent) indirilen ve kurulan (WebView2, VCRedist) yardımcı araçların, internet hızına bağlı olarak indirme sürecinde ekranı dondurmuş gibi göstermesi sorunu giderildi. Kurulum sırasında ilerleme çubukları ve açıklayıcı mesaj pencereleri görünür kılındı.
## v2.10.1
**PDF/CSV Export Hostname Fix**
- **Export Fix:** PDF ve CSV rapor çıktılarında yeni eklenen `hostname` değerlerinin doğru şekilde yansıtılmama sorunu (yerine işletim sistemi etiketinin yazılması) düzeltildi. `hostname` mevcutsa o, yoksa fallback etiketi kullanılacak şekilde ihracat logiği güncellendi.
## v2.10.0
**Discovery Enhancement: Hostname Resolution & Local MAC**
- **Hostname Resolution:** Tarama sırasında bulunan her aktif IP için DNS/mDNS reverse lookup yapılarak cihazların gerçek isimleri (ör. `iPad.local`, `MSI-4060.home`) çözümlenir ve hem host listesinde hem detay panelinde gösterilir.
- **Local MAC Discovery:** Taramayı yapan makinenin kendi MAC adresi artık `N/A` gösterilmez; `ipconfig /all` (Windows) / `ifconfig` (macOS) üzerinden fiziksel adres tespit edilir.
## v2.9.1
**UI tweaks and stealth order fix**
- **Stealth Options Reordered:** Tarama gizlilik (Stealth) modları T1-T5 (Sneaky -> Insane) sırasıyla, mantıksal sıralamaya uygun olarak listelenecek şekilde düzenlendi.

## v2.9.0
**Offline support, structural security updates, and styled telemetry fixes**

### Çevrimdışı (Offline / Air-gap) Desteği
- **Local Tailwind CSS & Icons:** Tailwind CSS CDN ve Material Symbols Outlined font dosyaları projeye lokal olarak bundle edildi. İnternet olmayan ortamlarda da arayüzün bozulmadan tam fonksiyonel çalışması sağlandı.
- **Yerel Web Sunucusu:** Local HTTP sunucusunun MIME tiplerine `.ttf` font desteği eklendi.

### Güvenlik & Arayüz Düzeltmeleri
- **XSS & ID Düzeltmesi (C2/C7):** Geçmiş kayıtlar listesindeki inline `onclick` handler'ları tamamen kaldırılıp DOM API ve event delegation yapısına geçilerek XSS riski sıfırlandı. Çakışmaları önlemek için history kaydına mikro-saniye bazlı benzersiz `id` eklendi.
- **Alert yerine Toast (C1):** Eski ve çirkin tarayıcı `alert()` pencereleri yerine Blue Team temasına uygun, modern ve şık animasyonlu bildirim (Toast) arayüzü eklendi.
- **Sahte Telemetri Temizliği (C5):** Arayüzdeki rastgele değer üreten sahte CPU/MEM barları kaldırıldı. Sabit `1.2 THz` yazısı `LOCAL ENGINE` olarak güncellendi. Sahte IP adresi (`127.0.0.1`) yerine işletim sisteminden çekilen gerçek yerel IP adresinin dinamik gösterimi sağlandı.
- **Platform Uyumlu ARP (A4):** macOS üzerinde ARP tablosunun çok daha hızlı sorgulanması amacıyla `arp -an` flag yapılandırması uygulandı.
- **Shorthand IP Range Desteği (A5):** `192.168.1.10-20` gibi son oktet kısaltmalı tarama aralıkları için çözümleme desteği getirildi.
- **Mükerrer Normalizasyon Temizliği (D1):** `scan_engine.dart` üzerindeki gereksiz OpenSSH normalizasyon tekrarları temizlendi.
- **M-04 ve M-05 Düzeltmeleri:** Asset sunumundaki hardcoded kontrol mekanizmaları dinamik dosya kontrolüyle esnetildi. PDF raporlarındaki renk tutarsızlıkları `blueGrey800` kurumsal renk teması altında eşitlendi.

### Altyapı & CI/CD
- **Gereksiz SQLite Temizliği (A2):** Geçmiş kaydı için kullanılmayan mükerrer SQLite geçmiş tablosu ve ilgili tüm fonksiyonlar silindi. Tek kaynak JSON-tabanlı `HistoryDb` olarak birleştirildi.
- **Gereksiz SQLite Kopyalaması (A1):** CVE veritabanının sürüm kontrolü için sürüm dosyası entegre edildi. Güncellemelerde veritabanının otomatik yenilenmesi sağlandı.
- **CI/CD Action Sürümleri (B1):** `build.yml` iş akışındaki geçersiz/eski major action sürümleri `@v4`/`@v2` gibi kararlı sürümlerle değiştirildi. Python kurulum adımı eklendi. Sürüm notları üretimi optimize edildi.
- Projeye MIT lisans belgesi eklenerek kurulum aracı buna göre yapılandırıldı.

## v2.8.0
**Full Codebase Security & Bug Audit — 18 Kritik/Yüksek Bug Düzeltildi**

### Güvenlik Düzeltmeleri (XSS / Injection)
- **JS Bridge Injection:** Dart'tan JS'e gönderilen tüm string değerler (onLog, onHostDiscovered, onPortDiscovered) ham string interpolasyonu yerine `jsonEncode()` ile güvence altına alındı. Banner grab gibi harici kaynaklı veriler artık JS kodunu bozamaz.
- **XSS — addLog():** Log terminalinde `innerHTML` ile yapılan enjeksiyona karşı DOM API (`createElement` + `textContent`) kullanımına geçildi.
- **XSS — updateHostsTreeView():** Host tree view'daki IP, vendor, label değerleri `htmlEscape()` yardımcısı ile temizleniyor.
- **XSS — updatePortsTable():** Port tablosundaki servis, versiyon, state değerleri `htmlEscape()` ile korunuyor.
- Projeye global `htmlEscape()` yardımcı fonksiyonu eklendi.

### Bug Düzeltmeleri
- **Abort Durumu (M-03):** İptal edilen taramalar ABORTED yerine hep COMPLETED olarak kaydediliyordu. `_scanWasAborted` flag mekaniğmasıyla düzeltildi.
- **Dispose (M-06):** Uygulama penceresi kapatılırken aktif tarama motor durduruluyor ve HTTP sunucusu zorla (`force: true`) kapatılıyor.
- **Ping Timeout (SE-01):** `_pingHost()` hardcoded 500ms yerine artık kullanıcının ayarladığı `timeout` değerini kullanıyor.
- **CIDR < /24 Hatası (SE-03):** `/24` den küçük CIDR girişleri artık sessizce başarısız olmuyor; kullanıcıya anlaşılır hata mesajı gösteriliyor.
- **IP Range Aşımı (SE-04):** 256'dan fazla host içeren aralıklar artık uyarı mesajıyla bildiriliyor.
- **HttpClient Sızıntısı (SE-09):** `_getMacVendor()` fonksiyonunda `HttpClient` her çağrıda yaratılıp kapatılmıyordu. `finally` bloğunda `client.close()` çağrısı eklendi.

### Mimari Temizlik
- **Ölü Kod (D-03/D-04):** Geçmiş kaydı SQLite'a yazdıktan sonra hiç okumayan duplicate SQLite write kaldırıldı. Tek kaynak JSON-tabanlı `HistoryDb`.
- **Kullanılmayan Bağımlılık (P-01):** `csv: ^8.0.0` bağımlılığı hiç kullanılmıyordu, kaldırıldı.

### Versiyon / Telif Hakkı
- **Runner.rc Fallback (R-01/R-02):** `#define VERSION_AS_NUMBER` ve `VERSION_AS_STRING` macros `2.6.13`'te kalmıştı, `2.8.0`'a güncellendi.
- **LegalCopyright (R-03):** `com.example` placeholderı gerçek firma adıyla değiştirildi: `BigDesigner`.

## v2.7.5
- **PDF Optimizasyonu:** PDF dışa aktarma (export) aracındaki tabloların tasarımı (sütun genişlikleri, font boyutları ve dolgular) iyileştirildi. Detaylı tarama raporları artık daha geniş alan sağlaması için A4 Yatay (Landscape) formatında çıkarılıyor; böylece yazılarda satır kaymaları veya daralmalar yaşanmıyor.

## v2.7.4
- **Arayüz Versiyon Senkronizasyonu:** Arayüzde (UI) unutulmuş olan sabit (hardcoded) versiyon numarası temizlenip güncel sürümle senkronize edildi. Versiyon yönetiminin eksiksiz otonom devam etmesi güvence altına alındı.

## v2.7.3
- **Arayüz Düzenlemesi:** Ana ekrandaki tarama modüllerinin sıralaması mantıksal (MOD_00 - MOD_04) olarak düzeltildi.
- **Kurulum (Installer) İyileştirmesi:** Yükleme işlemi sırasında arka planda indirilen WebView2 bileşeninden dolayı kurulum sihirbazının donmuş gibi bekleme yapması sorunu giderildi; işlem tamamen şeffaf hale getirildi.

## v2.7.2
- **Profesyonel PDF Raporlama:** PDF oluşturma motoru tamamen yenilendi. Global tarama geçmişi ve tekil tarama detayları, artık profesyonel kurumsal formatta (tablolar, renkli başlıklar ve detaylı cihaz analiziyle) PDF'e aktarılabiliyor.
- **Zafiyet Eşleştirme (CVE) İyileştirmesi:** Çevrimdışı veritabanı aramalarında kısmi eşleşme (LIKE) desteği eklenerek servis/versiyon tespit yeteneği artırıldı.
- **OS Fingerprint (Arayüz Fix):** Arka planda tespit edilen işletim sistemi bilgilerinin (Windows, Linux, Router vb.) UI üzerindeki ikonlara yansımamasına sebep olan Bridge (Köprü) kütüphanesi hatası giderildi.

## v2.7.1
- **Kurulum Ekranı İyileştirmesi:** Yükleyici (installer) ekranındaki uzun bilgilendirme metni, daha hızlı ve kolay okunabilmesi için 5 maddelik sade bir özete dönüştürüldü.

## v2.7.0
- **Stealth / Rate Limiting (Evasion):** IDS/IPS ve Firewall atlatma amacıyla T1 (Sneaky) ile T5 (Insane) arası tarama hızı/gecikme seçenekleri eklendi. Bağlantı denemeleri port sırasında değil rastgele (shuffle) yapılarak güvenlik duvarlarının tespiti zorlaştırıldı.
- **Offline CVE Veritabanı:** Dahili bir SQLite veritabanı (cve_db.sqlite) ile keşfedilen servislerin versiyon numaraları bilinen güvenlik açıkları (CVE) ile eşleştirilip arayüzde (CRITICAL, HIGH, vb.) raporlanmaktadır.
- **OS Fingerprinting (İşletim Sistemi Tespiti):** Hedef sistemin işletim sistemi (Windows, Linux, Ağ Cihazı) ICMP Ping TTL (Time-To-Live) değerleri üzerinden analiz edilerek arayüzde cihaz türüne göre özel ikonlarla gösterilmesi sağlandı.
- **Rapor Dışa Aktarma (PDF Export):** Tarama geçmişini CSV ve JSON formatlarının yanı sıra artık profesyonel bir PDF Raporu olarak dışa aktarma özelliği eklendi.
## v2.6.13
- **CI/CD Optimizasyonu:** GitHub Actions iş akışı (workflow) güncellendi. Artık gereksiz yere her kod gönderiminde derleme yapılmaması için `build-windows` ve `build-macos` işleri yalnızca CHANGELOG'a yeni bir versiyon numarası eklendiğinde (`release_needed == 'true'`) çalışacak şekilde koşullandırıldı. Bu sayede kota ve zaman tasarrufu sağlanacak.
## v2.6.12
- **Custom Scan Modülü:** Arayüze "Custom Scan" adlı yeni bir tarama modülü eklendi. Bu modül seçildiğinde ortaya çıkan metin kutusuna `80` veya `80,3389,5000` gibi özel portlar girilerek sadece bu hedeflerin taranması sağlanabiliyor.
- **Port Sayısı Gösterimi:** "Discovered Targets" listesinde artık her bir IP adresinde kaç adet aktif port bulunduğu anlık olarak sağ tarafta görüntülenmektedir.
- **Logo Kaldırıldı:** Sol menüdeki logo, daha sade bir görünüm için tamamen kaldırıldı.
## v2.6.11
- **UI Düzeltmesi:** Sol menüdeki logoya tıklandığında (https://gnn.tr) sayfanın yeni bir tarayıcı penceresinde açılmak yerine programın içindeki WebView'de açılmasına sebep olan link yönlendirmesi tamamen kaldırıldı. Logo artık sadece görsel bir element olarak işlev görüyor.
## v2.6.10
- **Quick Scan Kapsamı Genişletildi:** Kullanıcı talebi üzerine Quick Scan modülü güncellendi. Sadece Host Discovery (MAC/Ping) yapmak yerine artık sistemin durumunu hızlıca değerlendirebilmek için **en kritik ilk 20 TCP portunu** da ekstra olarak tarıyor.
## v2.6.9
- **Arayüz (UI) Kilitlenme ve Tarama İptali (Abort) İyileştirmesi:** Full Port Scan (65.535 port) sırasında her bir portun taranmasıyla ilgili arayüze log gönderilmesi, WebView köprüsünde büyük bir mesaj darboğazı oluşturuyordu. Bu durum, "Abort Scan" tuşuna basıldığında arka plan motoru anında dursa bile, arayüzün kuyruktaki on binlerce eski mesajı yazdırmaya devam etmesine (taramak akıyor gibi görünmesine) sebep oluyordu. Kapalı veya filtrelenmiş portların terminale yazdırılması devre dışı bırakılarak (Nmap'teki standart davranış gibi sadece açık portların ve genel durumların raporlanması sağlandı) bu darboğaz tamamen çözüldü. Artık tarama anında iptal ediliyor ve loglar temiz bir şekilde duruyor.
## v2.6.8
- **Yeni Tarama Modu eklendi (Quick Scan):** Kullanıcı talebi üzerine arayüze 4. bir seçenek olarak "Quick Scan" modülü eklendi. Bu mod seçildiğinde uygulama hiçbir TCP port taraması yapmaz; sadece hedefin ayakta olup olmadığını ve MAC/Üretici bilgilerini (ARP/Ping üzerinden) olağanüstü bir hızla tespit ederek süreci saniyeler içerisinde tamamlar.
## v2.6.7
- **Gelişmiş Tarama Kapsamı (Blue Team Modu):** Uygulamanın port tarama modları profesyonel bir siber güvenlik aracına (Nmap vb.) yakışacak seviyeye getirildi.
  - `Common Scan` (Standart Tarama) modu artık sadece 20 port yerine ilk **1024 ayrıcalıklı portun tamamını** ve popüler yüksek portları tarıyor.
  - `Full Port Scan` (Tam Tarama) modu artık 100 port yerine **tüm 65,535 TCP portunu** sıfırdan sona derinlemesine tarayarak gerçek bir Blue Team aracı gibi çalışıyor.
## v2.6.6
- **Zorunlu Tarama Modu (Nmap -Pn Benzeri):** Tekil ve statik harici IP adresleri veya alan adları girildiğinde, hedefin standart TCP Ping (Host Discovery) testini geçememesi durumunda taramanın iptal olması sorunu giderildi. Artık tekil hedefler Ping testinden düşse dahi (Güvenlik duvarı engellemesi vb.) "Up" (Açık) kabul edilerek port taramasına zorunlu olarak sokuluyor.
- **Ağ Zaman Aşımı İyileştirmesi:** TCP Ping discovery zaman aşımı toleransı dış ağ taramaları için 300ms'den 500ms'ye çıkarıldı.
## v2.6.5
- **Arayüz (UI) Geliştirmesi:** Sol paneldeki GNN Ecosystem logosu 150px genişliğinde, yüksekliği otomatik ayarlanacak şekilde orantısal olarak büyütüldü. Logoya tıklandığında uygulamanın resmi web sitesi (`https://gnn.tr`) varsayılan web tarayıcısında açılacak şekilde harici bağlantı özelliği eklendi.
- **Sürüm Güncellemesi:** Uygulama genelinde sürüm değerleri 2.6.5 olarak senkronize edildi.
## v2.6.4
- **Arayüz (UI) Güncellemesi:** Sol menüdeki logo bölümü tamamen sadeleştirildi. İkon ve metin kaldırılarak yalnızca "GNN Ecosystem" logosu merkezde konumlandırıldı ve altına 2.6.4 sürüm numarası eklendi.
- **macOS Uyumluluk Doğrulaması:** Evrensel (Universal) yapıların sorunsuz çalışması teyit edildi ve sürüm değerleri `2.6.4` olarak senkronize edildi.
## v2.6.3
- **CI/CD İyileştirmesi:** GitHub Actions üzerindeki Node.js 20 kullanımından kaynaklanan deprecation (kullanımdan kaldırma) uyarıları, tüm ilgili aksiyon eklentilerinin (checkout, setup-node, upload-artifact vb.) en güncel ana sürümlerine yükseltilmesiyle giderildi. Artık tüm süreçler sorunsuz bir şekilde doğrudan Node.js 24 üzerinde çalışmaktadır.
- **Sürüm Güncellemesi:** Tüm ortam, derleme ayarları ve kod referansları 2.6.3 sürümüne yükseltildi.

## v2.6.2
- **Hata Çözümü (Arayüz):** Javascript köprü değişkenindeki syntax (sözdizimi) hatası giderilerek arayüzdeki donma/tıklanamama sorunu çözüldü.
- **Hata Çözümü (Kurulum Sihirbazı):** `README.md` lisans dosyasının UTF-8 BOM (Byte Order Mark) kodlaması onarıldı; böylece Windows Kurulum Sihirbazı'ndaki Türkçe karakter sorunu (örn. geliÅŸtirilmiÅŸ) giderildi.

## v2.6.1
- **Yeniden Markalaşma:** Uygulama ismi "GNNcyber - NETscan" olarak güncellendi.
- **Sürüm Güncellemesi:** Tüm sistem ve CI/CD ayarlarında sürüm 2.6.1 olarak ayarlandı.
## v2.6.0
- **macOS Siyah Ekran Hata Çözümü:** macOS App Sandbox yetkilendirmelerine yerel istemci (network.client) ve sunucu (network.server) izinleri eklenerek, WebView'in yerel HTTP sunucusuna bağlanamaması sonucu oluşan siyah ekran problemi giderildi.
- **Platform Temizliği (iOS & Android Kaldırıldı):** Mobil platform (iOS ve Android) kodları, derleme gereksinimleri ve GitHub Actions mobil derleme işleri (build-ios) projeden tamamen temizlendi. Uygulama artık sadece Windows ve macOS masaüstü platformlarına odaklanmaktadır.

## v2.5.0
- **Sol Cihaz Listesinde Üretici (Vendor) Bilgisi:** Keşfedilen tüm IP adreslerinin hemen altına cihazların marka/üretici isimleri (örn. Apple, Synology, HP, Zyxel) eklenerek arayüzde gezinirken hızlıca görülmesi sağlandı.
- **Otomatik CI/CD Sürüm Yönetimi:** Sürüm yayınlama ve etiketleme işlemleri tamamen `CHANGELOG.md` tabanlı otomatikleştirildi, böylece her push'ta çift aksiyon çalışması önlendi.
- **Bireysel Tarama Detaylarını Dışa Aktarma (JSON & CSV):** Hedef Geçmişi (Target History) tablosuna her tarama satırı için bağımsız JSON ve CSV aktarım butonları eklendi. Bu sayede taranan IP adresleri, donanım MAC/Vendor bilgileri, açık portlar, servisler, versiyonlar ve zafiyet dereceleri detaylı olarak dışa aktarılabilmektedir.
- **Dinamik HOSTNAME ve Operatör Damgası:** Sol alt köşedeki profil alanı, taramayı gerçekleştiren makinenin yerel bilgisayar adıyla (`Platform.localHostname`) dinamik olarak güncellendi. Başlatılan tarama loglarına ve kaydedilen geçmiş verilerine bu HOSTNAME bilgisi basılarak Blue Team analizleri için tam izlenebilirlik sağlandı.

## v2.4.0
- **Yerel Ağda ARP Tabanlı Cihaz Keşfi:** TCP ping isteklerini engelleyen güvenlik duvarına sahip yerel cihazların tespiti için dinamik sistem ARP tablosu okuma özelliği eklendi.
- **Donanım (MAC) Adresi ve Üretici (Vendor) Bilgisi:** Keşfedilen tüm cihazların MAC adresleri ayıklanıp `macvendors.com` API'si üzerinden donanım üreticisi sorgulaması sorgulanarak arayüzde gösterilmesi sağlandı.
- **Web Arayüzü Tarayıcı Yönlendirmesi:** Açık portlarda HTTP/HTTPS web yayınları (80, 443, 5000, 8080 vb.) algılandığında yanına bir "tarayıcıda aç" butonu eklendi ve varsayılan tarayıcıda açılması sağlandı.
- **Linux Tarayıcı Desteği:** Dart tarafında Windows ve macOS'in yanı sıra Linux platformları için `xdg-open` entegrasyonu eklendi.
- **Dahili Hata Düzeltmeleri:** UI tasarımında sidebar başlığı ortalandı, font bütünlüğü Mono temayla uyumlu hale getirildi, real-time logs akış hızı optimize edildi.
