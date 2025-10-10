import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/repositories/auth_repository.dart';
import '../fakes/fake_secure_storage.dart';
import '../fakes/fake_api_client.dart';

void main() {
  group('AuthRepository', () {
    test('stores tokens when present', () async {
      final client = FakeApiClient(responses: {
        '/api/Auth/login': {
          'statusCode': 200,
          'data': {'accessToken': 't1', 'refreshToken': 'r1'},
          'message': 'ok'
        }
      });

      final storage = FakeSecureStorage();
      final repo = AuthRepository(apiClient: null, storage: storage, postDataFn: (path, {data, queryParameters}) async {
        final r = client.responses[path];
        return r is Map ? r['data'] : r;
      });

      final result = await repo.login('a', 'b');
      expect(result['accessToken'], 't1');
      expect(await storage.read(key: 'access_token'), 't1');
      expect(await storage.read(key: 'refresh_token'), 'r1');
    });

    test('logout deletes tokens', () async {
      final storage = FakeSecureStorage();
      final repo = AuthRepository(apiClient: null, storage: storage);
      await storage.write(key: 'access_token', value: 'x');
      await storage.write(key: 'refresh_token', value: 'y');

      await repo.logout();
      expect(await storage.read(key: 'access_token'), isNull);
      expect(await storage.read(key: 'refresh_token'), isNull);
    });
  });
}
