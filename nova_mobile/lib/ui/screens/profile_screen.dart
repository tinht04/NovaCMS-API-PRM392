import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../repositories/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = ProfileRepository();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getProfile();
      setState(() {
        _profile = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final storage = const FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Error: $_error'), const SizedBox(height: 8), ElevatedButton(onPressed: _load, child: const Text('Retry'))])),
      );
    }

    final name = _profile?['fullName'] ?? _profile?['name'] ?? _profile?['displayName'] ?? 'No name';
    final email = _profile?['email'] ?? _profile?['userName'] ?? '';
    final avatar = _profile?['avatarUrl'] ?? _profile?['avatar'] ?? _profile?['image'];

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(radius: 48, backgroundImage: avatar != null ? NetworkImage(avatar) : null, child: avatar == null ? const Icon(Icons.person, size: 48) : null),
            const SizedBox(height: 12),
            Text(name, style: Theme.of(context).textTheme.headlineSmall),
            if (email.isNotEmpty) ...[const SizedBox(height: 6), Text(email, style: Theme.of(context).textTheme.bodyMedium)],
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
              const SizedBox(width: 12),
              OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('Logout')),
            ]),
          ],
        ),
      ),
    );
  }
}
