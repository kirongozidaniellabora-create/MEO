import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/units.dart';
import '../../data/models/insulin_meal_hba1c.dart';
import '../../domain/app_state.dart';
import '../../widgets/common.dart';

/// Saisie d'un repas (WBS lot 8.1).
class MealEditorPage extends StatefulWidget {
  const MealEditorPage({super.key, required this.state, this.existing});

  final AppState state;
  final Meal? existing;

  @override
  State<MealEditorPage> createState() => _MealEditorPageState();
}

class _MealEditorPageState extends State<MealEditorPage> {
  late MealType _type;
  late DateTime _dateTime;
  late final TextEditingController _carbs;
  late final TextEditingController _quick;
  final _desc = TextEditingController();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? _suggest(DateTime.now().hour);
    _dateTime = e?.dateTime ?? DateTime.now();
    _carbs = TextEditingController(text: (e?.carbsG ?? 50).toStringAsFixed(0));
    _quick = TextEditingController(text: (e?.quickCarbsG ?? 0).toStringAsFixed(0));
    _desc.text = e?.description ?? '';
  }

  static MealType _suggest(int hour) {
    if (hour < 10) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    if (hour < 22) return MealType.dinner;
    return MealType.supper;
  }

  @override
  void dispose() {
    _carbs.dispose();
    _quick.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final c = double.tryParse(_carbs.text.trim().replaceAll(',', '.'));
    if (c == null || c < 0) {
      _toast('Montant de glucides invalide.');
      return;
    }
    final q = double.tryParse(_quick.text.trim().replaceAll(',', '.')) ?? 0;
    if (q > c) {
      _toast('Les sucres rapides ne peuvent pas dépasser le total des glucides.');
      return;
    }
    final e = widget.existing;
    final meal = Meal(
      id: e?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
      dateTime: _dateTime,
      type: _type,
      carbsG: c,
      quickCarbsG: q.clamp(0, c),
      description: _desc.text.trim(),
    );
    if (_isEdit) {
      await widget.state.updateMeal(meal);
    } else {
      await widget.state.addMeal(meal);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.state.profile.insulin.carbRatioGPerUnit;
    final carbs = double.tryParse(_carbs.text.replaceAll(',', '.')) ?? 0;
    final estimatedUnits = ratio > 0 ? carbs / ratio : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier le repas' : 'Nouveau repas'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await widget.state.deleteMeal(widget.existing!.id);
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SectionHeader(title: 'Type de repas', icon: Icons.restaurant_menu),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in MealType.values)
                ChoiceChip(
                  label: Text(t.label),
                  avatar: Icon(t.icon, size: 16),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Glucides', icon: Icons.bakery_dining_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: Column(
                children: [
                  TextField(
                    controller: _carbs,
                    autofocus: !_isEdit,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(
                      hintText: '50',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const Text(
                    'grammes de glucides',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _quick,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Dont sucres rapides',
                      hintText: '0',
                      helperText: 'Sodas, confiseries, jus de fruits, pâtes à tartiner',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.insulin.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calculate_outlined, size: 18, color: AppColors.insulin),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Avec votre ratio de $ratio g par U, ce repas correspond à environ '
                            '${formatUnits((estimatedUnits * 2).roundToDouble() / 2)} '
                            'd’insuline (valeur indicative).',
                            style: const TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF0B3B36)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Détails', icon: Icons.info_outline),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(dateFullFr(_dateTime)),
                  subtitle: Text(hhmm(_dateTime)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _dateTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                      lastDate: DateTime.now(),
                      locale: const Locale('fr'),
                    );
                    if (d != null) {
                      setState(() => _dateTime =
                          DateTime(d.year, d.month, d.day, _dateTime.hour, _dateTime.minute));
                    }
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: TextField(
                    controller: _desc,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Pain, fromage, pomme…',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(_isEdit ? 'Enregistrer' : 'Enregistrer le repas'),
          ),
        ],
      ),
    );
  }
}
