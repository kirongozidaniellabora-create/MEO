import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Type de diabète (donnée de profil).
enum DiabetesType {
  type1('Diabète de type 1', 'Insuline obligatoire', Icons.vaccines_outlined),
  type2('Diabète de type 2', 'Insuline parfois nécessaire', Icons.medication_outlined),
  other('Autre / non précisé', 'À préciser avec votre médecin', Icons.help_outline);

  const DiabetesType(this.label, this.subtitle, this.icon);

  final String label;
  final String subtitle;
  final IconData icon;

  static DiabetesType fromName(String? name) => DiabetesType.values.firstWhere(
    (t) => t.name == name,
    orElse: () => DiabetesType.type2,
  );
}

/// Objectifs cibles personnalisés (WBS lot 12.1).
/// Toutes les valeurs sont stockées en mg/dL sauf l'HbA1c (%).
class Targets {
  const Targets({
    this.fastingMgdl = 90,
    this.postMealMgdl = 126,
    this.hba1cPercent = 7.0,
    this.tirTargetPercent = 70,
  });

  final double fastingMgdl;
  final double postMealMgdl;
  final double hba1cPercent;

  /// Objectif de temps dans la cible, en % du temps de mesure
  /// (objectif usuel : au moins 70 % des mesures entre 0,70 et 1,80 g/L).
  final double tirTargetPercent;

  Map<String, dynamic> toJson() => {
    'fastingMgdl': fastingMgdl,
    'postMealMgdl': postMealMgdl,
    'hba1cPercent': hba1cPercent,
    'tirTargetPercent': tirTargetPercent,
  };

  factory Targets.fromJson(Map<String, dynamic> j) => Targets(
    fastingMgdl: (j['fastingMgdl'] as num?)?.toDouble() ?? 90,
    postMealMgdl: (j['postMealMgdl'] as num?)?.toDouble() ?? 126,
    hba1cPercent: (j['hba1cPercent'] as num?)?.toDouble() ?? 7.0,
    tirTargetPercent: (j['tirTargetPercent'] as num?)?.toDouble() ?? 70,
  );

  Targets copyWith({
    double? fastingMgdl,
    double? postMealMgdl,
    double? hba1cPercent,
    double? tirTargetPercent,
  }) => Targets(
    fastingMgdl: fastingMgdl ?? this.fastingMgdl,
    postMealMgdl: postMealMgdl ?? this.postMealMgdl,
    hba1cPercent: hba1cPercent ?? this.hba1cPercent,
    tirTargetPercent: tirTargetPercent ?? this.tirTargetPercent,
  );
}

/// Paramètres insuliniques servant aux calculateurs.
class InsulinSettings {
  const InsulinSettings({
    this.dailyPrescribedUnits = 20,
    this.carbRatioGPerUnit = 10,
    this.sensitivityMgdlPerUnit = 50,
  });

  /// Dose totale quotidienne prescrite.
  final double dailyPrescribedUnits;

  /// Ratio insuline / glucides : 1 U pour X g de glucides.
  final double carbRatioGPerUnit;

  /// Sensibilité à l'insuline : 1 U fait baisser la glycémie de X mg/dL.
  final double sensitivityMgdlPerUnit;

  Map<String, dynamic> toJson() => {
    'dailyPrescribedUnits': dailyPrescribedUnits,
    'carbRatioGPerUnit': carbRatioGPerUnit,
    'sensitivityMgdlPerUnit': sensitivityMgdlPerUnit,
  };

  factory InsulinSettings.fromJson(Map<String, dynamic> j) => InsulinSettings(
    dailyPrescribedUnits: (j['dailyPrescribedUnits'] as num?)?.toDouble() ?? 20,
    carbRatioGPerUnit: (j['carbRatioGPerUnit'] as num?)?.toDouble() ?? 10,
    sensitivityMgdlPerUnit: (j['sensitivityMgdlPerUnit'] as num?)?.toDouble() ?? 50,
  );

  InsulinSettings copyWith({
    double? dailyPrescribedUnits,
    double? carbRatioGPerUnit,
    double? sensitivityMgdlPerUnit,
  }) => InsulinSettings(
    dailyPrescribedUnits: dailyPrescribedUnits ?? this.dailyPrescribedUnits,
    carbRatioGPerUnit: carbRatioGPerUnit ?? this.carbRatioGPerUnit,
    sensitivityMgdlPerUnit: sensitivityMgdlPerUnit ?? this.sensitivityMgdlPerUnit,
  );
}

/// Profil de l'utilisateur (WBS lot 12.1).
class Profile {
  const Profile({
    this.displayName = 'Moi',
    this.age = 35,
    this.diabetesType = DiabetesType.type2,
    this.targets = const Targets(),
    this.insulin = const InsulinSettings(),
    this.thresholds = GlucoseThresholds.defaults,
  });

  final String displayName;
  final int age;
  final DiabetesType diabetesType;
  final Targets targets;
  final InsulinSettings insulin;
  final GlucoseThresholds thresholds;

  Profile copyWith({
    String? displayName,
    int? age,
    DiabetesType? diabetesType,
    Targets? targets,
    InsulinSettings? insulin,
    GlucoseThresholds? thresholds,
  }) => Profile(
    displayName: displayName ?? this.displayName,
    age: age ?? this.age,
    diabetesType: diabetesType ?? this.diabetesType,
    targets: targets ?? this.targets,
    insulin: insulin ?? this.insulin,
    thresholds: thresholds ?? this.thresholds,
  );

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'age': age,
    'diabetesType': diabetesType.name,
    'targets': targets.toJson(),
    'insulin': insulin.toJson(),
    'thresholds': thresholds.toJson(),
  };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    displayName: (j['displayName'] as String?) ?? 'Moi',
    age: (j['age'] as num?)?.toInt() ?? 35,
    diabetesType: DiabetesType.fromName(j['diabetesType'] as String?),
    targets: Targets.fromJson(
      (j['targets'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    insulin: InsulinSettings.fromJson(
      (j['insulin'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    thresholds: GlucoseThresholds.fromJson(
      (j['thresholds'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
  );
}
