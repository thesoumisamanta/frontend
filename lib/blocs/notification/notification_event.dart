import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationLoad extends NotificationEvent {
  final bool refresh;

  const NotificationLoad({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllAsRead extends NotificationEvent {
  const NotificationMarkAllAsRead();
}

class NotificationAdd extends NotificationEvent {
  final dynamic notification;

  const NotificationAdd(this.notification);

  @override
  List<Object?> get props => [notification];
}