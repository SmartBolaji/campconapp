import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primaryBackground;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;
  final Color border;
  final Color buttonBorder;

  const AppColorsExtension({
    required this.primaryBackground,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
    required this.border,
    required this.buttonBorder,
  });

  @override
  AppColorsExtension copyWith({
    Color? primaryBackground,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textLight,
    Color? border,
    Color? buttonBorder,
  }) {
    return AppColorsExtension(
      primaryBackground: primaryBackground ?? this.primaryBackground,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textLight: textLight ?? this.textLight,
      border: border ?? this.border,
      buttonBorder: buttonBorder ?? this.buttonBorder,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      border: Color.lerp(border, other.border, t)!,
      buttonBorder: Color.lerp(buttonBorder, other.buttonBorder, t)!,
    );
  }
}

extension AppThemeContextX on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

extension AppThemeColorSchemeX on ColorScheme {
  AppColorsExtension get appColorsExtension => brightness == Brightness.dark
      ? const AppColorsExtension(
          primaryBackground: AppColors.darkPrimaryBackground,
          background: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          textPrimary: AppColors.darkTextPrimary,
          textSecondary: AppColors.darkTextSecondary,
          textLight: AppColors.darkTextLight,
          border: AppColors.darkBorder,
          buttonBorder: AppColors.darkBorder,
        )
      : const AppColorsExtension(
          primaryBackground: AppColors.lightPrimaryBackground,
          background: AppColors.lightBackground,
          surface: AppColors.lightSurface,
          textPrimary: AppColors.lightTextPrimary,
          textSecondary: AppColors.lightTextSecondary,
          textLight: AppColors.lightTextLight,
          border: AppColors.lightBorder,
          buttonBorder: AppColors.lightBorder,
        );
}

class AppColors {
  // Light Theme Colors
  static const lightPrimary = Color(0xFFEFA101);
  static const lightPrimaryDark = Color(0xFFD89001);
  static const lightPrimaryBackground = Color(0xFFFFE8BA);
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF2C2C2C);
  static const lightTextSecondary = Color(0xFF6B6B6B);
  static const lightTextLight = Color(0xFF9B9B9B);
  static const lightBorder = Color(0xFFE8E8E8);

  // Dark Theme Colors
  static const darkPrimary = Color(0xFFFDB930);
  static const darkPrimaryDark = Color(0xFFEFA101);
  static const darkPrimaryBackground = Color(0xFF2A2209);
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkTextPrimary = Color(0xFFE8E8E8);
  static const darkTextSecondary = Color(0xFFB8B8B8);
  static const darkTextLight = Color(0xFF888888);
  static const darkBorder = Color(0xFF262626);

  // Semantic Colors (Same for both themes but with adjusted opacity)
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);
  static const info = Color(0xFF3498DB);

  // Gradient Colors
  static const lightGradient = LinearGradient(
    colors: [
      Colors.white,
      Color(0xFFEEEEEE),
      Color(0xFFEEEEEE),
      Color(0xFFE1AF4B)
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const darkGradient = LinearGradient(
    colors: [
      Color(0xFF1E1E1E),
      Color(0xFF2A2A2A),
      Color(0xFF2A2A2A),
      Color(0xFF3A3015)
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}

// This is the class you'll use throughout your app
class AppTheme {
  static Brightness get _platformBrightness =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  static bool get isDarkMode => _platformBrightness == Brightness.dark;

  // Primary Colors
  static Color get primary =>
      isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

  static Color get primaryDark =>
      isDarkMode ? AppColors.darkPrimaryDark : AppColors.lightPrimaryDark;

  static Color get primaryBackground => isDarkMode
      ? AppColors.darkPrimaryBackground
      : AppColors.lightPrimaryBackground;

  // Button Colors
  static Color get buttonPrimary =>
      isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

  static Color get buttonText =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  static Color get buttonBorder =>
      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;

  // Background Colors
  static Color get background =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

  static Color get surface =>
      isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

  // Text Colors
  static Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  static Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  static Color get textLight =>
      isDarkMode ? AppColors.darkTextLight : AppColors.lightTextLight;

  // Border
  static Color get border =>
      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;

  // Semantic Colors (same for both themes)
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;
  static const Color info = AppColors.info;
  static const Color white = Color(0xFFFFFFFF);

  // Gradient
  static LinearGradient get gradient =>
      isDarkMode ? AppColors.darkGradient : AppColors.lightGradient;

  // Logo Widget
  static Widget get campconLogo => Container(
        margin: const EdgeInsets.only(top: 23),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Image.asset('assets/images/smallLogo.png'),
            SizedBox(width: 6.sp),
            Text(
              "Campcon",
              style: GoogleFonts.cabin(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );

  // Get ThemeData for MaterialApp
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.lightPrimary,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.lightPrimary,
          secondary: AppColors.lightPrimaryDark,
          surface: AppColors.lightSurface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
          bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
        ),
        extensions: const [
          AppColorsExtension(
            primaryBackground: AppColors.lightPrimaryBackground,
            background: AppColors.lightBackground,
            surface: AppColors.lightSurface,
            textPrimary: AppColors.lightTextPrimary,
            textSecondary: AppColors.lightTextSecondary,
            textLight: AppColors.lightTextLight,
            border: AppColors.lightBorder,
            buttonBorder: AppColors.lightBorder,
          ),
        ],
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.darkPrimary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkPrimaryDark,
          surface: AppColors.darkSurface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
          bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
        ),
        extensions: const [
          AppColorsExtension(
            primaryBackground: AppColors.darkPrimaryBackground,
            background: AppColors.darkBackground,
            surface: AppColors.darkSurface,
            textPrimary: AppColors.darkTextPrimary,
            textSecondary: AppColors.darkTextSecondary,
            textLight: AppColors.darkTextLight,
            border: AppColors.darkBorder,
            buttonBorder: AppColors.darkBorder,
          ),
        ],
      );
}

// Keep the old Constants class for backward compatibility (gradually migrate away from this)
class Constants {
  static Color get primaryDark => AppTheme.primaryDark;
  static Color get primarybackground => AppTheme.primaryBackground;
  static Color get background => AppTheme.background;
  static Color get white => AppTheme.surface;
  static Color get black => AppTheme.textPrimary;
  static Color get textPrimary => AppTheme.textPrimary;
  static Color get textSecondary => AppTheme.textSecondary;
  static Color get textLight => AppTheme.textLight;
  static Color get border => AppTheme.border;
  static const Color success = AppTheme.success;
  static const Color warning = AppTheme.warning;
  static const Color error = AppTheme.error;
  static Color get primaryColors => AppTheme.primary;
  static Color? get backgroundColor => AppTheme.background;
  static LinearGradient get gradientColors => AppTheme.gradient;
  static Widget get campconLogo => AppTheme.campconLogo;
}
