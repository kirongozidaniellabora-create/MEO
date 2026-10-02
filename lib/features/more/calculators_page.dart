import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/units.dart';
import '../../domain/app_state.dart';
import '../../domain/glucose_logic.dart';
import '../../widgets/common.dart';

/// Trois calculateurs (WBS lot 10) — résultats **indicatifs**, jamais prescrits.
class CalculatorsPage extends StatefulWidget {
  const CalculatorsPage({super.key, required this.state});

  final AppState state;

  @override
  State<CalculatorsPage> createState() => _CalculatorsPageState();
}

class _CalculatorsPageState extends State<CalculatorsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculateurs'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Color(0xFF5B6D6A),
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Correction'),
              Tab(text: 'Glucides'),
              Tab(text: 'Hypoglycémie'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CorrectionTab(state: widget.state),
            _CarbsTab(state: widget.state),
            const _HypoTab(),
          ],
        ),
      ),
    );
  }
}

class _CorrectionTab extends StatefulWidget {
  const _CorrectionTab({required this.state});

  final AppState state;

  @override
  State<_CorrectionTab> createState() => _CorrectionTabState();
}

class _CorrectionTabState extends State<_CorrectionTab> {
  late final TextEditingController _glycemia;
  late double _target;

  @override
  void initState() {
    super.initState();
    _target = widget.state.profile.thresholds.targetLow;
    final latest = widget.state.latest?.valueMgdl ?? 180;
    _glycemia = TextEditingController(text: mgdlToGl(latest).toStringAsFixed(2));
  }

  @override
  void dispose() {
    _glycemia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.state.profile;
    final sens = profile.insulin.sensitivityMgdlPerUnit;
    final current = double.tryParse(_glycemia.text.replaceAll(',', '.'));
    final mgdl = current == null ? null : glToMgdl(current);

    final dose = mgdl == null
        ? 0.0
        : GlucoseLogic.correctionDose(
            currentMgdl: mgdl,
            targetMgdl: _target,
            sensitivityMgdlPerUnit: sens,
          );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _glycemia,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Glycémie actuelle',
                    suffixText: 'g/L',
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Glycémie cible : ${formatGl(_target)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Slider(
                  value: _target,
                  min: 80,
                  max: 180,
                  divisions: 20,
                  label: formatGl(_target),
                  onChanged: (v) => setState(() => _target = v),
                ),
                Text(
                  'Sensibilité : 1 U fait baisser de ${(sens / 100).toStringAsFixed(2)} g/L '
                  '(réglable dans les paramètres)',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Dose de correction estimée',
          value: formatUnits(dose),
          detail: mgdl == null
              ? 'Saisissez une glycémie'
              : '(${formatGl(mgdl)} − ${formatGl(_target)}) ÷ '
                    '${(sens / 100).toStringAsFixed(2)} g/L par U'
                    '${dose <= 0 ? ' — aucune correction nécessaire' : ''}',
          color: dose <= 0 ? AppColors.inRange : AppColors.secondary,
        ),
        const SizedBox(height: 16),
        const MedicalNotice(
          text: 'Ce calcul est indicatif. Il ne remplace pas les règles de correction '
              'que votre médecin a définies pour vous, qui peuvent être différentes '
              '(prise en compte de l’activité, de la glycémie de la veille, du poids…).',
        ),
      ],
    );
  }
}

class _CarbsTab extends StatefulWidget {
  const _CarbsTab({required this.state});

  final AppState state;

  @override
  State<_CarbsTab> createState() => _CarbsTabState();
}

class _CarbsTabState extends State<_CarbsTab> {
  late final TextEditingController _carbs;
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.state.profile.insulin.carbRatioGPerUnit;
    _carbs = TextEditingController(text: '50');
  }

  @override
  void dispose() {
    _carbs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carbs = double.tryParse(_carbs.text.replaceAll(',', '.')) ?? 0;
    final units = GlucoseLogic.bolusForCarbs(
      carbsG: carbs,
      carbRatioGPerUnit: _ratio,
    );
    final rise = GlucoseLogic.estimatedRiseMgdl(carbs);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _carbs,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Glucides du repas',
                    suffixText: 'g',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Repères : 1 pain = 15 g · 1 pomme = 15 g · 150 g de riz = 45 g · '
                  '1 yaourt = 15 g · 1 pomme de terre = 25 g',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A), height: 1.4),
                ),
                const SizedBox(height: 14),
                Text(
                  'Ratio insuline/glucides : 1 U pour ${_ratio.toStringAsFixed(0)} g',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Slider(
                  value: _ratio.clamp(5, 30),
                  min: 5,
                  max: 30,
                  divisions: 25,
                  label: '${_ratio.toStringAsFixed(0)} g/U',
                  onChanged: (v) => setState(() => _ratio = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ResultCard(
          title: 'Bolus estimé pour ce repas',
          value: formatUnits(units),
          detail: '${carbs.toStringAsFixed(0)} g ÷ ${_ratio.toStringAsFixed(0)} g par U, '
              'arrondi à la demi-unité',
          color: AppColors.insulin,
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'Montée de glycémie attendue sans insuline',
          value: '+${(rise / 100).toStringAsFixed(2)} g/L',
          detail: 'Estimation grossière (≈ 0,5 g/L pour 10 g de glucides). '
              'Les fibres, les protéines et le gras ralentissent la montée.',
          color: AppColors.carbs,
        ),
        const SizedBox(height: 16),
        const MedicalNotice(),
      ],
    );
  }
}

class _HypoTab extends StatelessWidget {
  const _HypoTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.hypoglycemia.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.hypoglycemia.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.hypoglycemia, size: 26),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Règle des 15 g / 15 minutes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.hypoglycemia,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Pour remonter une glycémie basse, il faut des glucides rapidement '
                'assimilables : environ 15 g à la fois, puis recontrôler 15 minutes après.',
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionHeader(title: '15 g de glucides rapides', icon: Icons.restaurant),
        Card(
          child: Column(
            children: const [
              InfoRow(label: '3 comprimés de sucre', value: '≈ 15 g'),
              InfoRow(label: '15 cl de jus de fruit', value: '≈ 15 g'),
              InfoRow(label: 'Petite canette de soda', value: '≈ 15 g'),
              InfoRow(label: '2 teaspoons de miel', value: '≈ 15 g'),
              Divider(),
              InfoRow(label: 'Pain complet', value: '≈ 30 g (trop lent)'),
              InfoRow(label: 'Chocolat noir 70 %', value: 'trop gras : imprévisible'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Protocole', icon: Icons.list),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 1; i <= 4; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.hypoglycemia.withValues(alpha: 0.15),
                          child: Text(
                            '$i',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.hypoglycemia,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            switch (i) {
                              1 => 'Prendre 15 g de glucides rapides (voir ci-dessus).',
                              2 => 'Attendre 15 minutes, sans faire d’activité physique.',
                              3 => 'Recontrôler la glycémie.',
                              _ => 'Si elle reste basse, recommencer. Une fois remontée, '
                                  'prendre une collation avec des fibres (pain, fromage) '
                                  'pour éviter un rebond.',
                            },
                            style: const TextStyle(fontSize: 12.5, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.emergency_outlined, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Personne inconsciente ou en convulsion : ne donnez RIEN par la bouche. '
                        'Mettez-la sur le côté et appelez immédiatement le 15 ou le 112.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const MedicalNotice(
          compact: true,
          text: 'Ce protocole est un rappel général. Suivez toujours le protocole '
              'personnalisé qui vous a été remis par votre équipe soignante.',
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.color,
  });

  final String title;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF5B6D6A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF2E3E3C)),
            ),
          ],
        ),
      ),
    );
  }
}
