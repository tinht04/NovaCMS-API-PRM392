import 'package:flutter/material.dart';
import '../../viewmodels/notification_viewmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationViewModel _vm = NotificationViewModel();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          final notifications = _vm.notifications;
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final n = notifications[i];
              return ListTile(
                leading: const Icon(Icons.notifications, color: Colors.blue),
                title: Text(n.message),
                onTap: () {
                  // Prefer an explicit onTap callback stored with the notification.
                  if (n.onTap != null) {
                    n.onTap!();
                    return;
                  }
                  // Fallback: simple message parsing for legacy notifications.
                  final msg = (n.message ?? '').toLowerCase();
                  if (msg.contains('giỏ hàng') || msg.contains('cart')) {
                    Navigator.of(context).pushNamed('/cart');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
