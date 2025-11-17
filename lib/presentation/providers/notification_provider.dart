import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.read(notificationRepositoryProvider));
});

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationRepository _notificationRepository;

  NotificationsNotifier(this._notificationRepository) : super(NotificationsState());

  Future<void> loadNotifications({bool? isRead}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notifications = await _notificationRepository.getNotifications(isRead: isRead);
      final unreadCount = _notificationRepository.getUnreadCount(notifications);
      
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
      
      // Update the notification in the list
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }
        return notification;
      }).toList();
      
      final unreadCount = _notificationRepository.getUnreadCount(updatedNotifications);
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
      
      // Mark all notifications as read
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
}
