# Security Audit Report: 607f2f1

| Alan | Değer |
|---|---|
| Branch | `main` |
| HEAD Commit | `607f2f1` (v2.18.1) |
| Worktree State | `clean` |
| Audit Mode | Full Contract Mode (`.specs/boundary-conditions.md` yüklendi) |
| Inspected File Manifest Digest | `sha256:dfe91e4d92db6965` (11 dosya) |
| Timestamp | 2026-10-25T20:39:10+03:00 |
| Run ID | `a7c31e` |

> Bu rapor salt-okunur bir denetimdir. Hiçbir uygulama kaynak dosyası değiştirilmemiştir.

## Vulnerability Dashboard
| Severity | Count | Classes Detected |
|---|---|---|
| **Critical** | 0 | — |
| **High** | 1 | RCE / Komut Enjeksiyonu (`openExternalUrl` köprüsü) |
| **Medium** | 2 | CSV/Formula Injection (uzak banner verisi), Güncelleme Bütünlüğü (imza/hash doğrulaması yok) |
| **Low** | 8 | Bağlam-yanlış escaping & boundary ihlalleri, harici font (Offline-First ihlali), WebView ayar sertleştirmesi, loopback sunucu, ayar sınırları, global CSV export, ölü ayar (`aggressive`), CI tedarik zinciri |

## Detailed Vulnerability Inventory

### H-01 · RCE / OS Komut Enjeksiyonu — `openExternalUrl` JS Köprüsü
- **Severity:** High
- **Location:** `lib/main.dart#L482-L499`
- **Verification Tier:** `Defense-in-Depth / Conditional Risk`
- **Attack / Dataflow Path:** `WebView JS (window.flutter_inappwebview.callHandler('openExternalUrl', X)) -> main.dart#L486 (args[0] as String, doğrulama yok) -> Process.run('cmd', ['/c','start','',X]) (main.dart#L488)`
- **Description:** Köprü, WebView içinde çalışan herhangi bir JS'ten gelen dizgeyi şema/host doğrulaması yapmadan `cmd.exe /c start` komutuna veriyor. Dart, Windows'ta yalnızca boşluk/tırnak içeren argümanları tırnaklar; `&`, `|`, `^` gibi cmd metakarakterleri tırnaklanmaz. Örn. `https://x&calc.exe` → `calc.exe` çalışır. Metakarakter olmasa bile `start` yerel/UNC yürütülebilir dosyaları (`\\attacker\share\a.exe`, `file:///C:/...`) doğrudan başlatır. macOS'ta `open` de keyfi uygulama/dosya açar. Mevcut UI çağıranı (`index.html#L1469`) URL'yi yalnızca IPv4 + int port'tan üretir, ve tespit edilen tüm DOM sink'leri escape edildiği için doğrulanmış bir XSS zinciri bulunamadı; bu yüzden "Conditional". Ancak `flutter_inappwebview` handler'ları varsayılan olarak tüm origin/frame'lere enjekte eder ve `shouldOverrideUrlLoading`/origin allow-list yoktur — herhangi bir gelecekteki XSS veya harici navigasyon doğrudan RCE'ye dönüşür.
- **Remediation:** Dart tarafında `Uri.tryParse` ile yalnızca `http`/`https` şemasına izin ver, host'un geçerli IP/hostname olduğunu doğrula, `cmd /c start` yerine `url_launcher` (`launchUrl`) kullan veya Windows'ta `rundll32 url.dll,FileProtocolHandler` + strict whitelist. Ek olarak `InAppWebViewSettings` içinde `javaScriptHandlersOriginAllowList: {'http://127.0.0.1:$_port'}` tanımla.
- **Code Snippet:**
```dart
final urlString = args[0] as String;
if (Platform.isWindows) {
  await Process.run('cmd', ['/c', 'start', '', urlString]);
```

### M-01 · CSV / Formula Injection — Tekil Tarama CSV Export'u
- **Severity:** Medium
- **Location:** `assets/web/index.html#L1922-L1936`
- **Verification Tier:** `Confirmed Exploit Path`
- **Attack / Dataflow Path:** `Uzak servis banner'ı / HTTP Server header (scan_engine.dart#L455-L467) veya saldırgan kontrollü PTR kaydı (scan_engine.dart#L649-L657) -> onPortDiscovered/onHostDiscovered -> history JSON -> exportSingleScan() CSV şablonu (index.html#L1930,#L1933) -> saveExportFile -> Excel/LibreOffice`
- **Description:** `version`, `hostname`, `vendor` alanları çift tırnak içine konuyor ama içerideki `"` kaçırılmıyor ve `=`, `+`, `-`, `@` ile başlayan değerler nötrleştirilmiyor. Taranan ağdaki kötü niyetli bir servis `Server: x","=HYPERLINK(...)` gibi bir başlık döndürerek sütundan kaçar ve formül enjekte eder. HTTP `Server:` başlığında uzunluk sınırı yoktur.
- **Remediation:** Her hücre için `"` → `""` kaçışı uygula ve `^[=+\-@\t\r]` ile başlayan değerlerin başına `'` ekle. Ortak bir `csvCell()` yardımcı fonksiyonu kullan.
- **Code Snippet:**
```javascript
csv += `"${host.ip}","${hostNameVal}",...,"${p.version || 'UNKNOWN'}",...\n`;
```

### M-02 · Güncelleme Bütünlüğü — Çalıştırma Öncesi İmza/Hash Doğrulaması Yok
- **Severity:** Medium
- **Location:** `lib/update_service.dart#L151-L188`
- **Verification Tier:** `Defense-in-Depth / Conditional Risk`
- **Attack / Dataflow Path:** `GitHub Releases asset -> HttpClient indirme -> %TEMP%\GNNcyber_NETscan_Setup.exe -> Process.start(filePath, detached)`
- **Description:** URL whitelist'i (v2.18.1 null-byte yaması dahil) doğru çalışıyor; ancak indirilen kurulum dosyası hiçbir SHA-256 / Authenticode doğrulamasından geçmeden çalıştırılıyor. Güvenlik tamamen GitHub hesabının ve release pipeline'ının bütünlüğüne dayanıyor. Dosya öngörülebilir bir temp yoluna yazılıyor (yazma ile çalıştırma arasında aynı kullanıcı bağlamında TOCTOU penceresi).
- **Remediation:** CI'da `SHA256SUMS` (tercihen imzalı) release asset'i yayınla; indirmeden sonra hash'i doğrula. Windows installer'ı Authenticode ile imzala ve çalıştırmadan önce imzayı doğrula. Temp dosyası için rastgele isimli alt dizin kullan.
- **Code Snippet:**
```dart
await sink.close();
onProgress(100.0);
if (Platform.isWindows) {
  await Process.start(filePath, [], mode: ProcessStartMode.detached);
```

### L-01 · Bağlam-Yanlış Escaping & Escape Edilmemiş DOM Değerleri (Boundary İhlali)
- **Severity:** Low
- **Location:** `assets/web/index.html#L1377`, `#L1458`, `#L1469-L1472`, `#L1816`
- **Verification Tier:** `Defense-in-Depth / Conditional Risk`
- **Attack / Dataflow Path:** `history JSON (yerel dosya) / bundled CVE DB -> loadHistoryItem() -> updatePortsTable()/updateHostsTreeView() -> innerHTML`
- **Description:** (a) `onclick="selectHost('${htmlEscape(ip)}')"`: HTML parser `&#039;` değerini JS çalışmadan önce `'`'ye çözer — HTML escape, JS-string-in-attribute bağlamı için yetersiz. (b) `p.vulnScore`, `p.vulnLevel`, `item.findingsCount`, `targetUrl` escape edilmeden `innerHTML`'e yazılıyor. Mevcut kaynaklar (IPv4 çözümlemesi, bundled DB) güvenli olduğu için düşük; ancak `.specs/boundary-conditions.md` "Dart'tan gelen her dizge `htmlEscape()`'den geçmeli" kuralını ihlal ediyor ve history dosyasına yazabilen yerel bir saldırgan için H-01'e köprü oluşturur.
- **Remediation:** Inline `onclick` yerine `data-ip` + `addEventListener` kullan; kalan tüm değerleri `htmlEscape()` ile sar.

### L-02 · Harici Google Fonts Yüklemesi (Offline-First İhlali)
- **Severity:** Low
- **Location:** `assets/web/index.html#L22`
- **Verification Tier:** `Confirmed Exploit Path` (gizlilik sızıntısı)
- **Description:** Her uygulama açılışında `fonts.googleapis.com`'a istek gidiyor; kullanıcının IP'si ve kullanım zamanlaması üçüncü tarafa sızıyor ve air-gapped ortamlarda font yüklenmiyor. "Offline First" sınır koşuluyla çelişiyor. Ayrıca CSP tanımlı değil.
- **Remediation:** JetBrains Mono / Geist fontlarını `assets/web/` altına bundle et; `<meta http-equiv="Content-Security-Policy" content="default-src 'self'; ...">` ekle.

### L-03 · Gereksiz Gevşek WebView Ayarları
- **Severity:** Low
- **Location:** `lib/main.dart#L180-L185`
- **Verification Tier:** `Defense-in-Depth / Conditional Risk`
- **Description:** İçerik `http://127.0.0.1` üzerinden sunulmasına rağmen `allowFileAccessFromFileURLs` ve `allowUniversalAccessFromFileURLs` `true`. Navigasyon kısıtlaması (`shouldOverrideUrlLoading`) ve handler origin allow-list yok.
- **Remediation:** Her iki ayarı `false` yap; yalnızca loopback origin'e navigasyona izin ver.

### L-04 · Loopback Asset Sunucusu — Host Başlığı Kontrolü Yok
- **Severity:** Low
- **Location:** `lib/main.dart#L97-L152`
- **Verification Tier:** `Defense-in-Depth / Conditional Risk`
- **Description:** Sunucu yalnızca `127.0.0.1`'e bağlı ve `rootBundle` dosya sistemi traversal'ına izin vermiyor (OK). Ancak `Host` başlığı doğrulanmadığı için DNS rebinding ile tarayıcıdaki bir site bundled asset'leri (CVE DB, OUI DB) okuyabilir; hata yanıtı exception metnini yansıtıyor (`Asset not found: $e`).
- **Remediation:** `request.headers.host` değerinin `127.0.0.1:$_port` olduğunu doğrula; genel 404 mesajı döndür.

### L-05 · Ayar Köprüsünde Sınır/Tip Doğrulaması Yok
- **Severity:** Low
- **Location:** `lib/main.dart#L327-L333`, `#L209-L213`; `lib/history_db.dart#L77-L85`
- **Verification Tier:** `Defense-in-Depth / Conditional Risk`
- **Description:** `saveSettings` keyfi bir map'i olduğu gibi diske yazıyor. `maxThreads`/`timeoutMs` için üst sınır yok (soket tükenmesi); tip uyuşmazlığında (`double`/`String`) `as int?` cast'i `startScan` handler'ını exception ile düşürür.
- **Remediation:** İzin verilen anahtarları whitelist'le; `maxThreads` (1–512) ve `timeoutMs` (50–10000) için `clamp` uygula; `(v as num?)?.toInt()` kullan.

### L-06 · Global History CSV Export'unda Alıntılama/Nötrleştirme Yok
- **Severity:** Low
- **Location:** `lib/main.dart#L466-L472`
- **Verification Tier:** `Defense-in-Depth / Conditional Risk`
- **Description:** `target`, `module`, `scanHost` alanları tırnaksız yazılıyor; virgül içeren değerler sütunları kaydırır, `=` ile başlayan hedef formül olarak yorumlanır. Değerler yerel kullanıcı girdisi olduğundan düşük.
- **Remediation:** M-01 ile aynı `csvCell()` mantığını Dart tarafında uygula.

### L-07 · Ölü Ayar Sinyali — `aggressive` (Rule 22)
- **Severity:** Low
- **Location:** `lib/history_db.dart#L91`, `assets/web/index.html#L1527`, `#L1558`
- **Verification Tier:** `Confirmed Exploit Path` (fonksiyonel)
- **Description:** UI `aggressive` ayarını kaydediyor fakat Dart tarafında hiçbir yerde okunmuyor; kullanıcı etkisiz bir kontrolü değiştirdiğini sanıyor.
- **Remediation:** Ayarı `ScanEngine`'e bağla veya UI'dan kaldır.

### L-08 · CI Tedarik Zinciri Sertleştirmesi
- **Severity:** Low
- **Location:** `.github/workflows/build.yml#L16-L17`, `#L80`, `#L203`
- **Verification Tier:** `Defense-in-Depth / Conditional Risk`
- **Description:** Üçüncü parti action'lar (`subosito/flutter-action@v2`, `softprops/action-gh-release@v3`) commit SHA yerine değişebilir tag ile pinlenmiş; `contents: write` yetkisi workflow genelinde (PR build'leri dahil) veriliyor. Ayrıca `test/update_service_test.dart` CI'da canlı GitHub API'sine istek atıyor (rate-limit kaynaklı kararsızlık).
- **Remediation:** Action'ları tam commit SHA ile pinle; varsayılanı `contents: read` yapıp yalnızca `release` job'unda `contents: write` ver; canlı API testini CI'da mock'la veya etiketle.

---

## Project Boundary Conditions Audit
- **XSS Prevention (`htmlEscape()` zorunluluğu):** **Violation (Kısmi)** — Ağdan gelen tüm banner/hostname/vendor/MAC değerleri doğru şekilde escape ediliyor veya `textContent` ile yazılıyor (log terminali, update paneli, subnet listesi OK). Ancak `vulnScore`, `vulnLevel`, `findingsCount`, `targetUrl` escape edilmeden `innerHTML`'e gidiyor ve inline `onclick` bağlamında yanlış encoding kullanılıyor (L-01).
- **Offline First:** **Violation (Kısmi)** — CVE eşleştirme tamamen offline (OK, parametreli `LIKE` sorgusu — SQL injection yok). Ancak Google Fonts her açılışta harici istek yapıyor (L-02).
- **Privacy (macvendors.com yalnızca fallback):** **OK** — Online lookup varsayılan olarak kapalı (`enableOnlineVendorLookup: false`), yalnızca 6 karakterlik OUI prefix'i gönderiliyor.
- **UI Logic (Dart yalnızca köprü):** **OK**.
- **Network Logic (Raw socket Dart'ta):** **OK** — WebView'da port tarama için AJAX/WebSocket kullanımı yok.
- **CI Triggers:** **OK (belge güncel değil)** — Workflow `main` push/PR ve `workflow_dispatch` ile tetikleniyor; sınır belgesindeki "yalnızca setup/pubspec değişince" ifadesi mevcut workflow ile uyuşmuyor (belge drift'i).

### Doğrulanmış Güvenli Kontroller
- `UpdateService.isValidUpdateUrl()` — https + `github.com` + repo path prefix + uzantı + null-byte reddi (v2.18.1). OK.
- `_pingHost()` — `Process.run` argüman listesi (shell yok) + strict IP regex. OK.
- `findCveForService()` — parametreli `whereArgs`. OK.
- Hardcoded secret / API anahtarı: bulunamadı. OK.
- Public dokümantasyon (README/CHANGELOG) iç agent direktifi sızıntısı: bulunamadı. OK.
- Tek kaynak versiyonlama (Rule 23): `sync_version.py --check` CI'da zorunlu. OK.

## Audit Scope & Unverified Runtime Risks
- **Inspected Modules / Files:** `lib/main.dart`, `lib/scan_engine.dart`, `lib/update_service.dart`, `lib/network_interface_helper.dart`, `lib/history_db.dart`, `lib/database_helper.dart`, `lib/version.dart`, `assets/web/index.html` (script bölümü + tüm DOM sink'leri), `.github/workflows/build.yml`, `.specs/boundary-conditions.md`, `.specs/constitution.md`, `README.md`/`CHANGELOG.md` (meta-sızıntı taraması).
- **Kapsam Dışı:** `assets/web/tailwind.js` (vendored üçüncü parti), `windows/`, `macos/` native runner kodu, `setup.iss`, `scripts/*.py` (yalnızca secret taraması).
- **Dependency Audit Method:** `Static Manifest/Lockfile Inspection Only (Live CVE DB Not Queried)` — Dart/pub için yerel salt-okunur advisory aracı çalıştırılmadı. `pub get` çıktısında 21 paketin kısıtlarla uyumsuz yeni sürümü var (örn. `file_picker` 11→13, `win32` 5→6); bilinen advisory tespit edilmedi.
- **Unverified Runtime Boundaries:** `flutter_inappwebview`'in gerçek çalışma zamanındaki handler origin enjeksiyon davranışı; Windows Dart `Process.run` argüman quoting'inin hedef SDK sürümündeki kesin davranışı; GitHub hesap/2FA ve release pipeline bütünlüğü; son kullanıcının Excel DDE/formül uyarı ayarları; WebView2 runtime sürümü.
