import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  // Allow an optional viewModel and an optional onSuccess callback.
  const LoginScreen({super.key, this.viewModel, this.onSuccess});

  final LoginViewModel? viewModel;
  final VoidCallback? onSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginViewModel _vm;
  late final VoidCallback _vmListener;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? LoginViewModel(AuthRepository());
    _vmListener = () => setState(() {});
    _vm.addListener(_vmListener);
  }

  @override
  void dispose() {
    _vm.removeListener(_vmListener);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final ok = await _vm.login(email, password);
    if (!mounted) return;
    if (ok) {
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            if (_vm.loading) const CircularProgressIndicator(),
            if (_vm.error != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(_vm.error!, style: const TextStyle(color: Colors.red))),
            if (!_vm.loading) ElevatedButton(onPressed: _submit, child: const Text('Sign in')),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: const Text('Sign up')),
          ],
        ),
      ),
    );
  }
}
