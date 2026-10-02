// Tests unitaires du projet (WBS lot 13.2) — objectif SMART O6.
// Ils ciblent la logique métier pure, séparée de l'interface : c'est ce qui rend
// les calculs (temps dans la cible, doses) vérifiables et fiables.
import 'package:diabtrack/core/theme.dart';
import 'package:diabtrack/core/units.dart';
import 'package:diabtrack/data/models/glucose_reading.dart';
import 'package:diabtrack/domain/glucose_logic.dart';
import 'package:flutter_test/flutter_test.dart';

GlucoseReading reading(double mgdl, {DateTime? at}) => GlucoseReading(
  id: 'r$mgdl',
  dateTime: at ?? DateTime(2026, 10, 1, 8),
  valueMgdl: mgdl,
);

void main() {
  group('Conversions d’unités', () {
    test('1 g/L = 100 mg/dL', () {
      expect(glToMgdl(1.0), 100);
      expect(mgdlToGl(180), 1.8);
    });

    test('affichage en g/L', () {
      expect(formatGl(128), '1.28 g/L');
      expect(formatGl(128, withUnit: false), '1.28');
      expect(formatGl(100), '1 g/L');
    });

    test('affichage des doses d’insuline', () {
      expect(formatUnits(4), '4 U');
      expect(formatUnits(4.5), '4.5 U');
    });
  });

  group('Statut glycémique', () {
    const t = GlucoseThresholds.defaults;

    test('hypoglycémie sous 0,70 g/L', () {
      expect(GlucoseStatus.fromValue(65, t), GlucoseStatus.hypoglycemia);
    });

    test('bas entre 0,70 et 0,90 g/L', () {
      expect(GlucoseStatus.fromValue(80, t), GlucoseStatus.low);
    });

    test('dans la cible entre 0,90 et 1,80 g/L', () {
      expect(GlucoseStatus.fromValue(120, t), GlucoseStatus.inRange);
      expect(GlucoseStatus.fromValue(90, t), GlucoseStatus.inRange);
      expect(GlucoseStatus.fromValue(180, t), GlucoseStatus.inRange);
    });

    test('haut puis hyperglycémie', () {
      expect(GlucoseStatus.fromValue(220, t), GlucoseStatus.high);
      expect(GlucoseStatus.fromValue(300, t), GlucoseStatus.hyperglycemia);
    });

    test('les bornes sont exclusives de façon cohérente', () {
      expect(GlucoseStatus.fromValue(69.9, t), GlucoseStatus.hypoglycemia);
      expect(GlucoseStatus.fromValue(70, t), GlucoseStatus.low);
      expect(GlucoseStatus.fromValue(89.9, t), GlucoseStatus.low);
    });
  });

  group('Statistiques descriptives', () {
    test('moyenne d’une liste vide vaut 0', () {
      expect(GlucoseLogic.average([]), 0);
    });

    test('moyenne', () {
      expect(GlucoseLogic.average([100, 200, 300]), 200);
    });

    test('écart-type nul si valeurs identiques', () {
      expect(GlucoseLogic.stdDev([120, 120, 120]), 0);
    });

    test('écart-type avec une seule valeur vaut 0', () {
      expect(GlucoseLogic.stdDev([120]), 0);
    });

    test('écart-type d’une population symétrique', () {
      final sd = GlucoseLogic.stdDev([100, 200]);
      expect(sd, closeTo(50, 0.001));
    });

    test('moyenne mobile', () {
      final ma = GlucoseLogic.movingAverage([100, 200, 300], 2);
      expect(ma, [100, 150, 250]);
    });
  });

  group('Temps dans la cible (indicateur clé du projet)', () {
    const t = GlucoseThresholds.defaults;

    test('0 % si aucune mesure', () {
      expect(GlucoseLogic.timeInRange([], t), 0);
    });

    test('100 % si toutes les mesures sont dans la cible', () {
      expect(GlucoseLogic.timeInRange([reading(100), reading(150)], t), 100);
    });

    test('50 % si une mesure sur deux est dans la cible', () {
      expect(GlucoseLogic.timeInRange([reading(100), reading(280)], t), 50);
    });

    test('0 % si aucune mesure dans la cible', () {
      expect(GlucoseLogic.timeInRange([reading(50), reading(300)], t), 0);
    });

    test('une série réaliste donne une valeur cohérente', () {
      final list = [reading(60), reading(120), reading(190), reading(210)];
      // Dans la cible : 120 et 190 (190 <= 180 ? non) -> seulement 120 => 25 %
      expect(GlucoseLogic.timeInRange(list, t), 25);
    });

    test('suit les seuils personnalisés du profil (régression)', () {
      // Cible resserrée 1,00-1,40 g/L : 100 et 120 seulement => 2/3.
      const serree = GlucoseThresholds(
        hypoLimit: 70,
        lowLimit: 100,
        targetLow: 100,
        targetHigh: 140,
        highLimit: 250,
        hyperLimit: 250,
      );
      expect(GlucoseLogic.timeInRange([reading(100), reading(120)], serree), 100);
      expect(
        GlucoseLogic.timeInRange([reading(100), reading(120), reading(180)], serree),
        closeTo(66.666, 0.01),
      );
    });

    test('les arguments low/high surchargent la cible du profil', () {
      expect(GlucoseLogic.timeInRange([reading(80)], t, low: 70), 100);
      expect(GlucoseLogic.timeInRange([reading(80)], t), 0);
    });
  });

  group('Répartition en 5 statuts', () {
    const t = GlucoseThresholds.defaults;

    test('les pourcentages totalisent 100 %', () {
      final dist = GlucoseLogic.distribution(
        [reading(60), reading(120), reading(200), reading(320), reading(100)],
        t,
      );
      final sum = dist.values.fold<double>(0, (a, b) => a + b);
      expect(sum, closeTo(100, 0.001));
    });

    test('distribution vide à 0', () {
      final dist = GlucoseLogic.distribution([], t);
      expect(dist.values.every((v) => v == 0), isTrue);
    });
  });

  group('Dose de correction', () {
    test('aucune correction si la glycémie est à la cible', () {
      expect(
        GlucoseLogic.correctionDose(
          currentMgdl: 120,
          targetMgdl: 120,
          sensitivityMgdlPerUnit: 50,
        ),
        0,
      );
    });

    test('correction = (glycémie − cible) ÷ sensibilité, arrondie à 0,5 U', () {
      // (280 - 120) / 50 = 3.2 -> 3.0
      expect(
        GlucoseLogic.correctionDose(
          currentMgdl: 280,
          targetMgdl: 120,
          sensitivityMgdlPerUnit: 50,
        ),
        3.0,
      );
      // (250 - 120) / 40 = 3.25 -> 3.5
      expect(
        GlucoseLogic.correctionDose(
          currentMgdl: 250,
          targetMgdl: 120,
          sensitivityMgdlPerUnit: 40,
        ),
        3.5,
      );
    });

    test('jamais de dose négative', () {
      expect(
        GlucoseLogic.correctionDose(
          currentMgdl: 80,
          targetMgdl: 120,
          sensitivityMgdlPerUnit: 50,
        ),
        0,
      );
    });

    test('une sensibilité nulle ne provoque pas de division par zéro', () {
      expect(
        GlucoseLogic.correctionDose(
          currentMgdl: 300,
          targetMgdl: 120,
          sensitivityMgdlPerUnit: 0,
        ),
        0,
      );
    });
  });

  group('Bolus pour les glucides', () {
    test('glucides ÷ ratio, arrondi à la demi-unité', () {
      expect(GlucoseLogic.bolusForCarbs(carbsG: 50, carbRatioGPerUnit: 10), 5);
      expect(GlucoseLogic.bolusForCarbs(carbsG: 30, carbRatioGPerUnit: 10), 3);
      expect(GlucoseLogic.bolusForCarbs(carbsG: 55, carbRatioGPerUnit: 10), 5.5);
    });

    test('un ratio nul ne provoque pas de division par zéro', () {
      expect(GlucoseLogic.bolusForCarbs(carbsG: 50, carbRatioGPerUnit: 0), 0);
    });
  });

  group('Sérialisation (persistance locale)', () {
    test('aller-retour JSON sans perte', () {
      final original = GlucoseReading(
        id: 'abc',
        dateTime: DateTime(2026, 10, 1, 7, 30),
        valueMgdl: 128,
        context: MeasureContext.afterMeal,
        exerciseMinutes: 30,
        sleepHours: 7.5,
        stressLevel: 2,
        note: 'Test',
        tags: const ['sport'],
      );
      final restored = GlucoseReading.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.dateTime, original.dateTime);
      expect(restored.valueMgdl, original.valueMgdl);
      expect(restored.context, original.context);
      expect(restored.exerciseMinutes, original.exerciseMinutes);
      expect(restored.sleepHours, original.sleepHours);
      expect(restored.stressLevel, original.stressLevel);
      expect(restored.note, original.note);
      expect(restored.tags, original.tags);
    });
  });
}
