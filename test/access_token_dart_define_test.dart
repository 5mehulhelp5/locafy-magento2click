// Guards the build-time wiring of the Magento integration token.
//
// This repo is public, so the token is not a literal in source. It arrives via
// `--dart-define=MAGENTO_ACCESS_TOKEN=...` and is read once, as a const, by
// `kMagentoAccessToken` in env.dart. Two ways that breaks silently:
//
//   1. Someone pastes a literal back in. It was hardcoded in TWO places
//      originally — `serverConfig.accessToken` in env.dart and `adminKey` in
//      services/base_services.dart — so the scan below covers all of lib/,
//      not just the one obvious spot.
//   2. Someone drops the `const` from kMagentoAccessToken. String.fromEnvironment
//      only reads the define when const-evaluated; without `const` it silently
//      returns the default and every authenticated call 401s.
//
// Case 2 is only observable when a define is actually present, so run with one
// for the full guarantee:
//   flutter test --dart-define=MAGENTO_ACCESS_TOKEN=probe
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magentoegypt/env.dart';

void main() {
  const fromDefine = String.fromEnvironment('MAGENTO_ACCESS_TOKEN');

  test('serverConfig.accessToken is fed by the dart-define, not a literal', () {
    final configured =
        (environment['serverConfig'] as Map<String, dynamic>)['accessToken'];

    expect(configured, equals(fromDefine),
        reason: 'serverConfig.accessToken must read kMagentoAccessToken, and '
            'kMagentoAccessToken must stay a const String.fromEnvironment. A '
            'hardcoded token, or a lost `const`, shows up here as a mismatch.');
    expect(kMagentoAccessToken, equals(fromDefine));
  });

  test('no Magento-token-shaped literal is committed anywhere in lib/', () {
    // A Magento integration token is 32 lowercase alphanumerics. As of writing
    // there is not a single string literal of that shape in lib/, so this has
    // no false positives to tolerate.
    final tokenish = RegExp(r'''(?:'|")([a-z0-9]{32})(?:'|")''');
    final offenders = <String>[];

    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      for (final m in tokenish.allMatches(f.readAsStringSync())) {
        offenders.add('${f.path}: ${m.group(1)}');
      }
    }

    expect(offenders, isEmpty,
        reason: 'These look like raw integration tokens committed to a public '
            'repo. Route them through kMagentoAccessToken instead:\n'
            '${offenders.join('\n')}');
  });
}
