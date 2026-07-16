import 'package:flutter/material.dart';

/// Design tokens. Grayscale UI with a single lime brand accent.
///
/// ⚠️ DESIGNER: [brand] / [brandInk] are PLACEHOLDER approximations of the
/// BodyPark brand green — replace with the real brand values (and their
/// on-light variant) before shipping.
class Wm {
  Wm._();

  // Brand accent (placeholder).
  static const Color brand = Color(0xFF7CC00C);
  static const Color brandInk = Color(0xFF4F7D05);
  static const Color brandTint = Color(0xFFEEF7DF); // selected icon background

  // Neutrals (slight cool bias).
  static const Color ink = Color(0xFF16181A);
  static const Color ink2 = Color(0xFF6A6F74);
  static const Color ink3 = Color(0xFF9BA0A5);
  static const Color line = Color(0xFFE8E9E5);
  static const Color hair = Color(0xFFF0F1ED);
  static const Color card = Color(0xFFFFFFFF);
  static const Color sheet = Color(0xFFFFFFFF);
  static const Color iconBg = Color(0xFFF2F3EF);
  static const Color lockedBg = Color(0xFFFAFBF8);

  // CTA.
  static const Color cta = Color(0xFF141414);
  static const Color ctaOff = Color(0xFFC9CDC6);

  // Plus / membership marker — GREEN system (placeholder; final asset from the
  // brand designer). Amber is reserved for caution/warning only.
  static const Color plus = Color(0xFF4F7D05);
  static const Color plusBg = Color(0xFFEEF7DF);
  static const Color plusLine = Color(0xFFD6ECB3);

  // Beta caution (functional amber).
  static const Color caution = Color(0xFF9A7212);
  static const Color cautionBg = Color(0xFFFAF6EA);
  static const Color cautionLine = Color(0xFFEFE6CD);

  // Blocking warning (offline etc.).
  static const Color warn = Color(0xFFB5451B);
  static const Color warnBg = Color(0xFFFCECE3);
  static const Color warnLine = Color(0xFFF1CFBD);

  // ATOM round device (OLED black).
  static const Color deviceBg = Color(0xFF000000);
  static const Color deviceCard = Color(0xFF151614);
  static const Color deviceCardLine = Color(0xFF2A2C28);
  static const Color deviceText = Color(0xFFF2F4EF);
  static const Color deviceSub = Color(0xFF8B918A);

  static const double radiusCard = 15;
  static const double radiusSheet = 26;
}

/// Motion tokens — one place to tune the phone-side micro-animations.
/// Durations sit in the 150–240ms iOS/Material sweet spot; easing is standard.
/// (ATOM round-screen motion lives on the C firmware, not here.)
class WmMotion {
  WmMotion._();

  static const Duration fast = Duration(milliseconds: 150); // press / small state
  static const Duration base = Duration(milliseconds: 220); // expand / settle
  static const Curve curve = Curves.easeOutCubic; // ≈ cubic-bezier(.22,.61,.36,1)
  static const Curve expand = Curves.easeOut; // height / size grow

  static const double pressScale = 0.98; // button tap-down scale
}
