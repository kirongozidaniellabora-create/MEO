import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/units.dart';
import '../../data/models/insulin_meal_hba1c.dart';
import '../../domain/app_state.dart';
import '../../domain/glucose_logic.dart';
import '../../navigation.dart';
import '../../widgets/common.dart';

/// Journal des repas (WBS lot 8.2) et répartition des glucides.
class MealsPage extends StatefulWidget {
  const MealsPage({super.key, required this.state});

  final AppState state;

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  int _range = 7;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: _range - 1));
    final meals = widget.state.meals.where((m) => !m.dateTime.isBefore(start)).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final total = meals.fold<double>(0, (s, m) => s + m.carbsG);
    final quick = meals.fold<double>(0, (s, m) => s + m.quickCarbsG);
    final perMeal = meals.isEmpty ? 0.0 : total / meals.length;
    final ratio = widget.state.profile.insulin.carbRatioGPerUnit;
    final perMealUnits = ratio > 0 ? perMeal / ratio : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repas & glucides'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Row(
                children: [
                  for (final (d, label) in const [(1, '24 h'), (7, '7 j'), (30, '30 j')])
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ChoiceChip(
                        label: Text(label),
                        visualDensity: VisualDensity.compact,
                        selected: _range == d,
                        onSelected: (_) => setState(() => _range = d),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Glucides',
                  value: total.toStringAsFixed(0),
                  unit: 'g',
                  icon: Icons.restaurant_outlined,
                  color: AppColors.carbs,
                  caption: 'sur $_range jour(s)',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  label: 'Par repas',
                  value: perMeal.toStringAsFixed(0),
                  unit: 'g',
                  icon: Icons.pie_chart_outline,
                  color: AppColors.carbs,
                  caption: '≈ ${perMealUnits.toStringAsFixed(1)} U d’insuline',
                ),
              ),
            ],
          ),
          if (quick > 0) ...[
            const SizedBox(height: 12),
            MedicalNotice(
              compact: true,
              text: 'Sur cette période, ${quick.toStringAsFixed(0)} g de sucres rapides ont été '
                  'relevés. Les sucres rapides font monter la glycémie très vite : privilégiez '
                  'ceux issus de fruits ou de produits laitiers.',
            ),
          ],
          const SizedBox(height: 18),
          const SectionHeader(title: 'Répartition par type', icon: Icons.bar_chart),
          _CarbsByType(meals: meals),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Repas enregistrés', icon: Icons.list_alt),
          if (meals.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Aucun repas sur les $_range derniers jours',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF5B6D6A)),
                  ),
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < meals.length; i++) ...[
                    if (i > 0) const Divider(indent: 60, endIndent: 12),
                    _MealTile(
                      meal: meals[i],
                      carbRatio: widget.state.profile.insulin.carbRatioGPerUnit,
                      onTap: () => openMealEditor(context, widget.state, meals[i]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openMealEditor(context, widget.state),
        icon: const Icon(Icons.add),
        label: const Text('Repas'),
        backgroundColor: AppColors.carbs,
      ),
    );
  }
}

class _CarbsByType extends StatelessWidget {
  const _CarbsByType({required this.meals});

  final List<Meal> meals;

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final m in meals) {
      totals[m.type.label] = (totals[m.type.label] ?? 0) + m.carbsG;
    }
    if (totals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Center(
            child: Text(
              'Aucune donnée',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF8A9A98)),
            ),
          ),
        ),
      );
    }
    final max = totals.values.reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            for (final entry in totals.entries) ...[
              Row(
                children: [
                  SizedBox(
                    width: 92,
                    child: Text(
                      entry.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0 : entry.value / max,
                        minHeight: 9,
                        backgroundColor: const Color(0xFFEDF1F0),
                        valueColor: const AlwaysStoppedAnimation(AppColors.carbs),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    child: Text(
                      '${entry.value.toStringAsFixed(0)} g',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.meal, required this.carbRatio, required this.onTap});

  final Meal meal;
  final double carbRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final units = carbRatio > 0 ? GlucoseLogic.bolusForCarbs(
      carbsG: meal.carbsG,
      carbRatioGPerUnit: carbRatio,
    ) : 0.0;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.carbs.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(meal.type.icon, size: 20, color: AppColors.carbs),
      ),
      title: Row(
        children: [
          Text(
            meal.carbsG.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.carbs,
            ),
          ),
          const Text(' g', style: TextStyle(fontSize: 12, color: Color(0xFF5B6D6A))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              meal.type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF5B6D6A)),
            ),
          ),
        ],
      ),
      subtitle: Text(
        meal.description.isEmpty
            ? '≈ ${formatUnits(units)} d’insuline'
            : '${meal.description} · ≈ ${formatUnits(units)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A9A98)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            hhmm(meal.dateTime),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          Text(
            relativeDayFr(meal.dateTime),
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF8A9A98)),
          ),
        ],
      ),
    );
  }
}
