import 'package:equatable/equatable.dart';
import 'package:cinemax_app/bloc/export.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderProvider reminderProvider;

  ReminderBloc(this.reminderProvider) : super(ReminderInitial()) {
    on<LoadReminders>((event, emit) async {
      emit(ReminderLoading());
      try {
        final list = await reminderProvider.getReminders();
        emit(ReminderLoaded(list));
      } catch (e) {
        emit(ReminderError(e.toString()));
      }
    });

    on<AddReminderEvent>((event, emit) async {
      try {
        await reminderProvider.addReminder(event.reminder);
        await reminderProvider.showInstantConfirmation(
          event.reminder.movieTitle,
          event.reminder.cinemaName,
        );
        eventBus.fire(ReminderCreatedEvent(event.reminder));
        final list = await reminderProvider.getReminders();
        emit(ReminderLoaded(list));
      } catch (e) {
        emit(ReminderError(e.toString()));
      }
    });

    on<DeleteReminderEvent>((event, emit) async {
      try {
        await reminderProvider.deleteReminder(event.id);
        eventBus.fire(ReminderDeletedEvent(event.id));
        final list = await reminderProvider.getReminders();
        emit(ReminderLoaded(list));
      } catch (e) {
        emit(ReminderError(e.toString()));
      }
    });

    on<TriggerTestNotificationEvent>((event, emit) async {
      await reminderProvider.sendTestNotification(secondsDelay: event.seconds);
    });
  }
}
