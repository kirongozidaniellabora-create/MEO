// Tests de la couche de persistance locale (WBS lot 5.4).
//
// Régression ciblée : au tout premier lancement (aucune donnée enregistrée),
// les fabriques de listes renvoyaient `const []`, une liste NON MODIFIABLE.
// `AppState.load()` faisait ensuite `.sort(...)` dessus et levait
// « Unsupported operation: sort », ce qui bloquait l'application sur l'écran de
// chargement — sur Android comme sur le web.
import 'package:diabtrack/data/local_store.dart';
import 'package:diabtrack/data/models/glucose_reading.dart';
import 'package:diabtrack/data/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Premier lancement sans donnée (régression)', () {
    test('readingsFrom renvoie une liste triable et modifiable', () {
      final list = LocalStore.readingsFrom(null);
      expect(list, isEmpty);
      // Avant le correctif, cette ligne levait Unsupported operation: sort.
      expect(() => list.sort((a, b) => a.dateTime.compareTo(b.dateTime)), returnsNormally);
    });

    test('mealsFrom renvoie une liste triable et modifiable', () {
      final list = LocalStore.mealsFrom(null);
      expect(list, isEmpty);
      expect(() => list.sort((a, b) => a.dateTime.compareTo(b.dateTime)), returnsNormally);
    });

    test('insulinFrom renvoie une liste triable et modifiable', () {
      final list = LocalStore.insulinFrom(null);
      expect(list, isEmpty);
      expect(() => list.sort((a, b) => a.dateTime.compareTo(b.dateTime)), returnsNormally);
    });

    test('hba1cFrom renvoie une liste triable et modifiable', () {
      final list = LocalStore.hba1cFrom(null);
      expect(list, isEmpty);
      expect(() => list.sort((a, b) => a.date.compareTo(b.date)), returnsNormally);
    });

    test('une clé présente mais vide donne aussi une liste modifiable', () {
      final data = <String, dynamic>{
        'readings': <dynamic>[],
        'meals': <dynamic>[],
        'insulinEntries': <dynamic>[],
        'hba1c': <dynamic>[],
      };
      expect(() => LocalStore.readingsFrom(data).sort((a, b) => a.dateTime.compareTo(b.dateTime)),
          returnsNormally);
      expect(() => LocalStore.mealsFrom(data).sort((a, b) => a.dateTime.compareTo(b.dateTime)),
          returnsNormally);
      expect(() => LocalStore.insulinFrom(data).sort((a, b) => a.dateTime.compareTo(b.dateTime)),
          returnsNormally);
      expect(() => LocalStore.hba1cFrom(data).sort((a, b) => a.date.compareTo(b.date)),
          returnsNormally);
    });

    test('profileFrom(null) et onboardingDone(null) ne plantent pas', () {
      expect(LocalStore.profileFrom(null), isA<Profile>());
      expect(LocalStore.onboardingDone(null), isFalse);
    });
  });

  group('Données illisibles', () {
    test('une entrée corrompue est ignorée sans perdre les autres', () {
      final data = <String, dynamic>{
        'readings': [
          <String, dynamic>{
            'id': 'ok1',
            'dateTime': DateTime(2026, 10, 1, 8).toIso8601String(),
            'valueMgdl': 120,
          },
          'pas une map',
          <String, dynamic>{'id': 'casse', 'valueMgdl': 'abc'},
        ],
      };
      final list = LocalStore.readingsFrom(data);
      expect(list.length, 1);
      expect(list.first.id, 'ok1');
    });

    test('un type de donnée inattendu ne plante pas', () {
      final data = <String, dynamic>{
        'readings': 'pas une liste',
        'profile': 42,
      };
      expect(LocalStore.readingsFrom(data), isEmpty);
      expect(LocalStore.profileFrom(data), isA<Profile>());
    });
  });

  group('Lecture de données valides', () {
    test('les mesures sont relues et restent triables', () {
      final source = GlucoseReading(
        id: 'a',
        dateTime: DateTime(2026, 10, 2, 9),
        valueMgdl: 150,
      );
      final data = <String, dynamic>{
        'readings': [source.toJson()],
      };
      final list = LocalStore.readingsFrom(data);
      expect(list.single.valueMgdl, 150);
      expect(() => list.sort((a, b) => a.dateTime.compareTo(b.dateTime)), returnsNormally);
    });

    test('les repas et injections sont relus', () {
      final data = <String, dynamic>{
        'meals': [
          {
            'id': 'm1',
            'dateTime': DateTime(2026, 10, 1, 12).toIso8601String(),
            'description': 'Dejeuner',
          },
        ],
        'insulinEntries': [
          {
            'id': 'i1',
            'dateTime': DateTime(2026, 10, 1, 12).toIso8601String(),
            'units': 6,
          },
        ],
        'hba1c': [
          {
            'id': 'h1',
            'date': DateTime(2026, 9, 1).toIso8601String(),
            'valuePercent': 6.8,
          },
        ],
      };
      expect(LocalStore.mealsFrom(data).single.description, 'Dejeuner');
      expect(LocalStore.insulinFrom(data).single.units, 6);
      expect(LocalStore.hba1cFrom(data).single.valuePercent, closeTo(6.8, 0.001));
    });
  });
}