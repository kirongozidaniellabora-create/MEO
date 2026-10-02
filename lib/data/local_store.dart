import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/glucose_reading.dart';
import 'models/insulin_meal_hba1c.dart';
import 'models/profile.dart';

/// Persistance **locale** des données (WBS lot 4.3).
///
/// Choix d'architecture conforme au risque R5 : un unique document JSON versionné, stocké dans
/// les préférences de l'application. **Aucun appel réseau, aucun serveur, aucune dépendance
/// externe** : les données de santé ne quittent jamais l'appareil.
class LocalStore {
  LocalStore(this._prefs);

  static const _key = 'diabtrack.data.v1';
  static const schemaVersion = 1;

  final SharedPreferences _prefs;

  static Future<LocalStore> open() async =>
      LocalStore(await SharedPreferences.getInstance());

  // ---------------------------------------------------------------- lecture

  String? get raw => _prefs.getString(_key);

  Map<String, dynamic>? readAll() {
    final data = raw;
    if (data == null || data.isEmpty) return null;
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } on FormatException {
      // Données corrompues : on ne perd pas la session, on repart d'un état vierge
      // (l'export JSON permet à l'utilisateur de conserver une trace).
      return null;
    }
  }

  // ---------------------------------------------------------------- écriture

  Future<void> writeAll(Map<String, dynamic> data) async {
    data['schemaVersion'] = schemaVersion;
    data['savedAt'] = DateTime.now().toIso8601String();
    await _prefs.setString(_key, jsonEncode(data));
  }

  Future<void> clear() => _prefs.remove(_key);

  // ---------------------------------------------------------------- sérialisation

  static List<GlucoseReading> readingsFrom(Map<String, dynamic>? data) {
    final list = data?['readings'];
    if (list is! List) return <GlucoseReading>[];
    final out = <GlucoseReading>[];
    for (final e in list) {
      if (e is Map) {
        try {
          out.add(GlucoseReading.fromJson(e.cast<String, dynamic>()));
        } on Object {
          // Ignore une entrée illisible plutôt que de perdre tout l'historique.
        }
      }
    }
    return out;
  }

  static List<Meal> mealsFrom(Map<String, dynamic>? data) {
    final list = data?['meals'];
    if (list is! List) return <Meal>[];
    final out = <Meal>[];
    for (final e in list) {
      if (e is Map) {
        try {
          out.add(Meal.fromJson(e.cast<String, dynamic>()));
        } on Object {
          // idem
        }
      }
    }
    return out;
  }

  static List<InsulinEntry> insulinFrom(Map<String, dynamic>? data) {
    final list = data?['insulinEntries'];
    if (list is! List) return <InsulinEntry>[];
    final out = <InsulinEntry>[];
    for (final e in list) {
      if (e is Map) {
        try {
          out.add(InsulinEntry.fromJson(e.cast<String, dynamic>()));
        } on Object {
          // idem
        }
      }
    }
    return out;
  }

  static List<Hba1cRecord> hba1cFrom(Map<String, dynamic>? data) {
    final list = data?['hba1c'];
    if (list is! List) return <Hba1cRecord>[];
    final out = <Hba1cRecord>[];
    for (final e in list) {
      if (e is Map) {
        try {
          out.add(Hba1cRecord.fromJson(e.cast<String, dynamic>()));
        } on Object {
          // idem
        }
      }
    }
    return out;
  }

  static Profile profileFrom(Map<String, dynamic>? data) {
    final p = data?['profile'];
    if (p is! Map) return const Profile();
    return Profile.fromJson(p.cast<String, dynamic>());
  }

  static bool onboardingDone(Map<String, dynamic>? data) => data?['onboardingDone'] == true;

  /// Export lisible par un humain (partage de données avec le médecin).
  static String exportJson({
    required Profile profile,
    required List<GlucoseReading> readings,
    required List<Meal> meals,
    required List<InsulinEntry> insulinEntries,
    required List<Hba1cRecord> hba1c,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'application': 'DiabTrack',
      'version': '1.0.0',
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'unite': 'glycémie en mg/dL (1 g/L = 100 mg/dL)',
      'profile': profile.toJson(),
      'readings': readings.map((e) => e.toJson()).toList(),
      'meals': meals.map((e) => e.toJson()).toList(),
      'insulinEntries': insulinEntries.map((e) => e.toJson()).toList(),
      'hba1c': hba1c.map((e) => e.toJson()).toList(),
    });
  }
}
