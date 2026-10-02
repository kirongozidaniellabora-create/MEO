import 'package:flutter/material.dart';

/// Charte graphique du projet (cf. WBS lot 3.3).
///
/// Règle d'accessibilité : aucune information n'est portée par la couleur seule.
/// Chaque statut de glycémie est toujours accompagné d'un libellé texte **et** d'une icône,
/// afin de rester lisible en cas de daltonisme.
class AppColors {
  const AppColors._();

  // Statuts glycémiques
  static const hypoglycemia = Color(0xFFD32F2F); // rouge
  static const low = Color(0xFFF57C00); // orange
  static const inRange = Color(0xFF2E7D32); // vert
  static const high = Color(0xFFF57C00); // orange
  static const hyperglycemia = Color(0xFFC62828); // rouge foncé
  static const unknown = Color(0xFF9E9E9E); // gris

  // Accents de l'application
  static const primary = Color(0xFF00695C); // teal foncé
  static const primaryLight = Color(0xFF26A69A);
  static const secondary = Color(0xFF3949AB); // indigo
  static const surface = Color(0xFFF6F8F8);
  static const ink = Color(0xFF10231F);

  static const insulin = Color(0xFF00838F);
  static const carbs = Color(0xFFEF6C00);
  static const hba1c = Color(0xFF6A1B9A);
}

/// Seuils de statut, exprimés en mg/dL.
/// Un utilisateur peut les personnaliser (cf. Objectifs cibles), ces valeurs sont les valeurs
/// par défaut correspondant aux recommandations usuelles pour un adulte non diabétique.
class GlucoseThresholds {
  const GlucoseThresholds({
    required this.hypoLimit,
    required this.lowLimit,
    required this.targetLow,
    required this.targetHigh,
    required this.highLimit,
    required this.hyperLimit,
  });

  final double hypoLimit;
  final double lowLimit;
  final double targetLow;
  final double targetHigh;
  final double highLimit;
  final double hyperLimit;

  static const defaults = GlucoseThresholds(
    hypoLimit: 70,
    lowLimit: 90,
    targetLow: 90,
    targetHigh: 180,
    highLimit: 250,
    hyperLimit: 250,
  );

  Map<String, dynamic> toJson() => {
    'hypoLimit': hypoLimit,
    'lowLimit': lowLimit,
    'targetLow': targetLow,
    'targetHigh': targetHigh,
    'highLimit': highLimit,
    'hyperLimit': hyperLimit,
  };

  factory GlucoseThresholds.fromJson(Map<String, dynamic> j) => GlucoseThresholds(
    hypoLimit: (j['hypoLimit'] as num?)?.toDouble() ?? defaults.hypoLimit,
    lowLimit: (j['lowLimit'] as num?)?.toDouble() ?? defaults.lowLimit,
    targetLow: (j['targetLow'] as num?)?.toDouble() ?? defaults.targetLow,
    targetHigh: (j['targetHigh'] as num?)?.toDouble() ?? defaults.targetHigh,
    highLimit: (j['highLimit'] as num?)?.toDouble() ?? defaults.highLimit,
    hyperLimit: (j['hyperLimit'] as num?)?.toDouble() ?? defaults.hyperLimit,
  );
}

/// Thème Material 3 de l'application.
ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
      ).copyWith(
        surface: Colors.white,
        surfaceContainerHighest: const Color(0xFFE8EFED),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2EAE8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      elevation: 8,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE2EAE8), space: 1),
  );
}
