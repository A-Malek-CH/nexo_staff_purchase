import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(notificationServiceProvider));
});

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository(this._notificationService);

  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int page = 1,
  }) async {
    return await _notificationService.getNotifications(
      isRead: isRead,
      page: page,
    );
  }

  Future<void> markAsRead(String notificationId) async {
    return await _notificationService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    return await _notificationService.markAllAsRead();
  }

  int getUnreadCount(List<NotificationModel> notifications) {
    return notifications.where((n) => !n.isRead).length;
  }
}
