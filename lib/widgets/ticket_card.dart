import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/reminder.dart';
import '../data/config/app_colors.dart';
import '../data/config/app_dimens.dart';
import 'app_badge.dart';

class TicketCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;

  const TicketCard({
    super.key,
    required this.reminder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCompleted = now.isAfter(reminder.notificationTime);

    final formattedDate =
        DateFormat('EEEE, dd MMM yyyy').format(reminder.scheduledTime);
    final formattedTime =
        DateFormat('HH:mm').format(reminder.scheduledTime);
    final notifTime = reminder.notificationTime;
    final formattedNotifTime = DateFormat('HH:mm').format(notifTime);

    final leadLabel = reminder.leadTimeMinutes == 0
        ? 'On time'
        : '${reminder.leadTimeMinutes}m Before';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? const Color(0xFFE2E8F0) : AppColors.primaryYellow,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? const Color(0x06000000)
                : const Color(0x0F000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFF1F5F9) : AppColors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isCompleted)
                      const AppBadge(
                        text: 'Completed',
                        backgroundColor: Color(0xFF10B981),
                        textColor: Colors.white,
                      )
                    else
                      const AppBadge(text: 'MOVIE REMINDER'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFE2E8F0)
                            : AppColors.teal.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFFCBD5E1)
                              : AppColors.teal.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check
                                : Icons.notifications_active,
                            size: 11,
                            color: isCompleted
                                ? const Color(0xFF059669)
                                : AppColors.teal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted
                                ? 'Triggered at $formattedNotifTime'
                                : leadLabel,
                            style: TextStyle(
                              color: isCompleted
                                  ? const Color(0xFF475569)
                                  : AppColors.darkTeal,
                              fontSize: AppDimens.captionSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    isCompleted ? Icons.delete_outline : Icons.close,
                    size: 18,
                    color: isCompleted
                        ? const Color(0xFF94A3B8)
                        : AppColors.lightSlate,
                  ),
                  tooltip: isCompleted
                      ? 'Delete completed reminder'
                      : 'Cancel reminder',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFECFDF5)
                        : AppColors.primaryYellow.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFFA7F3D0)
                          : AppColors.primaryYellow,
                    ),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.confirmation_number,
                    color: isCompleted
                        ? const Color(0xFF059669)
                        : AppColors.darkTeal,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.movieTitle,
                        style: TextStyle(
                          color: isCompleted
                              ? const Color(0xFF334155)
                              : AppColors.deepSlate,
                          fontSize: AppDimens.textMain,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: isCompleted
                                ? const Color(0xFF94A3B8)
                                : AppColors.teal,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reminder.cinemaName,
                              style: TextStyle(
                                color: isCompleted
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF475569),
                                fontSize: AppDimens.captionSmall,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 14,
                            color: isCompleted
                                ? const Color(0xFF94A3B8)
                                : AppColors.teal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$formattedDate • $formattedTime',
                            style: TextStyle(
                              color: isCompleted
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.slate,
                              fontSize: AppDimens.captionSmall,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
