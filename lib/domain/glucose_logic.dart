import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models/glucose_reading.dart';
import '../data/models/profile.dart';

/// Statut glycémique d'une valeur (WBS lot 3.3 : charte graphique du statut).
///
/// Règle d'accessibilité : le statut porte TOUJOURS trois informations —
/// un libellé texte, une icône et une couleur. Jamais la couleur seule.
enum GlucoseStatus {
  hypoglycemia('Hypoglycémie', 'À corriger immédiatement', Icons.warning_amber_rounded),
  low('Bas', 'Légèrement sous la cible', Icons.south_rounded),
  inRange('Dans la cible', 'Équilibre satisfaisant', Icons.check_circle_outline),
  high('Haut', 'Légèrement au-dessus de la cible', Icons.north_rounded),
  hyperglycemia('Hyperglycémie', 'Contrôle et hydratation', Icons.report_problem_outlined);

  const GlucoseStatus(this.label, this.hint, this.icon);

  final String label;
  final String hint;
  final IconData icon;

  bool get isUrgent => this == GlucoseStatus.hypoglycemia || this == GlucoseStatus.hyperglycemia;
  bool get isAlert => this != GlucoseStatus.inRange;

  Color get color => switch (this) {
    GlucoseStatus.hypoglycemia => AppColors.hypoglycemia,
    GlucoseStatus.low => AppColors.low,
    GlucoseStatus.inRange => AppColors.inRange,
    GlucoseStatus.high => AppColors.high,
    GlucoseStatus.hyperglycemia => AppColors.hyperglycemia,
  };

  static GlucoseStatus fromValue(double mgdl, GlucoseThresholds t) {
    if (mgdl < t.hypoLimit) return GlucoseStatus.hypoglycemia;
    if (mgdl < t.targetLow) return GlucoseStatus.low;
    if (mgdl <= t.targetHigh) return GlucoseStatus.inRange;
    if (mgdl <= t.highLimit) return GlucoseStatus.high;
    return GlucoseStatus.hyperglycemia;
  }
}

/// Fonctions « métier » testables : statut, moyenne, TIR, variabilité.
///
/// Isolées de l'UI pour permettre des tests unitaires (WBS lot 13.2).
class GlucoseLogic {
  const GlucoseLogic._();

  static GlucoseStatus status(GlucoseReading r, Profile p) =>
      GlucoseStatus.fromValue(r.valueMgdl, p.thresholds);

  /// Moyenne simple d'une liste (0 si vide).
  static double average(List<double> values) {
    if (values.isEmpty) return 0;
    var sum = 0.0;
    for (final v in values) {
      sum += v;
    }
    return sum / values.length;
  }

  /// Écart-type d'une population (0 si moins de 2 valeurs).
  static double stdDev(List<double> values) {
    if (values.length < 2) return 0;
    final mean = average(values);
    var acc = 0.0;
    for (final v in values) {
      acc += (v - mean) * (v - mean);
    }
    return _sqrt(acc / values.length);
  }

  /// Coefficient de variation, exprimé en % : 100 × écart-type / moyenne.
  static double coefficientOfVariation(List<double> values) {
    final m = average(values);
    if (m == 0) return 0;
    return stdDev(values) / m * 100;
  }

  /// Moyenne mobile sur `window` mesures.
  static List<double> movingAverage(List<double> values, int window) {
    if (window <= 1) return List<double>.from(values);
    final result = <double>[];
    for (var i = 0; i < values.length; i++) {
      final start = i - window + 1 < 0 ? 0 : i - window + 1;
      final slice = values.sublist(start, i + 1);
      result.add(average(slice));
    }
    return result;
  }

  /// **Temps dans la cible** : proportion de mesures situées dans l'intervalle cible.
  ///
  /// Formule de référence : `(nombre de mesures dans la cible / nombre total de mesures) × 100`.
  /// C'est l'indicateur n° 1 de l'équilibre glycémique.
  ///
  /// La cible provient des seuils du profil ([GlucoseThresholds.targetLow] et
  /// [GlucoseThresholds.targetHigh]) : si le patient modifie ses objectifs dans
  /// les paramètres, l'indicateur suit. Les arguments `low` et `high` ne servent
  /// qu'à surcharger ces valeurs (tests, calculs ponctuels).
  static double timeInRange(
    List<GlucoseReading> readings,
    GlucoseThresholds t, {
    double? low,
    double? high,
  }) {
    if (readings.isEmpty) return 0;
    final lo = low ?? t.targetLow;
    final hi = high ?? t.targetHigh;
    final inRange = readings
        .where((r) => r.valueMgdl >= lo && r.valueMgdl <= hi)
        .length;
    return inRange / readings.length * 100;
  }

  /// Répartition en 5 statuts, en pourcentage du nombre de mesures.
  static Map<GlucoseStatus, double> distribution(
    List<GlucoseReading> readings,
    GlucoseThresholds t,
  ) {
    final out = {for (final s in GlucoseStatus.values) s: 0.0};
    if (readings.isEmpty) return out;
    for (final s in GlucoseStatus.values) {
      out[s] = 0;
    }
    for (final r in readings) {
      final s = GlucoseStatus.fromValue(r.valueMgdl, t);
      out[s] = out[s]! + 1;
    }
    for (final s in GlucoseStatus.values) {
      out[s] = out[s]! / readings.length * 100;
    }
    return out;
  }

  /// Dose de correction proposée, **indicative** et à valider par le soignant.
  ///
  /// `dose = (glycémie − cible) / sensibilité`
  static double correctionDose({
    required double currentMgdl,
    required double targetMgdl,
    required double sensitivityMgdlPerUnit,
    double rounding = 0.5,
  }) {
    if (sensitivityMgdlPerUnit <= 0) return 0;
    final raw = (currentMgdl - targetMgdl) / sensitivityMgdlPerUnit;
    if (raw <= 0) return 0;
    return (raw / rounding).roundToDouble() * rounding;
  }

  /// Insuline nécessaire pour un repas : `glucides / ratio insuline/glucides`.
  static double bolusForCarbs({
    required double carbsG,
    required double carbRatioGPerUnit,
  }) {
    if (carbRatioGPerUnit <= 0) return 0;
    final raw = carbsG / carbRatioGPerUnit;
    return (raw * 2).roundToDouble() / 2; // arrondi au demi-unité
  }

  /// Estimation de l'montée de glycémie après un repas hyperglycémique
  /// (≈ 0,5 g/L par 10 g de glucides, ordre de grandeur usuel — indicatif).
  static double estimatedRiseMgdl(double carbsG) => carbsG * 5;

  static double _sqrt(double v) {
    if (v <= 0) return 0;
    var guess = v;
    for (var i = 0; i < 40; i++) {
      guess = 0.5 * (guess + v / guess);
    }
    return guess;
  }
}
