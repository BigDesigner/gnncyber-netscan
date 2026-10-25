# Güvenlik Denetim Raporu (Security Audit Report): 39c9c47

## Zafiyet Özeti (Vulnerability Dashboard)
| Önem Derecesi | Sayı | Tespit Edilen Sınıflar |
|---|---|---|
| **Kritik (Critical)** | 0 | - |
| **Yüksek (High)** | 0 | - |
| **Orta (Medium)** | 0 | - |
| **Düşük (Low)** | 0 | - (1 Önceden Düzeltildi: DOM XSS Sanitization) |

## Detaylı Zafiyet Envanteri (Detailed Vulnerability Inventory)

### [Cross-Site Scripting (XSS) / DOM Injection - Remediation Verified]
- **Önem Derecesi (Severity):** Düşük (Low) -> Giderildi (Resolved)
- **Konum (Location):** `assets/web/index.html#L1414-L1420`
- **Açıklama (Description):** Cihaz seçim panelinde `macSpan.innerHTML` içine yerleştirilen `host.mac` ve `host.vendor` değerleri `htmlEscape()` fonksiyonundan geçirilmeden doğrudan DOM'a aktarılıyordu. Bu durum teorik olarak manipüle edilmiş ARP/OUI verisi ile DOM XSS zafiyeti doğurabilirdi.
- **Düzeltme (Remediation):** `host.mac` ve `host.vendor` değişkenleri `htmlEscape()` süzgecine alınarak güvenli hale getirildi.

---

## Proje Sınır Koşulları Denetimi (Project Boundary Conditions Audit)
- **XSS Koruması (XSS Prevention):** [OK] - Tüm WebView köprü çıktıları ve DOM manipülasyonları `htmlEscape()` ile güvenceye alınmıştır.
- **SQL / Veritabanı Enjeksiyonu (SQL Injection):** [OK] - `database_helper.dart` içindeki CVE aramaları parametrik sorgu (`whereArgs`) kullanmaktadır.
- **RCE & Komut Enjeksiyonu (Command Injection):** [OK] - `scan_engine.dart` içerisindeki `Process.run('ping', ...)` çağrısı öncesi katı IPv4/IPv6 Regex doğrulaması devrededir. Güncelleme URL'leri katı whitelist ile korunmaktadır.
- **Çevrimdışı Öncelikli Mimari (Offline First):** [OK] - OUI ve CVE veritabanları yerel SQLite ve bundle varlıkları üzerinden dışa bağımlı olmadan çalışmaktadır.
- **Ağ İzolasyonu (Network Boundary):** [OK] - Ham soket işlemleri yalnızca Dart katmanında yürütülmekte, WebView içerisinde doğrudan soket çağrısı yapılmamaktadır.
