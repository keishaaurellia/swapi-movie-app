part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {}

class AddReminderEvent extends ReminderEvent {
  final Reminder reminder;
  const AddReminderEvent(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class DeleteReminderEvent extends ReminderEvent {
  final String id;
  const DeleteReminderEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class TriggerTestNotificationEvent extends ReminderEvent {
  final int seconds;
  const TriggerTestNotificationEvent({this.seconds = 5});

  @override
  List<Object?> get props => [seconds];
}
