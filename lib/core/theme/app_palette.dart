import 'package:flutter/material.dart';

/// Every colour in the app. Nothing else should construct a Color.
class AppColors {
  const AppColors._();

  // ---- Primary: deep teal ----
  static const Color primary = Color(0xFF0F5A5E);
  static const Color primaryDark = Color(0xFF0A4245); // pressed
  static const Color primaryLight = Color(0xFF2C7B7F); // hover, focus ring
  static const Color primaryTint = Color(0xFFE3EEEE); // selected chip bg
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---- Ink: text and structure ----
  static const Color ink = Color(0xFF101826); // headings, body
  static const Color inkSecondary = Color(0xFF4A5261); // labels, meta
  static const Color inkMuted = Color(0xFF7A7469); // hints, timestamps
  static const Color inkDisabled = Color(0xFFA8A399);

  // ---- Ground ----
  static const Color background = Color(0xFFF6F4F1); // warm paper
  static const Color surface = Color(0xFFFFFFFF); // cards, sheets
  static const Color surfaceAlt = Color(0xFFEFECE7); // avatars, empty slots
  static const Color border = Color(0xFFE4E0DA);
  static const Color borderStrong = Color(0xFFD6D1C8); // outlined buttons

  // ---- Semantic: status only, never decoration ----
  static const Color employed = Color(0xFF157F4E);
  static const Color employedTint = Color(0xFFE4F0E9);
  static const Color employedInk = Color(0xFF0E5C39); // text on the tint

  static const Color attention = Color(0xFFA85B00);
  static const Color attentionTint = Color(0xFFF7ECDD);
  static const Color attentionInk = Color(0xFF7A4200);

  static const Color destructive = Color(0xFFB02A22);
  static const Color destructiveTint = Color(0xFFF7E3E1);
  static const Color destructiveInk = Color(0xFF8A1F19);

  /// Unemployed is the default state, so it reads as neutral rather
  /// than as a problem.
  static const Color neutralTint = Color(0xFFEFECE7);
  static const Color neutralInk = Color(0xFF5C574E);
}

/// Spacing, radius and elevation, so magic numbers stay out of widgets.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 10;
  static const double radiusLg = 16;
  static const double radiusPill = 999;
}
