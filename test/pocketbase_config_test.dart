import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/data/remote/pocketbase_config.dart';

void main() {
  test('buildUri preserves PocketBase base path prefixes', () {
    const config = PocketBaseConfig(
      baseUrl: 'https://example.com/pb',
      email: 'user@example.com',
      password: 'secret',
    );

    final uri = config.buildUri('/api/collections/users/records', {
      'perPage': '1',
    });

    expect(
      uri.toString(),
      'https://example.com/pb/api/collections/users/records?perPage=1',
    );
  });
}
