import 'package:event_bus/event_bus.dart';
import '../data/models/cinema.dart';
import '../data/models/reminder.dart';

final EventBus eventBus = EventBus();

class CinemaSelectedEvent {
  final Cinema cinema;
  const CinemaSelectedEvent(this.cinema);
}

class ReminderCreatedEvent {
  final Reminder reminder;
  const ReminderCreatedEvent(this.reminder);
}

class ReminderDeletedEvent {
  final String reminderId;
  const ReminderDeletedEvent(this.reminderId);
}
