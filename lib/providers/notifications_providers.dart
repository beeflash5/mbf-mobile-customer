import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/notification.dart';
import 'package:fuodz/services/notification.service.dart';

/// Controller list notifikasi (lokal). Pakai `AsyncNotifier` agar UI dapat
/// state loading otomatis dan bisa di-refresh.
class NotificationsController
    extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    return NotificationService.getNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(NotificationService.getNotifications);
  }

  /// Mark sebagai sudah dibaca (lokal + persist).
  Future<void> markRead(NotificationModel n) async {
    n.read = true;
    NotificationService.updateNotification(n);
    await refresh();
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<NotificationModel>>(
  NotificationsController.new,
);
