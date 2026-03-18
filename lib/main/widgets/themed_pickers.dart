import 'package:campcon/main/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provides consistently themed date and time pickers
/// that match the app's Cabin font and AppTheme colors.
class ThemedPickers {
  ThemedPickers._();

  /// Builds a [ThemeData] that styles Material date/time pickers
  /// with the app's Cabin font family and [AppTheme] palette.
  static ThemeData _pickerTheme(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseText = GoogleFonts.cabinTextTheme(
      Theme.of(context).textTheme,
    ).apply(
      bodyColor: appColors.textPrimary,
      displayColor: appColors.textPrimary,
    );

    return Theme.of(context).copyWith(
      colorScheme:
          (isDark ? const ColorScheme.dark() : const ColorScheme.light())
              .copyWith(
        primary: colorScheme.primary,
        onPrimary: colorScheme.onPrimary,
        surface: appColors.surface,
        onSurface: appColors.textPrimary,
        secondary: appColors.primaryBackground,
        onSecondary: appColors.textPrimary,
        outline: appColors.border,
      ),
      textTheme: baseText,
      dialogTheme: DialogThemeData(
        backgroundColor: appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.cabin(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: appColors.surface,
        headerBackgroundColor: colorScheme.primary,
        headerForegroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        dayStyle: GoogleFonts.cabin(
          fontSize: 14,
          color: appColors.textPrimary,
        ),
        weekdayStyle: GoogleFonts.cabin(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: appColors.textSecondary,
        ),
        yearStyle: GoogleFonts.cabin(
          fontSize: 14,
          color: appColors.textPrimary,
        ),
        headerHelpStyle: GoogleFonts.cabin(
          fontSize: 14,
          color: colorScheme.onPrimary.withValues(alpha: 0.9),
        ),
        headerHeadlineStyle: GoogleFonts.cabin(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return colorScheme.onPrimary;
          if (states.contains(WidgetState.disabled)) return appColors.textLight;
          return appColors.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return colorScheme.onPrimary;
          return colorScheme.primary;
        }),
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return Colors.transparent;
        }),
        todayBorder: BorderSide(color: colorScheme.primary, width: 1.5),
        surfaceTintColor: Colors.transparent,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: appColors.background,
          labelStyle: GoogleFonts.cabin(color: appColors.textSecondary),
          hintStyle: GoogleFonts.cabin(color: appColors.textLight),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: appColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        hourMinuteTextStyle: GoogleFonts.cabin(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
        dayPeriodTextStyle: GoogleFonts.cabin(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        helpTextStyle: GoogleFonts.cabin(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: appColors.textSecondary,
        ),
        hourMinuteColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.primaryBackground;
          }
          return appColors.buttonBorder;
        }),
        hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return appColors.textPrimary;
        }),
        dayPeriodColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.primaryBackground;
          }
          return Colors.transparent;
        }),
        dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return appColors.textLight;
        }),
        dayPeriodBorderSide: BorderSide(color: appColors.border),
        dialHandColor: colorScheme.primary,
        dialBackgroundColor: appColors.primaryBackground.withValues(alpha: 0.3),
        dialTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return colorScheme.onPrimary;
          return appColors.textPrimary;
        }),
        entryModeIconColor: appColors.textSecondary,
      ),
    );
  }

  /// Shows a themed date picker that matches the app's design.
  static Future<DateTime?> showDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: _pickerTheme(context),
          child: child!,
        );
      },
    );
  }

  /// Shows a themed time picker that matches the app's design.
  static Future<TimeOfDay?> showTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: _pickerTheme(context),
          child: child!,
        );
      },
    );
  }
}
