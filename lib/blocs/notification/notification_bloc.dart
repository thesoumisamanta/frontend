import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ApiService apiService;

  NotificationBloc({required this.apiService}) : super(NotificationInitial()) {
    on<NotificationLoad>(_onNotificationLoad);
    on<NotificationMarkAsRead>(_onNotificationMarkAsRead);
    on<NotificationMarkAllAsRead>(_onNotificationMarkAllAsRead);
    on<NotificationAdd>(_onNotificationAdd);
  }

  Future<void> _onNotificationLoad(
    NotificationLoad event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final currentState = state;
      bool isSlientRefresh = false;

      // Only emit loading if we don't have content, OR if it's an explicit full reload.
      // If we are refreshing but have content, we might want to keep showing it?
      // But standard pull-to-refresh usually handles its own loading state locally?
      // No, usually Bloc emits Loading, causing UI updates.
      // To implement "Silent Refresh" (keep data, show loading, update data, or fail silently):

      if (currentState is NotificationLoaded && event.refresh) {
        // We have data, and we are refreshing.
        // Do NOT emit NotificationLoading if you want to keep data visible.
        // BUT, we need to know we are loading.
        // Since we don't have a "NotificationRefreshing" state, we just don't emit Loading.
        isSlientRefresh = true;
      } else if (currentState is! NotificationLoaded) {
        emit(NotificationLoading());
      }
      // If none of above (e.g. pagination load), we handle it below (we don't emit Loading for pagination typically, checks are inside)

      int page = 1;
      List<NotificationModel> currentNotifications = [];

      if (currentState is NotificationLoaded && !event.refresh) {
        page = currentState.currentPage + 1;
        currentNotifications = currentState.notifications;
      }

      final response = await apiService.getNotifications(page: page, limit: 20);

      if (response['success'] == true) {
        final List<dynamic> notificationsJson = response['notifications'];
        final newNotifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        final allNotifications = event.refresh
            ? newNotifications
            : [...currentNotifications, ...newNotifications];
        final hasMore = page < response['totalPages'];
        final unreadCount = response['unreadCount'] ?? 0;

        emit(
          NotificationLoaded(
            notifications: allNotifications,
            unreadCount: unreadCount,
            hasMore: hasMore,
            currentPage: page,
          ),
        );
      } else {
        if (isSlientRefresh) {
          // Don't blow up the UI if refresh failed
          print('Failed to refresh notifications: ${response['message']}');
        } else {
          emit(
            NotificationError(
              response['message'] ?? 'Failed to load notifications',
            ),
          );
        }
      }
    } catch (e) {
      if (state is NotificationLoaded) {
        print('Error refreshing notifications: $e');
      } else {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onNotificationMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await apiService.markNotificationAsRead(event.notificationId);

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final updatedNotifications = currentState.notifications.map((notif) {
          if (notif.id == event.notificationId) {
            return NotificationModel(
              id: notif.id,
              recipient: notif.recipient,
              sender: notif.sender,
              type: notif.type,
              message: notif.message,
              post: notif.post,
              comment: notif.comment,
              story: notif.story,
              isRead: true,
              createdAt: notif.createdAt,
            );
          }
          return notif;
        }).toList();

        final newUnreadCount = currentState.unreadCount > 0
            ? currentState.unreadCount - 1
            : 0;

        emit(
          currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: newUnreadCount,
          ),
        );
      }

      // REMOVED: emit(NotificationMarkedAsRead(event.notificationId));
      // This was causing the state to be overwritten
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onNotificationMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await apiService.markAllNotificationsAsRead();

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final updatedNotifications = currentState.notifications.map((notif) {
          return NotificationModel(
            id: notif.id,
            recipient: notif.recipient,
            sender: notif.sender,
            type: notif.type,
            message: notif.message,
            post: notif.post,
            comment: notif.comment,
            story: notif.story,
            isRead: true,
            createdAt: notif.createdAt,
          );
        }).toList();

        emit(
          currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          ),
        );
      }

      // REMOVED: emit(NotificationAllMarkedAsRead());
      // This was causing the state to be overwritten
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onNotificationAdd(
    NotificationAdd event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    if (currentState is NotificationLoaded) {
      final notification = NotificationModel.fromJson(event.notification);
      final updatedNotifications = [
        notification,
        ...currentState.notifications,
      ];

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: currentState.unreadCount + 1,
        ),
      );
    }
  }
}