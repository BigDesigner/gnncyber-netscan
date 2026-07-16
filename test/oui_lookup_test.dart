import 'package:flutter_test/flutter_test.dart';
import 'package:netscan/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled OUI database (IEEE registry) loads and resolves known prefixes', () async {
    final helper = DatabaseHelper();
    await helper.init();

    // Stable, well-known IEEE-registered prefixes (not part of the curated override list).
    expect(helper.lookupOuiVendor('FCFC48'), 'Apple, Inc.');
    expect(helper.lookupOuiVendor('000000'), 'XEROX CORPORATION');
    expect(helper.lookupOuiVendor('74867A'), 'Dell Inc.');

    // Lookup should be case-insensitive.
    expect(helper.lookupOuiVendor('fcfc48'), 'Apple, Inc.');

    // Unknown / malformed prefixes must return null (caller falls back to 'UNKNOWN').
    expect(helper.lookupOuiVendor('ZZZZZZ'), isNull);
    expect(helper.lookupOuiVendor(''), isNull);

    // Sanity check that the full IEEE registry loaded, not just a handful of entries.
    expect(helper.debugOuiEntryCount, greaterThan(30000));
  });

  test('CVE database still initializes correctly alongside OUI database', () async {
    final helper = DatabaseHelper();
    await helper.init();
    // Should not throw; a missing match should simply return null.
    final result = await helper.findCveForService('nonexistent-service-xyz', '0.0.0');
    expect(result, isNull);
  });
}
