import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_bottom_nav.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationsState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notificationsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationsState.notifications.isEmpty
              ? const Center(
                  child: Text('No notifications', style: AppTheme.bodyMedium),
                )
              : ListView.builder(
                  itemCount: notificationsState.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationsState.notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notification.isRead
                              ? AppTheme.lightGrey
                              : AppTheme.primaryOrange,
                          child: Icon(
                            Icons.notifications,
                            color: AppTheme.white,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notification.message),
                        onTap: () {
                          if (!notification.isRead) {
                            ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                          }
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
