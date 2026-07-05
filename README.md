<div align="center">
  <h1>GNNscan <br> <sub>Advanced Network Discovery & Vulnerability Scanner</sub></h1>
  <p>Siber güvenlik uzmanları, Blue/Red Team operasyonları ve sistem yöneticileri için tasarlanmış, geleneksel ağ tarayıcılarının ötesine geçerek <strong>tamamen yerel, gizli ve derinlemesine</strong> ağ analizi yapan yeni nesil bir araçtır.</p>
</div>

---

## 🎯 Neden GNNscan?

Standart ping ve ARP tabanlı ağ tarayıcıları genellikle yüzeysel sonuçlar üretir. GNNscan ise ağınızdaki cihazların sadece IP'sini ve MAC adresini bulmakla kalmaz; o cihazın **işletim sistemini, üzerindeki servislerin tam versiyonunu, zafiyet seviyesini ve gerçek makine ismini (Hostname)** de tespit eder. Tüm bu işlemleri yaparken güvenlik duvarlarına yakalanmamak için **Stealth (Gizlilik)** algoritmaları kullanır.

## 🚀 Öne Çıkan Özellikler (Geleneksel Araçlardan Farkımız)

### 1. Derinlemesine Ağ ve Kimlik Keşfi
- **DNS & mDNS Hostname Çözümleme:** Sadece IP adreslerini değil, cihazların ağdaki gerçek isimlerini (ör. `iPhone.local`, `MSI-4060.home`) anında tespit eder.
- **İleri Seviye OS Fingerprinting:** Cihazların işletim sistemlerini (Windows, Linux/macOS, Network/Cisco) TTL (Time-To-Live) değerleri ve port karakteristikleri üzerinden kesin bir şekilde saptar.
- **Akıllı MAC & Yerel Arayüz Analizi:** Taramayı yapan yerel bilgisayarın MAC adresini tespit etmek için ARP tablosunu atlayıp işletim sisteminin native ağ arayüzlerini (`ipconfig /all`, `ifconfig`) Türkçe/İngilizce dil bağımsız olarak okur ve çözer.
- **Vendor/OUI Tespiti:** Cihazların hangi üreticiye ait olduğunu anında analiz eder.

### 2. Gerçek Servis Tespiti ve Banner Grabbing
- Klasik araçlar gibi 80 portunu görünce "HTTP" yazıp geçmez.
- **Banner Grabbing:** Açık portlara soket üzerinden özel payloadlar göndererek o portta gerçekten hangi servisin ve versiyonun (`SSH-2.0-OpenSSH`, `HTTP/1.1 200 OK`, `220 Welcome to FTP Server`) çalıştığını çeker.

### 3. IDS/IPS Atlatma ve Gizlilik (Stealth Scanning)
- Kurumsal ağlardaki Saldırı Tespit Sistemlerine (IDS/IPS) yakalanmamak için tasarlanmıştır.
- **T1'den T5'e Kadar Hız Kontrolü:** T1 (Sneaky) ile çok yavaş ve şüphe çekmeyen taramalar yapabilir veya T5 (Insane) ile saniyeler içinde koca bir ağı tarayabilirsiniz.
- **Shuffled (Rastgele) IP Tarama:** IP adreslerini `1, 2, 3...` diye sırayla taramak yerine karıştırarak (Shuffle) rastgele sırayla tarar. Bu sayede Port sweep alarmlarını tetiklemez.

### 4. Çevrimdışı (Air-gapped) Zafiyet Analizi (CVE)
- Bulunan açık portları, servisleri ve işletim sistemi versiyonlarını eşleştirerek potansiyel zafiyetleri (LOW, MEDIUM, HIGH, CRITICAL) olarak skorlar.
- Bunu yaparken verilerinizi buluta göndermez; **tamamen offline** çalışacak şekilde izole ağlarda kullanılabilir.

### 5. Sıfır Dışa Bağımlılık & Modern Mimari
- Tüm stil (Tailwind CSS) ve ikon kütüphaneleri projenin içine gömülüdür (Air-gapped ortamlarda tam fonksiyonel çalışır).
- Çirkin, Windows 98 tarzı arayüzlerin aksine, asenkron iletişim kuran (Dart backend <-> Javascript frontend) **şık, modern ve koyu tema (Blue Team)** odaklı bir arayüze sahiptir.
- SQL veri tabanı ile tarama geçmişinizi kalıcı olarak tutar. XSS zafiyetlerine karşı arayüzü sanitize edilmiştir.

---

## 💻 Teknoloji Yığını
- **Core (Engine):** Dart
- **Frontend / UI:** HTML5, Vanilla JavaScript, Local Tailwind CSS, Material Symbols
- **Database:** SQLite
- **Bridge:** Flutter InAppWebView (Tamamen Asenkron)

## ⚖️ Yasal Uyarı
Bu araç, sızma testleri (penetrasyon), ağ denetimleri ve savunma (Blue Team) operasyonları sırasında yetkili personelin kullanması için geliştirilmiştir. Sadece izniniz olan ağlarda kullanınız.

---
> *Copyright © 2024-2026 BigDesigner*
