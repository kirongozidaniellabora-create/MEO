import 'package:flutter/material.dart';

import '../../core/units.dart';

/// Contexte d'une mesure de glycémie (WBS lot 5.1).
enum MeasureContext {
  fasting('À jeun', Icons.wb_twilight_outlined),
  beforeMeal('Avant repas', Icons.restaurant_outlined),
  afterMeal('Après repas', Icons.restaurant),
  bedtime('Au coucher', Icons.bedtime_outlined),
  beforeSport('Avant effort', Icons.directions_run),
  afterSport('Après effort', Icons.fitness_center),
  other('Autre', Icons.help_outline);

  const MeasureContext(this.label, this.icon);

  final String label;
  final IconData icon;

  static MeasureContext fromName(String? name) => MeasureContext.values.firstWhere(
    (c) => c.name == name,
    orElse: () => MeasureContext.other,
  );
}

/// Une mesure de glycémie. Stockage en mg/dL.
class GlucoseReading {
  GlucoseReading({
    required this.id,
    required this.dateTime,
    required this.valueMgdl,
    this.context = MeasureContext.other,
    this.mealId,
    this.exerciseMinutes = 0,
    this.sleepHours,
    this.stressLevel = 0,
    this.note = '',
    this.tags = const <String>[],
  });

  final String id;
  final DateTime dateTime;

  /// Valeur en **mg/dL**.
  final double valueMgdl;
  final MeasureContext context;
  final String? mealId;
  final int exerciseMinutes;
  final double? sleepHours;

  /// 0 = aucun, 1 = léger, 2 = modéré, 3 = fort.
  final int stressLevel;
  final String note;
  final List<String> tags;

  double get valueGl => mgdlToGl(valueMgdl);

  GlucoseReading copyWith({
    DateTime? dateTime,
    double? valueMgdl,
    MeasureContext? context,
    String? mealId,
    bool clearMeal = false,
    int? exerciseMinutes,
    double? sleepHours,
    bool clearSleep = false,
    int? stressLevel,
    String? note,
    List<String>? tags,
  }) {
    return GlucoseReading(
      id: id,
      dateTime: dateTime ?? this.dateTime,
      valueMgdl: valueMgdl ?? this.valueMgdl,
      context: context ?? this.context,
      mealId: clearMeal ? null : (mealId ?? this.mealId),
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      sleepHours: clearSleep ? null : (sleepHours ?? this.sleepHours),
      stressLevel: stressLevel ?? this.stressLevel,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'valueMgdl': valueMgdl,
    'context': context.name,
    'mealId': mealId,
    'exerciseMinutes': exerciseMinutes,
    'sleepHours': sleepHours,
    'stressLevel': stressLevel,
    'note': note,
    'tags': tags,
  };

  factory GlucoseReading.fromJson(Map<String, dynamic> j) => GlucoseReading(
    id: j['id'] as String,
    dateTime: DateTime.parse(j['dateTime'] as String),
    valueMgdl: (j['valueMgdl'] as num).toDouble(),
    context: MeasureContext.fromName(j['context'] as String?),
    mealId: j['mealId'] as String?,
    exerciseMinutes: (j['exerciseMinutes'] as num?)?.toInt() ?? 0,
    sleepHours: (j['sleepHours'] as num?)?.toDouble(),
    stressLevel: (j['stressLevel'] as num?)?.toInt() ?? 0,
    note: (j['note'] as String?) ?? '',
    tags:
        (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
  );
}
