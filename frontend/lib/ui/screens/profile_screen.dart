import 'package:flutter/material.dart';
import '../../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _vm = ProfileViewModel();

  @override
  void initState() {
    super.initState();
    _vm.loadProfile();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _vm.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        if (_vm.loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (_vm.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Error: ${_vm.error}'), const SizedBox(height: 8), ElevatedButton(onPressed: _vm.loadProfile, child: const Text('Retry'))])),
          );
        }
        final data = _vm.profile ?? {};
    final name = data['fullName'] ?? data['name'] ?? 'No name';
    final email = data['email'] ?? '';
    final avatar = data['avatarUrl'];
    final phone = data['phoneNumber'] ?? 'Not provided';
    final points = (data['loyaltyPoints'] ?? 0) as num;
    final address = data['address'] ?? 'Not provided';
    final createdAt = data['createdAt'];
    final status = data['status'] ?? '';
    final role = data['roleName'] ?? '';
    final invoiceAmount = (data['invoiceAmount'] ?? 0) as num;
    final totalTransactions = (data['totaltransactions'] ?? 0) as num;

    String fmtCurrency(num v) {
      try {
        final iv = v.toInt();
        final s = iv.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
        return '₫$s';
      } catch (_) {
        return v.toString();
      }
    }

    String fmtDate(dynamic v) {
      try {
        final dt = DateTime.parse(v.toString()).toLocal();
  return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      } catch (_) {
        return v?.toString() ?? '';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            CircleAvatar(radius: 44, backgroundImage: avatar != null ? NetworkImage(avatar) : null, child: avatar == null ? const Icon(Icons.person, size: 42) : null),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(name, style: Theme.of(context).textTheme.headlineSmall)), const SizedBox(width: 8), Chip(label: Text(role))]),
                const SizedBox(height: 6),
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.star, color: Colors.orange), const SizedBox(width: 6), Text('${points.toInt()} points', style: const TextStyle(fontWeight: FontWeight.bold))]),
              ]),
            )
          ]),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(children: [const Text('Invoice Amount'), const SizedBox(height: 6), Text(fmtCurrency(invoiceAmount), style: const TextStyle(fontWeight: FontWeight.bold))]),
                Column(children: [const Text('Transactions'), const SizedBox(height: 6), Text(totalTransactions.toString(), style: const TextStyle(fontWeight: FontWeight.bold))]),
                Column(children: [const Text('Status'), const SizedBox(height: 6), Text(status.toString(), style: const TextStyle(fontWeight: FontWeight.bold))]),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Account details', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(email)),
          ListTile(leading: const Icon(Icons.phone), title: const Text('Phone'), subtitle: Text(phone ?? 'Not provided')),
          ListTile(leading: const Icon(Icons.home), title: const Text('Address'), subtitle: Text(address ?? 'Not provided')),
          ListTile(leading: const Icon(Icons.calendar_today), title: const Text('Member since'), subtitle: Text(fmtDate(createdAt ?? ''))),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: _vm.loadProfile, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
            const SizedBox(width: 12),
            OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('Logout')),
          ])
        ]),
      ),
    );
      },
    );
  }
}
