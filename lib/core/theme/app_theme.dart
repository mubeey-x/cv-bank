
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final text = _textTheme(base.textTheme);

    return base.copyWith(
      colorScheme: _scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text,
      primaryTextTheme: text,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ---- Buttons ----
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceAlt,
          disabledForegroundColor: AppColors.inkDisabled,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.borderStrong),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ---- Inputs ----
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 15),
        labelStyle: const TextStyle(
          color: AppColors.inkSecondary,
          fontSize: 14,
        ),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.5),
        errorBorder: _inputBorder(AppColors.destructive),
        focusedErrorBorder: _inputBorder(AppColors.destructive, width: 1.5),
        errorStyle: const TextStyle(
          color: AppColors.destructiveInk,
          fontSize: 12,
        ),
      ),

      // ---- Chips: category and filter selection ----
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryTint,
        checkmarkColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.inkSecondary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),

      // ---- Sheets and dialogs ----
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.border,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),

      // ---- Misc ----
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.inkSecondary,
        textColor: AppColors.ink,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceAlt,
      ),

      splashFactory: InkRipple.splashFactory,
    );
  }

  static const ColorScheme _scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryTint,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.primaryLight,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSecondary,
    surfaceContainerHighest: AppColors.surfaceAlt,
    error: AppColors.destructive,
    onError: AppColors.onPrimary,
    errorContainer: AppColors.destructiveTint,
    onErrorContainer: AppColors.destructiveInk,
    outline: AppColors.border,
    outlineVariant: AppColors.borderStrong,
  );

  /// Three sizes, plus weight for emphasis. Resist adding a fourth.
  static TextTheme _textTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      // Screen titles
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.3,
      ),
      // Section headers, card titles
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.35,
      ),
      // Names in a list
      titleSmall: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
        height: 1.35,
      ),
      // Body
      bodyLarge: const TextStyle(
        fontSize: 15,
        color: AppColors.ink,
        height: 1.5,
      ),
      // Secondary line under a name
      bodyMedium: const TextStyle(
        fontSize: 13,
        color: AppColors.inkMuted,
        height: 1.45,
      ),
      // Badges, timestamps
      bodySmall: const TextStyle(
        fontSize: 12,
        color: AppColors.inkMuted,
        height: 1.4,
      ),
      // The big numbers on the dashboard
      headlineMedium: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Status colours resolved in one place, so no widget decides them.
extension EmploymentColors on bool {
  Color get statusBg => this ? AppColors.employedTint : AppColors.neutralTint;
  Color get statusFg => this ? AppColors.employedInk : AppColors.neutralInk;
  String get statusLabel => this ? 'Employed' : 'Unemployed';
}
