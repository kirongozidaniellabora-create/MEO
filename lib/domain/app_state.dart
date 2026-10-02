import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../data/models/glucose_reading.dart';
import '../data/models/insulin_meal_hba1c.dart';
import '../data/models/profile.dart';
import '../domain/glucose_logic.dart';

/// État global de l'application (WBS lot 4.4).
///
/// `ChangeNotifier` + `ListenableBuilder` (widget natif Flutter) : permet d'éviter une
/// dépendance supplémentaire, cohérent avec la stratégie de minimisation des risques.
class AppState extends ChangeNotifier {
  AppState(this._store);

  final LocalStore _store;

  Profile _profile = const Profile();
  List<GlucoseReading> _readings = [];
  List<Meal> _meals = [];
  List<InsulinEntry> _insulin = [];
  List<Hba1cRecord> _hba1c = [];
  bool _onboardingDone = false;
  bool _ready = false;
  String? _lastError;

  // ------------------------------------------------------------------ getters

  Profile get profile => _profile;
  List<GlucoseReading> get readings => List.unmodifiable(_readings);
  List<Meal> get meals => List.unmodifiable(_meals);
  List<InsulinEntry> get insulinEntries => List.unmodifiable(_insulin);
  List<Hba1cRecord> get hba1cRecords => List.unmodifiable(_hba1c);
  bool get onboardingDone => _onboardingDone;
  bool get ready => _ready;
  String? get lastError => _lastError;

  /// Dernière mesure enregistrée, la plus récente en premier.
  GlucoseReading? get latest =>
      _readings.isEmpty ? null : _readings.first;

  /// Mesures du jour (00:00 → maintenant), triées par heure croissante.
  List<GlucoseReading> get todayReadings {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final list = _readings.where((r) => !r.dateTime.isBefore(start)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  List<Meal> get todayMeals {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final list = _meals.where((m) => !m.dateTime.isBefore(start)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  List<InsulinEntry> get todayInsulin {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final list = _insulin.where((i) => !i.dateTime.isBefore(start)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  double get todayInsulinTotal =>
      todayInsulin.fold<double>(0, (sum, i) => sum + i.units);

  double get todayCarbsTotal => todayMeals.fold<double>(0, (sum, m) => sum + m.carbsG);

  double get todayAverageMgdl {
    final list = todayReadings;
    if (list.isEmpty) return 0;
    return GlucoseLogic.average(list.map((r) => r.valueMgdl).toList());
  }

  double get todayTimeInRange => GlucoseLogic.timeInRange(todayReadings, _profile.thresholds);

  GlucoseStatus get latestStatus =>
      latest == null ? GlucoseStatus.inRange : GlucoseLogic.status(latest!, _profile);

  /// Mesures des `days` derniers jours (le jour courant inclus).
  /// `days <= 0` signifie « tout l'historique » (filtre « Tout »).
  List<GlucoseReading> readingsLastDays(int days) {
    if (days <= 0) {
      return _readings.where((r) => true).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    final list = _readings.where((r) => !r.dateTime.isBefore(start)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  // ------------------------------------------------------------------ cycle de vie

  /// Charge les données locales au démarrage.
  ///
  /// Ne doit jamais lever : une donnée corrompue ou illisible ne doit pas
  /// laisser l'utilisateur bloqué sur l'écran de chargement. On retombe sur
  /// un profil par défaut et l'utilisateur pourra repartir d'un historique
  /// vierge depuis les paramètres.
  Future<void> load() async {
    try {
      final data = _store.readAll();
      _profile = LocalStore.profileFrom(data);
      _readings = LocalStore.readingsFrom(data).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _meals = LocalStore.mealsFrom(data).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _insulin = LocalStore.insulinFrom(data).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _hba1c = LocalStore.hba1cFrom(data).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _onboardingDone = LocalStore.onboardingDone(data);
    } on Object catch (e, s) {
      debugPrint('DiabTrack : données locales illisibles, démarrage à vide ($e)\n$s');
      _profile = const Profile();
      _readings = [];
      _meals = [];
      _insulin = [];
      _hba1c = [];
      _onboardingDone = false;
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      await _store.writeAll({
        'onboardingDone': _onboardingDone,
        'profile': _profile.toJson(),
        'readings': _readings.map((e) => e.toJson()).toList(),
        'meals': _meals.map((e) => e.toJson()).toList(),
        'insulinEntries': _insulin.map((e) => e.toJson()).toList(),
        'hba1c': _hba1c.map((e) => e.toJson()).toList(),
      });
      _lastError = null;
    } on Object catch (e) {
      _lastError = 'Enregistrement impossible : $e';
    }
    notifyListeners();
  }

  // ------------------------------------------------------------------ modifications

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999).toString().padLeft(4, '0')}';

  /// Enregistre le profil saisi à l'onboarding ET marque l'onboarding comme terminé.
  Future<void> completeOnboarding(Profile p) async {
    _profile = p;
    _onboardingDone = true;
    await _persist();
  }

  Future<void> updateProfile(Profile p) async {
    _profile = p;
    await _persist();
  }

  Future<void> addReading(GlucoseReading r) async {
    _readings = [r, ..._readings]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await _persist();
  }

  Future<void> updateReading(GlucoseReading r) async {
    _readings = [
      for (final e in _readings) if (e.id == r.id) r else e,
    ]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await _persist();
  }

  Future<void> deleteReading(String id) async {
    _readings = _readings.where((r) => r.id != id).toList();
    await _persist();
  }

  /// Duplique une mesure (utile pour gripped plusieurs mesures proches).
  Future<void> duplicateReading(GlucoseReading r) async {
    final copy = GlucoseReading(
      id: _newId(),
      dateTime: DateTime.now(),
      valueMgdl: r.valueMgdl,
      context: r.context,
      note: '',
      tags: const <String>[],
    );
    _readings = [copy, ..._readings];
    await _persist();
  }

  Future<void> addMeal(Meal m) async {
    _meals = [m, ..._meals]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await _persist();
  }

  Future<void> updateMeal(Meal m) async {
    _meals = [for (final e in _meals) if (e.id == m.id) m else e]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await _persist();
  }

  Future<void> deleteMeal(String id) async {
    _meals = _meals.where((m) => m.id != id).toList();
    await _persist();
  }

  Future<void> addInsulin(InsulinEntry e) async {
    _insulin = [e, ..._insulin]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await _persist();
  }

  /// Ajout ou mise à jour selon l'existence de l'entrée.
  Future<void> addOrUpdateInsulin(InsulinEntry e, {required bool isUpdate}) async {
    if (isUpdate) {
      await updateInsulin(e);
    } else {
      await addInsulin(e);
    }
  }

  Future<void> updateInsulin(InsulinEntry e) async {
    _insulin = [for (final x in _insulin) if (x.id == e.id) e else x]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await _persist();
  }

  Future<void> deleteInsulin(String id) async {
    _insulin = _insulin.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> addHba1c(Hba1cRecord r) async {
    _hba1c = [r, ..._hba1c]..sort((a, b) => b.date.compareTo(a.date));
    await _persist();
  }

  Future<void> deleteHba1c(String id) async {
    _hba1c = _hba1c.where((e) => e.id != id).toList();
    await _persist();
  }

  // ------------------------------------------------------------------ données

  String exportJson() => LocalStore.exportJson(
    profile: _profile,
    readings: _readings,
    meals: _meals,
    insulinEntries: _insulin,
    hba1c: _hba1c,
  );

  /// Jeu de démonstration (WBS lot 12.3) : permet d'explorer l'application
  /// avant d'avoir saisi de vraies données.
  Future<void> loadDemoData() async {
    final now = DateTime.now();
    final rng = Random(42);
    final demo = <GlucoseReading>[];
    for (var day = 13; day >= 0; day--) {
      final count = 3 + rng.nextInt(3);
      for (var i = 0; i < count; i++) {
        final base = now.subtract(Duration(days: day));
        final hour = [7, 12, 17, 22][i % 4] + rng.nextInt(2) - 1;
        final when = DateTime(base.year, base.month, base.day, hour.clamp(0, 23), rng.nextInt(60));
        // Simulation grossière d'une journée : creux à jeun, pics après les repas.
        final profile = [95.0, 150.0, 165.0, 140.0][i % 4];
        final noise = (rng.nextDouble() - 0.5) * 70;
        final value = (profile + noise).clamp(55.0, 300.0);
        demo.add(
          GlucoseReading(
            id: 'demo-$day-$i',
            dateTime: when,
            valueMgdl: double.parse(value.toStringAsFixed(1)),
            context: [
              MeasureContext.fasting,
              MeasureContext.afterMeal,
              MeasureContext.afterMeal,
              MeasureContext.bedtime,
            ][i % 4],
            exerciseMinutes: day % 3 == 0 ? 30 : 0,
            stressLevel: rng.nextInt(2),
            tags: const <String>[],
          ),
        );
      }
    }
    _readings = demo..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    _meals = [
      Meal(
        id: 'demo-m1',
        dateTime: DateTime(now.year, now.month, now.day, 7, 30),
        type: MealType.breakfast,
        carbsG: 45,
        quickCarbsG: 12,
        description: 'Pain complet, beurre, confiture, jus d’orange',
      ),
      Meal(
        id: 'demo-m2',
        dateTime: DateTime(now.year, now.month, now.day, 12, 30),
        type: MealType.lunch,
        carbsG: 70,
        quickCarbsG: 0,
        description: 'Pâtes, salade, dessert',
      ),
      Meal(
        id: 'demo-m3',
        dateTime: DateTime(now.year, now.month, now.day, 19, 0),
        type: MealType.dinner,
        carbsG: 40,
        description: 'Soupe, poisson, légumes',
      ),
    ];

    _insulin = [
      InsulinEntry(
        id: 'demo-i1',
        dateTime: DateTime(now.year, now.month, now.day, 7, 0),
        kind: InsulinKind.basal,
        units: 12,
        productName: 'Basal (type glargine)',
      ),
      InsulinEntry(
        id: 'demo-i2',
        dateTime: DateTime(now.year, now.month, now.day, 7, 30),
        kind: InsulinKind.bolus,
        units: 4.5,
        mealId: 'demo-m1',
        productName: 'Rapide (type aspart)',
      ),
      InsulinEntry(
        id: 'demo-i3',
        dateTime: DateTime(now.year, now.month, now.day, 12, 30),
        kind: InsulinKind.bolus,
        units: 7,
        mealId: 'demo-m2',
        productName: 'Rapide (type aspart)',
      ),
    ];

    _hba1c = [
      Hba1cRecord(
        id: 'demo-h1',
        date: now.subtract(const Duration(days: 180)),
        valuePercent: 7.8,
        labName: 'Laboratoire (démonstration)',
      ),
      Hba1cRecord(
        id: 'demo-h2',
        date: now.subtract(const Duration(days: 90)),
        valuePercent: 7.2,
        labName: 'Laboratoire (démonstration)',
      ),
      Hba1cRecord(
        id: 'demo-h3',
        date: now.subtract(const Duration(days: 5)),
        valuePercent: 6.9,
        labName: 'Laboratoire (démonstration)',
      ),
    ];
    await _persist();
  }

  /// Remise à zéro totale (WBS lot 12.3).
  Future<void> resetAll() async {
    _readings = [];
    _meals = [];
    _insulin = [];
    _hba1c = [];
    _profile = const Profile();
    _onboardingDone = false;
    await _store.clear();
    notifyListeners();
  }

  /// Vide les données de suivi mais conserve le profil (utile pour repartir à zéro).
  Future<void> resetDataOnly() async {
    _readings = [];
    _meals = [];
    _insulin = [];
    _hba1c = [];
    _onboardingDone = true;
    await _persist();
  }
}
