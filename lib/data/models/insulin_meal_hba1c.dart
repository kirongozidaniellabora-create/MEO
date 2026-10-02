import 'package:flutter/material.dart';

/// Type de repas (WBS lot 8.1).
enum MealType {
  breakfast('Petit-déjeuner', Icons.free_breakfast_outlined),
  lunch('Déjeuner', Icons.lunch_dining_outlined),
  snack('Collation', Icons.cookie_outlined),
  dinner('Dîner', Icons.dinner_dining_outlined),
  supper('Dîner tardif', Icons.nightlight_outlined),
  other('Autre', Icons.fastfood_outlined);

  const MealType(this.label, this.icon);

  final String label;
  final IconData icon;

  static MealType fromName(String? name) => MealType.values.firstWhere(
    (m) => m.name == name,
    orElse: () => MealType.other,
  );
}

/// Un repas et sa teneur en glucides (rapidement assimilables + total).
class Meal {
  Meal({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.carbsG,
    this.quickCarbsG = 0,
    this.description = '',
  });

  final String id;
  final DateTime dateTime;
  final MealType type;

  /// Total des glucides en grammes.
  final double carbsG;

  /// Partie « sucres rapides » (raisons, soda, confiserie) — utile pour anticiper un pic.
  final double quickCarbsG;
  final String description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'type': type.name,
    'carbsG': carbsG,
    'quickCarbsG': quickCarbsG,
    'description': description,
  };

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
    id: j['id'] as String,
    dateTime: DateTime.parse(j['dateTime'] as String),
    type: MealType.fromName(j['type'] as String?),
    carbsG: (j['carbsG'] as num?)?.toDouble() ?? 0,
    quickCarbsG: (j['quickCarbsG'] as num?)?.toDouble() ?? 0,
    description: (j['description'] as String?) ?? '',
  );
}

/// Nature de l'insuline injectée (WBS lot 7.1).
enum InsulinKind {
  basal('Basal ( lente)', Icons.schedule),
  bolus('Bolus (rapide)', Icons.bolt);

  const InsulinKind(this.label, this.icon);

  final String label;
  final IconData icon;

  static InsulinKind fromName(String? name) => InsulinKind.values.firstWhere(
    (k) => k.name == name,
    orElse: () => InsulinKind.bolus,
  );
}

/// Une injection d'insuline.
class InsulinEntry {
  InsulinEntry({
    required this.id,
    required this.dateTime,
    required this.kind,
    required this.units,
    this.productName = '',
    this.mealId,
    this.isCorrection = false,
    this.penLot = '',
    this.note = '',
  });

  final String id;
  final DateTime dateTime;
  final InsulinKind kind;
  final double units;
  final String productName;
  final String? mealId;

  /// Vrai si la dose a été calculée pour corriger une hyperglycémie.
  final bool isCorrection;
  final String penLot;
  final String note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'kind': kind.name,
    'units': units,
    'productName': productName,
    'mealId': mealId,
    'isCorrection': isCorrection,
    'penLot': penLot,
    'note': note,
  };

  factory InsulinEntry.fromJson(Map<String, dynamic> j) => InsulinEntry(
    id: j['id'] as String,
    dateTime: DateTime.parse(j['dateTime'] as String),
    kind: InsulinKind.fromName(j['kind'] as String?),
    units: (j['units'] as num).toDouble(),
    productName: (j['productName'] as String?) ?? '',
    mealId: j['mealId'] as String?,
    isCorrection: (j['isCorrection'] as bool?) ?? false,
    penLot: (j['penLot'] as String?) ?? '',
    note: (j['note'] as String?) ?? '',
  );
}

/// Résultat d'analyse d'HbA1c (WBS lot 9.4).
class Hba1cRecord {
  Hba1cRecord({
    required this.id,
    required this.date,
    required this.valuePercent,
    this.labName = '',
    this.note = '',
  });

  final String id;
  final DateTime date;
  final double valuePercent;
  final String labName;
  final String note;

  /// Plausible : 4 % (anémie) à 20 % (très déséquilibré).
  bool get isPlausible => valuePercent >= 3.5 && valuePercent <= 20;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'valuePercent': valuePercent,
    'labName': labName,
    'note': note,
  };

  factory Hba1cRecord.fromJson(Map<String, dynamic> j) => Hba1cRecord(
    id: j['id'] as String,
    date: DateTime.parse(j['date'] as String),
    valuePercent: (j['valuePercent'] as num).toDouble(),
    labName: (j['labName'] as String?) ?? '',
    note: (j['note'] as String?) ?? '',
  );
}
