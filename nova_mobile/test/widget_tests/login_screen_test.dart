import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mobile/ui/screens/login_screen.dart';
import 'package:nova_mobile/viewmodels/login_viewmodel.dart';
import 'package:nova_mobile/repositories/auth_repository.dart';

class FakeLoginVM extends LoginViewModel {
  FakeLoginVM({bool shouldSucceed = true}) : super(AuthRepository()) {
    _shouldSucceed = shouldSucceed;
  }

  bool _shouldSucceed = true;
  @override
  Future<bool> login(String email, String password) async {
    loading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 10));
    loading = false;
    if (_shouldSucceed) {
      notifyListeners();
      return true;
    } else {
      error = 'Invalid credentials';
      notifyListeners();
      return false;
    }
  }
}

void main() {
  testWidgets('Login success navigates to home', (tester) async {
    final fake = FakeLoginVM(shouldSucceed: true);
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/login',
      routes: {
        '/': (c) => const Scaffold(body: Text('Home')),
        '/login': (c) => LoginScreen(viewModel: fake),
      },
    ));

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();

  expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Login failure shows error', (tester) async {
    final fake = FakeLoginVM(shouldSucceed: false);
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/login',
      routes: {'/login': (c) => LoginScreen(viewModel: fake)},
    ));

    await tester.enterText(find.byType(TextField).first, 'bad@example.com');
    await tester.enterText(find.byType(TextField).last, 'badpass');
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();

  expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
