import 'package:flutter/material.dart';
import 'package:cinemax_app/bloc/export.dart';
import 'package:cinemax_app/widgets/export_widgets.dart';

class ReminderScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ReminderScreen({super.key, this.onBack});

  Future<bool?> _showRemoveConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Keep Reminder',
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            cancelLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            confirmLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderB = context.read<ReminderBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: 'Kembali ke halaman sebelumnya',
          child: Container(
            width: AppDimens.buttonSize,
            height: AppDimens.buttonSize,
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: AppDimens.iconSize,
                color: AppColors.deepSlate,
              ),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Cinema Reminders',
          style: TextStyle(
            color: AppColors.deepSlate,
            fontSize: AppDimens.titleMain,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          BlocBuilder<ReminderBloc, ReminderState>(
            bloc: reminderB,
            buildWhen: (prev, curr) {
              if (prev is ReminderLoaded && curr is ReminderLoaded) {
                return prev.reminders.length != curr.reminders.length;
              }
              return prev.runtimeType != curr.runtimeType;
            },
            builder: (context, state) {
              if (state is ReminderLoaded && state.reminders.isNotEmpty) {
                final now = DateTime.now();
                final completedList = state.reminders
                    .where((r) => now.isAfter(r.notificationTime))
                    .toList();
                if (completedList.isNotEmpty) {
                  return IconButton(
                    tooltip: 'Clear finished',
                    icon: const Icon(
                      Icons.playlist_remove,
                      color: AppColors.iconDarkAccent,
                    ),
                    onPressed: () async {
                      final count = completedList.length;
                      final confirmed = await _showRemoveConfirmationDialog(
                        context,
                        title: 'Clear past reminders?',
                        message: count == 1
                            ? 'Remove 1 finished showtime from your history?'
                            : 'Remove all $count finished showtimes from your history?',
                        confirmLabel: 'Clear All',
                        cancelLabel: 'Keep',
                      );
                      if (confirmed == true && context.mounted) {
                        for (final r in completedList) {
                          reminderB.add(DeleteReminderEvent(r.id));
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF0F172A),
                            content: Text(
                              count == 1
                                  ? 'Cleared 1 past reminder.'
                                  : 'Cleared $count past reminders.',
                              style: const TextStyle(fontSize: AppDimens.textMain),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              }
              return const SizedBox();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surface, height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.deepSlate,
        elevation: 2,
        onPressed: () => ScheduleDialog.show(context),
        icon: const Icon(Icons.add_alert, color: AppColors.iconPrimary),
        label: const Text(
          'Set Reminder',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: AppDimens.textMain),
        ),
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        bloc: reminderB..add(LoadReminders()),
        buildWhen: (prev, curr) =>
            prev.runtimeType != curr.runtimeType ||
            (prev is ReminderLoaded &&
                curr is ReminderLoaded &&
                prev.reminders != curr.reminders),
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            );
          } else if (state is ReminderLoaded) {
            if (state.reminders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withAlpha(40),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryYellow,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 48,
                          color: AppColors.iconDarkAccent,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'No upcoming reminders',
                        style: TextStyle(
                          fontSize: AppDimens.titleMain,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pick a movie and cinema to get alerted before the showtime starts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppDimens.textMain,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final now = DateTime.now();
            final sortedReminders = List<Reminder>.from(state.reminders)
              ..sort((a, b) {
                final aDone = now.isAfter(a.notificationTime);
                final bDone = now.isAfter(b.notificationTime);
                if (aDone != bDone) {
                  return aDone ? 1 : -1;
                }
                return a.scheduledTime.compareTo(b.scheduledTime);
              });

            return ListView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 90,
              ),
              itemCount: sortedReminders.length,
              itemBuilder: (context, index) {
                final reminder = sortedReminders[index];
                final isDone = now.isAfter(reminder.notificationTime);
                return TicketCard(
                  reminder: reminder,
                  onDelete: () async {
                    final confirmed = await _showRemoveConfirmationDialog(
                      context,
                      title: isDone ? 'Remove from history?' : 'Cancel reminder?',
                      message: isDone
                          ? 'Remove "${reminder.movieTitle}" from your past reminders?'
                          : 'You won\'t receive alerts or alarm for "${reminder.movieTitle}".',
                      confirmLabel: isDone ? 'Remove' : 'Cancel Reminder',
                      cancelLabel: 'Keep Reminder',
                    );
                    if (confirmed == true && context.mounted) {
                      reminderB.add(DeleteReminderEvent(reminder.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF0F172A),
                          content: Text(
                            isDone
                                ? 'Removed "${reminder.movieTitle}".'
                                : 'Cancelled reminder for "${reminder.movieTitle}".',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppDimens.textMain,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          } else if (state is ReminderError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: AppDimens.textMain,
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
