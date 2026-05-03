import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  FRETE PRO ANTT — Design System
//  Estética: Industrial-Profissional
//  Paleta: Azul escuro + Laranja âmbar + Cinza aço
// ─────────────────────────────────────────────

class AppColors {
  // Primárias
  static const primary      = Color(0xFF0F2D52);   // azul marinho profundo
  static const primaryLight = Color(0xFF1A4A80);
  static const accent       = Color(0xFFE87722);   // laranja caminhão
  static const accentLight  = Color(0xFFFFB347);

  // Superfícies
  static const background   = Color(0xFFF5F4F0);   // off-white quente
  static const surface      = Color(0xFFFFFFFF);
  static const surfaceAlt   = Color(0xFFEEECE6);

  // Texto
  static const textPrimary   = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF5A5A5A);
  static const textHint      = Color(0xFF9E9E9E);

  // Semânticas
  static const success   = Color(0xFF2E7D32);
  static const successBg = Color(0xFFE8F5E9);
  static const warning   = Color(0xFFE65100);
  static const warningBg = Color(0xFFFFF3E0);
  static const danger    = Color(0xFFC62828);
  static const dangerBg  = Color(0xFFFFEBEE);

  // Bordas
  static const border       = Color(0xFFDDDAD0);
  static const borderStrong = Color(0xFFBBB8AE);
}

class AppTextStyles {
  static TextStyle get display => GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w800,
    letterSpacing: -1.2, height: 1.1,
    color: AppColors.textPrimary,
  );
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700,
    letterSpacing: -0.8, height: 1.2,
    color: AppColors.textPrimary,
  );
  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );
  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
    color: AppColors.textPrimary,
  );
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );
  static TextStyle get mono => GoogleFonts.robotoMono(
    fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static TextStyle get piso => GoogleFonts.inter(
    fontSize: 36, fontWeight: FontWeight.w800,
    color: AppColors.success, letterSpacing: -1.5,
  );
}

class AppSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm   = BorderRadius.all(Radius.circular(8));
  static const md   = BorderRadius.all(Radius.circular(12));
  static const lg   = BorderRadius.all(Radius.circular(16));
  static const xl   = BorderRadius.all(Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(999));
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: -0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
        textStyle: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: const OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textHint),
      labelStyle: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600,
        letterSpacing: 0.8, color: AppColors.textSecondary,
      ),
    ),
    cardTheme: const CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lg,
        side: BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.only(bottom: AppSpacing.md),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border, thickness: 0.5,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
    ),
  );
}
