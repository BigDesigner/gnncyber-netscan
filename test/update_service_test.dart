import 'package:flutter_test/flutter_test.dart';
import 'package:netscan/update_service.dart';

void main() {
  test('checkForUpdates hits the real GitHub Releases API and returns a sane shape', () async {
    final result = await UpdateService.checkForUpdates();

    expect(result['currentVersion'], kAppVersion);
    expect(result.containsKey('updateAvailable'), isTrue);

    if (result['error'] != null) {
      // Network/environment issue (e.g. sandboxed, no internet) - still must not throw
      // and must degrade to "no update available" rather than crashing the caller.
      expect(result['updateAvailable'], isFalse);
      // ignore: avoid_print
      print('checkForUpdates returned an error (expected in sandboxed/offline environments): ${result['error']}');
    } else {
      expect(result['latestVersion'], matches(RegExp(r'^\d+\.\d+\.\d+$')));
      // ignore: avoid_print
      print('Live GitHub check succeeded: current=$kAppVersion latest=${result['latestVersion']} updateAvailable=${result['updateAvailable']}');
    }
  });
}
