import 'package:flutter/material.dart';
import '../data/models/cinema.dart';
import '../data/config/app_colors.dart';
import '../data/config/app_dimens.dart';
import 'app_badge.dart';
import 'schedule_dialog.dart';

class CinemaCard extends StatelessWidget {
  final Cinema cinema;
  final bool isSelected;
  final bool hasActiveReminder;
  final double? distanceKm;
  final int? durationMinutes;
  final VoidCallback onTap;
  final bool showReminderButton;

  const CinemaCard({
    super.key,
    required this.cinema,
    required this.onTap,
    this.isSelected = false,
    this.hasActiveReminder = false,
    this.distanceKm,
    this.durationMinutes,
    this.showReminderButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel =
        '${cinema.name}, ${cinema.address}. ${distanceKm != null ? "$distanceKm kilometer, " : ""}${durationMinutes != null ? "$durationMinutes menit perjalanan" : ""}${hasActiveReminder ? ", Pengingat aktif" : ""}';

    return Semantics(
      button: true,
      label: semanticLabel,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryYellow : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primaryYellow.withAlpha(60)
                    : const Color(0x0A000000),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const AppBadge(text: 'CINEMA XXI'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cinema.name,
                      style: const TextStyle(
                        fontSize: AppDimens.textMain,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepSlate,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasActiveReminder) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active,
                              size: 12, color: Color(0xFFD97706)),
                          SizedBox(width: 3),
                          Text(
                            'Reminder Active',
                            style: TextStyle(
                              fontSize: AppDimens.captionSmall,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                cinema.address,
                style: const TextStyle(
                  fontSize: AppDimens.captionSmall,
                  color: Color(0xFF475569),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(color: AppColors.surface, height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.near_me,
                          size: 14, color: AppColors.darkTeal),
                      const SizedBox(width: 4),
                      Text(
                        '${distanceKm ?? 0.0} km',
                        style: const TextStyle(
                          fontSize: AppDimens.captionSmall,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.darkTeal),
                      const SizedBox(width: 4),
                      Text(
                        '${durationMinutes ?? 0} mins drive',
                        style: const TextStyle(
                          fontSize: AppDimens.captionSmall,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (showReminderButton) ...[
                const SizedBox(height: AppDimens.buttonSpacing),
                Semantics(
                  button: true,
                  label: 'Atur pengingat jadwal film di ${cinema.name}',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      minimumSize:
                          const Size.fromHeight(AppDimens.buttonHeight),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ScheduleDialog.show(context,
                          initialCinema: cinema.name);
                    },
                    icon: const Icon(
                      Icons.alarm_add_rounded,
                      size: AppDimens.iconSize,
                      color: Color(0xFF0F172A),
                    ),
                    label: const Text(
                      'Set Reminder at this Cinema',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimens.textMain,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
