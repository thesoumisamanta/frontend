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
      if (event.refresh) {
        emit(NotificationLoading());
      }

      final currentState = state;
      int page = 1;
      List<NotificationModel> currentNotifications = [];

      if (currentState is NotificationLoaded && !event.refresh) {
        page = currentState.currentPage + 1;
        currentNotifications = currentState.notifications;
      }

      final response = await apiService.getNotifications(
        page: page,
        limit: 20,
      );

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

        emit(NotificationLoaded(
          notifications: allNotifications,
          unreadCount: unreadCount,
          hasMore: hasMore,
          currentPage: page,
        ));
      } else {
        emit(NotificationError(
            response['message'] ?? 'Failed to load notifications'));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
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

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        ));
      }

      emit(NotificationMarkedAsRead(event.notificationId));
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

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      }

      emit(NotificationAllMarkedAsRead());
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
      final updatedNotifications = [notification, ...currentState.notifications];

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: currentState.unreadCount + 1,
      ));
    }
  }
}