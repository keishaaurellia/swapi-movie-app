import 'package:flutter/material.dart';
import '../data/config/app_colors.dart';
import '../data/config/app_dimens.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.primaryYellow,
    this.textColor = AppColors.deepSlate,
    this.fontSize = AppDimens.captionSmall,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withAlpha(80),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
