import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: AnimatedBuilder(
        animation: NotificationService.instance,
        builder: (context, _) {
          final notifications = NotificationService.instance.notifications;
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: Text(notifications[i].message),
              onTap: () {
                final msg = notifications[i].message.toLowerCase();
                if (msg.contains('giỏ hàng')) {
                  Navigator.of(context).pushNamed('/cart');
                } else if (notifications[i].onTap != null) {
                  notifications[i].onTap!();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
