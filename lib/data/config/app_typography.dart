import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle judulUtama = TextStyle(
    fontSize: AppDimens.judulUtama,
    fontWeight: FontWeight.bold,
    color: AppColors.deepSlate,
  );
  static const TextStyle titleMain = judulUtama;

  static const TextStyle teksUtama = TextStyle(
    fontSize: AppDimens.teksUtama,
    fontWeight: FontWeight.normal,
    color: AppColors.deepSlate,
  );
  static const TextStyle textMain = teksUtama;

  static const TextStyle keteranganKecil = TextStyle(
    fontSize: AppDimens.keteranganKecil,
    fontWeight: FontWeight.normal,
    color: AppColors.slate,
  );
  static const TextStyle captionSmall = keteranganKecil;
}
