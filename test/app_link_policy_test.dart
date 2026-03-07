import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/app_link_policy.dart';

void main() {
  test('parseExternalHttpsUri accepts absolute https links', () {
    final uri = AppLinkPolicy.parseExternalHttpsUri(
      'https://example.com/privacy',
    );

    expect(uri, isNotNull);
    expect(uri!.scheme, 'https');
    expect(uri.host, 'example.com');
  });

  test('parseExternalHttpsUri rejects non-https links', () {
    final uri = AppLinkPolicy.parseExternalHttpsUri(
      'http://example.com/privacy',
    );

    expect(uri, isNull);
  });

  test('parseExternalHttpsUri rejects hostless values', () {
    final uri = AppLinkPolicy.parseExternalHttpsUri('/privacy');

    expect(uri, isNull);
  });
}
