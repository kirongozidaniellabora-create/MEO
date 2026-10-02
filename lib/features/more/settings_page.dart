import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/units.dart';
import '../../data/models/profile.dart';
import '../../domain/app_state.dart';
import '../../widgets/common.dart';

/// Paramètres et gestion des données (WBS lot 12).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final p = state.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SectionHeader(title: 'Profil', icon: Icons.person_outline),
          _card([
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Nom affiché'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.displayName,
                    style: const TextStyle(color: Color(0xFF5B6D6A), fontSize: 13),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _editName(context),
            ),
            const Divider(indent: 56),
            ListTile(
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Âge'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${p.age} ans',
                    style: const TextStyle(color: Color(0xFF5B6D6A), fontSize: 13),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _editAge(context),
            ),
            const Divider(indent: 56),
            ListTile(
              leading: const Icon(Icons.medical_information_outlined),
              title: const Text('Type de diabète'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.diabetesType.label,
                    style: const TextStyle(color: Color(0xFF5B6D6A), fontSize: 13),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _editType(context),
            ),
          ]),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Objectifs glycémiques', icon: Icons.flag_outlined),
          _TargetsCard(state: state),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Paramètres insuliniques', icon: Icons.vaccines_outlined),
          _InsulinCard(state: state),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Mes données', icon: Icons.folder_outlined),
          _card([
            ListTile(
              leading: const Icon(Icons.ios_share_outlined),
              title: const Text('Exporter en JSON'),
              subtitle: Text(
                '${state.readings.length} mesures · ${state.meals.length} repas · '
                '${state.insulinEntries.length} injections',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _export(context),
            ),
            const Divider(indent: 56),
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: const Text('Charger le jeu de démonstration'),
              subtitle: const Text('14 jours de mesures simulées, efface les données actuelles'),
              onTap: () => _confirm(context, 'Charger la démonstration ?',
                  'Vos données actuelles seront remplacées. Pensez à les exporter avant.'),
            ),
            const Divider(indent: 56),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              title: const Text('Vider les données de suivi'),
              subtitle: const Text('Conserve le profil, supprime mesures, repas, insulines, HbA1c'),
              onTap: () => _confirm(context, 'Vider les données ?',
                  'Toutes les mesures, repas, injections et résultats HbA1c seront supprimés.'),
            ),
            const Divider(indent: 56),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore, color: Colors.redAccent),
              title: const Text('Réinitialiser l’application'),
              subtitle: const Text('Efface tout et relance l’onboarding'),
              onTap: () => _confirm(context, 'Tout réinitialiser ?',
                  'Profil, objectifs et données seront effacés. Cette action est irréversible.'),
            ),
          ]),
          const SizedBox(height: 18),
          const SectionHeader(title: 'À propos', icon: Icons.info_outline),
          _card([
            const ListTile(
              leading: Icon(Icons.water_drop),
              title: Text('DiabTrack'),
              subtitle: Text('Version 1.0.0 — projet de gestion de projet, ICAM B1'),
            ),
            const Divider(indent: 56),
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Confidentialité'),
              subtitle: Text(
                'Toutes vos données sont enregistrées uniquement sur ce téléphone. '
                'Aucun compte, aucun serveur, aucune connexion Internet.',
              ),
            ),
            const Divider(indent: 56),
            const ListTile(
              leading: Icon(Icons.accessibility_new_outlined),
              title: Text('Accessibilité'),
              subtitle: Text(
                'Chaque statut combine une couleur, une icône et un libellé texte, '
                'pour rester lisible avec un daltonisme.',
              ),
            ),
          ]),
          const SizedBox(height: 18),
          const MedicalNotice(),
        ],
      ),
    );
  }

  static Widget _card(List<Widget> children) => Card(child: Column(children: children));

  Future<void> _editName(BuildContext context) async {
    final controller = TextEditingController(text: state.profile.displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nom affiché'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Moi'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final name = result.isEmpty ? 'Moi' : result;
    await state.updateProfile(state.profile.copyWith(displayName: name));
  }

  Future<void> _editAge(BuildContext context) async {
    var age = state.profile.age.toDouble();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Âge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${age.round()} ans',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              Slider(
                value: age,
                min: 1,
                max: 100,
                divisions: 99,
                onChanged: (v) => setLocal(() => age = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, age.round()),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await state.updateProfile(state.profile.copyWith(age: result));
  }

  Future<void> _editType(BuildContext context) async {
    var type = state.profile.diabetesType;
    final result = await showDialog<DiabetesType>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Type de diabète'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in DiabetesType.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    t == type ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: t == type ? Theme.of(context).colorScheme.primary : const Color(0xFFB4C0BE),
                  ),
                  title: Text(t.label, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                    t.subtitle,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
                  ),
                  onTap: () => setLocal(() => type = t),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, type),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await state.updateProfile(state.profile.copyWith(diabetesType: result));
  }

  Future<void> _export(BuildContext context) async {
    final json = state.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Export copié dans le presse-papiers : collez-le dans un mail '
              'ou une note pour le transmettre à votre médecin.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
  }

  Future<void> _confirm(BuildContext context, String title, String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    if (title.contains('démonstration')) {
      await state.loadDemoData();
    } else if (title.contains('Tout')) {
      await state.resetAll();
    } else {
      await state.resetDataOnly();
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('« $title » effectué'), behavior: SnackBarBehavior.floating),
      );
    Navigator.of(context).maybePop();
  }
}

/// Réglage des objectifs cibles (glycémie à jeun, post-prandiale, HbA1c, TIR).
class _TargetsCard extends StatefulWidget {
  const _TargetsCard({required this.state});

  final AppState state;

  @override
  State<_TargetsCard> createState() => _TargetsCardState();
}

class _TargetsCardState extends State<_TargetsCard> {
  late Targets _targets;

  @override
  void initState() {
    super.initState();
    _targets = widget.state.profile.targets;
  }

  Future<void> _apply() async {
    await widget.state.updateProfile(widget.state.profile.copyWith(targets: _targets));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Objectifs enregistrés'), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          children: [
            _sliderRow(
              label: 'Glycémie cible',
              value: _targets.fastingMgdl,
              min: 80,
              max: 130,
              divisions: 10,
              display: formatGl(_targets.fastingMgdl),
              onChanged: (v) => setState(() => _targets = _targets.copyWith(fastingMgdl: v)),
            ),
            _sliderRow(
              label: 'Cible après repas',
              value: _targets.postMealMgdl,
              min: 100,
              max: 180,
              divisions: 16,
              display: formatGl(_targets.postMealMgdl),
              onChanged: (v) => setState(() => _targets = _targets.copyWith(postMealMgdl: v)),
            ),
            _sliderRow(
              label: 'Objectif HbA1c',
              value: _targets.hba1cPercent,
              min: 5.5,
              max: 9,
              divisions: 14,
              display: '${_targets.hba1cPercent.toStringAsFixed(1)} %',
              onChanged: (v) => setState(() => _targets = _targets.copyWith(hba1cPercent: v)),
            ),
            _sliderRow(
              label: 'Objectif de temps dans la cible',
              value: _targets.tirTargetPercent,
              min: 50,
              max: 90,
              divisions: 8,
              display: '${_targets.tirTargetPercent.toStringAsFixed(0)} %',
              onChanged: (v) => setState(() => _targets = _targets.copyWith(tirTargetPercent: v)),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Enregistrer les objectifs'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            Text(display, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
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

/// Réglage des paramètres insuliniques servant aux calculateurs.
class _InsulinCard extends StatefulWidget {
  const _InsulinCard({required this.state});

  final AppState state;

  @override
  State<_InsulinCard> createState() => _InsulinCardState();
}

class _InsulinCardState extends State<_InsulinCard> {
  late InsulinSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.state.profile.insulin;
  }

  Future<void> _apply() async {
    await widget.state.updateProfile(widget.state.profile.copyWith(insulin: _settings));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Paramètres enregistrés'), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          children: [
            _TargetsCardState._sliderRow(
              label: 'Dose totale quotidienne prescrite',
              value: _settings.dailyPrescribedUnits,
              min: 4,
              max: 100,
              divisions: 96,
              display: formatUnits(_settings.dailyPrescribedUnits),
              onChanged: (v) =>
                  setState(() => _settings = _settings.copyWith(dailyPrescribedUnits: v)),
            ),
            _TargetsCardState._sliderRow(
              label: 'Ratio insuline / glucides',
              value: _settings.carbRatioGPerUnit,
              min: 5,
              max: 30,
              divisions: 25,
              display: '1 U pour ${_settings.carbRatioGPerUnit.toStringAsFixed(0)} g',
              onChanged: (v) =>
                  setState(() => _settings = _settings.copyWith(carbRatioGPerUnit: v)),
            ),
            _TargetsCardState._sliderRow(
              label: 'Sensibilité à l’insuline',
              value: _settings.sensitivityMgdlPerUnit,
              min: 20,
              max: 100,
              divisions: 16,
              display: '1 U = −${( _settings.sensitivityMgdlPerUnit / 100).toStringAsFixed(2)} g/L',
              onChanged: (v) =>
                  setState(() => _settings = _settings.copyWith(sensitivityMgdlPerUnit: v)),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Enregistrer les paramètres'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ces valeurs servent uniquement aux calculateurs de la V1. '
              'Elles doivent correspondre à votre prescription.',
              style: TextStyle(fontSize: 11, color: Color(0xFF8A9A98), height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
