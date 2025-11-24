import 'package:campcon/main/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TextConstants {
  static TextStyle boldText = GoogleFonts.cabin(
    fontWeight: FontWeight.w700,
    fontSize: 28.sp,
    color: Constants.textPrimary,
  );
  static TextStyle mediumText = GoogleFonts.cabin(
    fontWeight: FontWeight.w300,
    fontSize: 20.sp,
    color: Constants.textPrimary,
  );
  static TextStyle smallText = GoogleFonts.cabin(
    fontSize: 14.sp,
    color: Constants.textPrimary,
  );
}
