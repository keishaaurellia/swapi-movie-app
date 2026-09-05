import 'package:flutter/material.dart';
import '../data/config/app_colors.dart';
import '../data/config/app_dimens.dart';
import '../data/config/network_error_helper.dart';

class AppErrorView extends StatelessWidget {
  final dynamic error;
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool isCompact;
  final EdgeInsetsGeometry padding;

  const AppErrorView({
    super.key,
    this.error,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryLabel = 'Coba Lagi',
    this.isCompact = false,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    final info = NetworkErrorHelper.parse(error);
    final displayTitle = title ?? info.title;
    final displayMessage = message ?? info.message;
    final displayIcon = icon ?? info.icon;

    if (isCompact) {
      return Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(displayIcon, size: 28, color: AppColors.error),
            ),
            const SizedBox(height: 10),
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.deepSlate,
                fontWeight: FontWeight.bold,
                fontSize: AppDimens.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.slate,
                fontSize: AppDimens.captionSmall,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(retryLabel),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepSlate,
                  backgroundColor: AppColors.surface,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                displayIcon,
                size: 38,
                color: displayIcon == Icons.wifi_off_rounded
                    ? const Color(0xFFEF4444)
                    : AppColors.deepSlate,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.deepSlate,
                fontSize: AppDimens.titleMain,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: AppDimens.textMain,
                  height: 1.4,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  retryLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimens.textMain,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.deepSlate,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
