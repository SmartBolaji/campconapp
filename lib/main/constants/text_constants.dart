import 'package:campcon/main/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TextConstants {
  static TextStyle get boldText => GoogleFonts.cabin(
        fontWeight: FontWeight.w700,
        fontSize: 28.sp,
        color: AppTheme.textPrimary,
      );

  static TextStyle get mediumText => GoogleFonts.cabin(
        fontWeight: FontWeight.w300,
        fontSize: 20.sp,
        color: AppTheme.textPrimary,
      );

  static TextStyle get smallText => GoogleFonts.cabin(
        fontSize: 14.sp,
        color: AppTheme.textPrimary,
      );

  static TextStyle bold(BuildContext context) => GoogleFonts.cabin(
        fontWeight: FontWeight.w700,
        fontSize: 28.sp,
        color: context.appColors.textPrimary,
      );

  static TextStyle medium(BuildContext context) => GoogleFonts.cabin(
        fontWeight: FontWeight.w300,
        fontSize: 20.sp,
        color: context.appColors.textPrimary,
      );

  static TextStyle small(BuildContext context) => GoogleFonts.cabin(
        fontSize: 14.sp,
        color: context.appColors.textPrimary,
      );
}
