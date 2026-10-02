import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../data/models/insulin_meal_hba1c.dart';
import '../../domain/app_state.dart';
import '../../widgets/common.dart';

/// Saisie d'une injection (WBS lot 7.2).
class InsulinEditorPage extends StatefulWidget {
  const InsulinEditorPage({super.key, required this.state, this.existing});

  final AppState state;
  final InsulinEntry? existing;

  @override
  State<InsulinEditorPage> createState() => _InsulinEditorPageState();
}

class _InsulinEditorPageState extends State<InsulinEditorPage> {
  late InsulinKind _kind;
  late DateTime _dateTime;
  late final TextEditingController _units;
  final _product = TextEditingController();
  final _penLot = TextEditingController();
  final _note = TextEditingController();
  bool _correction = false;
  String? _mealId;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kind = e?.kind ?? InsulinKind.bolus;
    _dateTime = e?.dateTime ?? DateTime.now();
    _units = TextEditingController(text: (e?.units ?? 4).toStringAsFixed(1));
    _product.text = e?.productName ?? (_kind == InsulinKind.bolus ? 'Rapide' : 'Lente');
    _penLot.text = e?.penLot ?? '';
    _note.text = e?.note ?? '';
    _correction = e?.isCorrection ?? false;
    _mealId = e?.mealId;
  }

  @override
  void dispose() {
    _units.dispose();
    _product.dispose();
    _penLot.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final u = double.tryParse(_units.text.trim().replaceAll(',', '.'));
    if (u == null || u <= 0) {
      _toast('Dose invalide : saisissez un nombre supérieur à 0.');
      return;
    }
    if (u > 200) {
      _toast('Dose inhabituellement élevée : vérifiez la saisie.');
      return;
    }
    final e = widget.existing;
    await widget.state.addOrUpdateInsulin(
      InsulinEntry(
        id: e?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
        dateTime: _dateTime,
        kind: _kind,
        units: u,
        productName: _product.text.trim(),
        mealId: _mealId,
        isCorrection: _correction,
        penLot: _penLot.text.trim(),
        note: _note.text.trim(),
      ),
      isUpdate: _isEdit,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier l’injection' : 'Nouvelle injection'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await widget.state.deleteInsulin(widget.existing!.id);
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SectionHeader(title: 'Type d’insuline', icon: Icons.category_outlined),
          Row(
            children: [
              for (final k in InsulinKind.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(k.label.split(' ').first, textAlign: TextAlign.center),
                      avatar: Icon(k.icon, size: 16),
                      selected: _kind == k,
                      onSelected: (_) => setState(() => _kind = k),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Dose', icon: Icons.speed_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: Column(
                children: [
                  TextField(
                    controller: _units,
                    autofocus: !_isEdit,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(
                      hintText: '4.0',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const Text('unités (U)', style: TextStyle(fontSize: 12, color: Color(0xFF5B6D6A))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final step in [-1.0, -0.5, 0.5, 1.0])
                        OutlinedButton(
                          onPressed: () {
                            final cur = double.tryParse(_units.text) ?? 0;
                            final next = (cur + step).clamp(0.0, 200.0);
                            _units.text = next == next.roundToDouble()
                                ? next.toStringAsFixed(0)
                                : next.toStringAsFixed(1);
                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            step > 0 ? '+$step' : '$step',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
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
                      setState(() {
                        _dateTime =
                            DateTime(d.year, d.month, d.day, _dateTime.hour, _dateTime.minute);
                      });
                    }
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _product,
                    decoration: const InputDecoration(
                      labelText: 'Produit / analogue',
                      hintText: 'Rapide (aspart, lispro), lente (glargine, detemir)…',
                    ),
                  ),
                ),
                if (widget.state.meals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _mealId,
                        hint: const Text('Repas associé (facultatif)'),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('Aucun')),
                          ...widget.state.meals.take(15).map(
                            (m) => DropdownMenuItem<String?>(
                              value: m.id,
                              child: Text(
                                '${relativeTimeFr(m.dateTime)} · ${m.type.label} · '
                                '${m.carbsG.toStringAsFixed(0)} g',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _mealId = v),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _penLot,
                    decoration: const InputDecoration(
                      labelText: 'Lot du stylo',
                      hintText: 'Repère du flacon (traçabilité)',
                    ),
                  ),
                ),
                SwitchListTile(
                  value: _correction,
                  onChanged: (v) => setState(() => _correction = v),
                  title: const Text('Dose de correction', style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                    'Calculée pour corriger une glycémie haute',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  child: TextField(
                    controller: _note,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const MedicalNotice(),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(_isEdit ? 'Enregistrer' : 'Enregistrer l’injection'),
          ),
        ],
      ),
    );
  }
}
