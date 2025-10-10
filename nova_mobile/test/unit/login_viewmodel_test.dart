import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/viewmodels/login_viewmodel.dart';
import '../fakes/fake_auth_repository.dart';

void main() {
  group('LoginViewModel', () {
    test('succeeds when repo returns non-empty map', () async {
      final repo = FakeAuthRepository((e, p) => {'accessToken': 'abc'});
      final vm = LoginViewModel(repo);

      final res = await vm.login('a', 'b');
      expect(res, isTrue);
      expect(vm.loading, isFalse);
      expect(vm.error, isNull);
    });

    test('fails when repo throws', () async {
      final repo = FakeAuthRepository((e, p) => throw Exception('network'));
      final vm = LoginViewModel(repo);

      final res = await vm.login('a', 'b');
      expect(res, isFalse);
      expect(vm.loading, isFalse);
      expect(vm.error, contains('network'));
    });

    test('reports empty map as failure', () async {
      final repo = FakeAuthRepository((e, p) => <String, dynamic>{});
      final vm = LoginViewModel(repo);

      final res = await vm.login('a', 'b');
      expect(res, isFalse);
      expect(vm.loading, isFalse);
    });

    test('handles slow responses and still updates loading', () async {
      final repo = FakeAuthRepository((e, p) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return {'accessToken': 'ok'};
      });
      final vm = LoginViewModel(repo);

      final future = vm.login('a', 'b');
      // shortly after starting, loading should be true
      expect(vm.loading, isTrue);
      final res = await future;
      expect(res, isTrue);
      expect(vm.loading, isFalse);
    });
  });
}
