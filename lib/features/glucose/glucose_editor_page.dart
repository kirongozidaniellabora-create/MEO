import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/units.dart';
import '../../data/models/glucose_reading.dart';
import '../../domain/app_state.dart';
import '../../domain/glucose_logic.dart';
import '../../widgets/common.dart';

/// Formulaire de saisie d'une glycémie (WBS lot 5.2).
///
/// Objectif SMART **O2** : la saisie doit se faire en **moins de 20 secondes**, soit 4 gestes.
/// D'où la conception : un champ géant, une valeur par défaut pré-remplie avec la dernière
/// mesure connue, un bouton d'enregistrement toujours visible, et un quai de boutons
/// +/- pour éviter le clavier.
class GlucoseEditorPage extends StatefulWidget {
  const GlucoseEditorPage({super.key, required this.state, this.existing});

  final AppState state;
  final GlucoseReading? existing;

  @override
  State<GlucoseEditorPage> createState() => _GlucoseEditorPageState();
}

class _GlucoseEditorPageState extends State<GlucoseEditorPage> {
  late final TextEditingController _value;
  final _noteController = TextEditingController();

  late DateTime _dateTime;
  late MeasureContext _context;
  String? _mealId;
  int _exercise = 0;
  double? _sleep;
  int _stress = 0;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    // Valeur par défaut : la dernière mesure connue, modifiable en un geste.
    final seed = e?.valueMgdl ?? widget.state.latest?.valueMgdl ?? 110;
    _value = TextEditingController(text: mgdlToGl(seed).toStringAsFixed(2));
    _noteController.text = e?.note ?? '';
    _dateTime = e?.dateTime ?? DateTime.now();
    _context = e?.context ?? _suggestContext(DateTime.now());
    _mealId = e?.mealId;
    _exercise = e?.exerciseMinutes ?? 0;
    _sleep = e?.sleepHours;
    _stress = e?.stressLevel ?? 0;
  }

  /// Propose un contexte cohérent avec l'heure (gain de temps, moins d'erreurs).
  static MeasureContext _suggestContext(DateTime now) {
    final h = now.hour;
    if (h >= 6 && h < 10) return MeasureContext.fasting;
    if (h >= 10 && h < 15) return MeasureContext.afterMeal;
    if (h >= 15 && h < 18) return MeasureContext.beforeMeal;
    if (h >= 21) return MeasureContext.bedtime;
    return MeasureContext.other;
  }

  @override
  void dispose() {
    _value.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? get _mgdl {
    final gl = double.tryParse(_value.text.trim().replaceAll(',', '.'));
    if (gl == null) return null;
    return glToMgdl(gl);
  }

  void _nudge(double deltaGl) {
    final current = _mgdl ?? 100;
    final next = ((mgdlToGl(current) + deltaGl) * 100).round() / 100;
    _value.text = next.toStringAsFixed(2);
    _value.selection = TextSelection.collapsed(offset: _value.text.length);
  }

  Future<void> _save() async {
    final mgdl = _mgdl;
    if (mgdl == null) {
      _toast('Valeur invalide : saisissez un nombre, par exemple 1,28');
      return;
    }
    if (mgdl < 20 || mgdl > 600) {
      _toast('Valeur hors limites (0,20 à 6,00 g/L). Vérifiez la saisie.');
      return;
    }
    if (_dateTime.isAfter(DateTime.now().add(const Duration(minutes: 2)))) {
      _toast('La date ne peut pas être dans le futur.');
      return;
    }

    final e = widget.existing;
    final reading = GlucoseReading(
      id: e?.id ?? _newId(),
      dateTime: _dateTime,
      valueMgdl: mgdl,
      context: _context,
      mealId: _mealId,
      exerciseMinutes: _exercise,
      sleepHours: _sleep,
      stressLevel: _stress,
      note: _noteController.text.trim(),
      tags: e?.tags ?? const <String>[],
    );
    if (_isEdit) {
      await widget.state.updateReading(reading);
    } else {
      await widget.state.addReading(reading);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${DateTime.now().millisecond}';

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final status = _mgdl == null
        ? null
        : GlucoseStatus.fromValue(_mgdl!, widget.state.profile.thresholds);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la mesure' : 'Nouvelle mesure'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ---------------- Valeur ----------------
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: Column(
                children: [
                  TextField(
                    controller: _value,
                    autofocus: !_isEdit,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(
                      hintText: '1.28',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const Text(
                    'g/L  ·  glycémie capillaire',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NudgeButton(label: '− 0,10', onTap: () => _nudge(-0.10)),
                      _NudgeButton(label: '− 0,01', onTap: () => _nudge(-0.01)),
                      _NudgeButton(label: '+ 0,01', onTap: () => _nudge(0.01)),
                      _NudgeButton(label: '+ 0,10', onTap: () => _nudge(0.10)),
                    ],
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 14),
                    Column(
                      children: [
                        StatusBadge(status: status),
                        const SizedBox(height: 6),
                        Text(
                          status.hint,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ---------------- Date et heure ----------------
          const SectionHeader(title: 'Quand ?', icon: Icons.schedule),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(dateFullFr(_dateTime)),
                  subtitle: Text(hhmm(_dateTime)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: _pickDate,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.timelapse),
                  title: const Text('Changer l’heure'),
                  subtitle: Text(hhmm(_dateTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ---------------- Contexte ----------------
          const SectionHeader(title: 'Dans quel contexte ?', icon: Icons.category_outlined),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in MeasureContext.values)
                ChoiceChip(
                  label: Text(c.label),
                  avatar: Icon(c.icon, size: 16),
                  selected: _context == c,
                  onSelected: (_) => setState(() => _context = c),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ---------------- Repas lié ----------------
          if (widget.state.meals.isNotEmpty) ...[
            const SectionHeader(title: 'Repas associé (facultatif)', icon: Icons.restaurant_menu),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _mealId,
                    hint: const Text('Aucun repas lié'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Aucun repas lié'),
                      ),
                      ...widget.state.meals.take(20).map(
                        (m) => DropdownMenuItem<String?>(
                          value: m.id,
                          child: Text(
                            '${relativeTimeFr(m.dateTime)} · ${m.type.label} · ${m.carbsG.toStringAsFixed(0)} g',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _mealId = v),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // ---------------- Facteurs --------------
          const SectionHeader(title: 'Facteurs du jour (facultatif)', icon: Icons.favorite_outline),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  _SliderRow(
                    label: 'Activité physique',
                    value: _exercise.toDouble(),
                    min: 0,
                    max: 240,
                    divisions: 24,
                    display: _exercise == 0 ? 'Aucune' : '$_exercise min',
                    onChanged: (v) => setState(() => _exercise = v.round()),
                  ),
                  _SliderRow(
                    label: 'Heures de sommeil',
                    value: _sleep ?? 7,
                    min: 0,
                    max: 12,
                    divisions: 12,
                    display: _sleep == null ? 'Non renseigné' : formatHours(_sleep!),
                    onChanged: (v) => setState(() => _sleep = v),
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Stress', style: TextStyle(fontSize: 13.5)),
                      ),
                      ...List.generate(4, (i) {
                        final active = _stress == i + 1;
                        return IconButton(
                          tooltip: switch (i + 1) {
                            1 => 'Stress léger',
                            2 => 'Stress modéré',
                            _ => 'Stress fort',
                          },
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() => _stress = i + 1),
                          icon: Icon(
                            active ? Icons.sentiment_very_dissatisfied : Icons.sentiment_neutral_outlined,
                            size: 22,
                            color: active ? AppColors.low : const Color(0xFFB4C0BE),
                          ),
                        );
                      }),
                      if (_stress > 0)
                        IconButton(
                          tooltip: 'Effacer',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() => _stress = 0),
                          icon: const Icon(Icons.close, size: 18, color: Color(0xFF8A9A98)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _stress == 0 ? 'Aucun' : switch (_stress) {
                        1 => 'Stress léger',
                        2 => 'Stress modéré',
                        _ => 'Stress fort',
                      },
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'Maladie, mal-être, décalage horaire…',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(_isEdit ? 'Enregistrer les modifications' : 'Enregistrer la mesure'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now(),
      locale: const Locale('fr'),
    );
    if (d != null) {
      setState(() {
        _dateTime = DateTime(d.year, d.month, d.day, _dateTime.hour, _dateTime.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (t != null) {
      setState(() {
        _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day, t.hour, t.minute);
      });
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette mesure ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await widget.state.deleteReading(widget.existing!.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }
}

class _NudgeButton extends StatelessWidget {
  const _NudgeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13.5))),
            Text(
              display,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
