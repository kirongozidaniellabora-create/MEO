/// Modèle de domaine et utilitaires de conversion d'unités.
///
/// Règle du projet (cf. docs/04-cycle-de-vie-et-conception.md § 5.4) :
/// **la glycémie est stockée en mg/dL** (entier, unité internationale) et
/// **affichée en g/L** avec une décimale. 1 g/L = 100 mg/dL.
library;

/// Conversion mg/dL -> g/L.
double mgdlToGl(double mgdl) => mgdl / 100.0;

/// Conversion g/L -> mg/dL.
double glToMgdl(double gl) => gl * 100.0;

/// Formate une glycémie stockée en mg/dL pour l'affichage en g/L.
String formatGl(double mgdl, {bool withUnit = true}) {
  final gl = mgdlToGl(mgdl);
  final text = gl.toStringAsFixed(gl.truncateToDouble() == gl ? 0 : 2);
  return withUnit ? '$text g/L' : text;
}

/// Formate une dose d'insuline (unité, entier ou demi-unité).
String formatUnits(double units) {
  final text = units == units.roundToDouble()
      ? units.toStringAsFixed(0)
      : units.toStringAsFixed(1);
  return '$text U';
}

/// Formate une durée en heures décimales vers « 7 h 30 ».
String formatHours(double hours) {
  final h = hours.floor();
  final m = ((hours - h) * 60).round();
  if (h == 0 && m == 0) return '0 h';
  if (m == 0) return '$h h';
  return '$h h ${m.toString().padLeft(2, '0')}';
}

/// Arrondi d'un pourcentage à l'entier.
int formatPercent(double ratio) => (ratio * 100).round();

/// Deux décimales, sans notation scientifique.
String fixed2(double v) => v.toStringAsFixed(2);
