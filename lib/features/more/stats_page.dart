import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/units.dart';
import '../../data/models/glucose_reading.dart';
import '../../data/models/profile.dart';
import '../../domain/app_state.dart';
import '../../domain/glucose_logic.dart';
import '../../widgets/common.dart';

/// Statistiques (WBS lot 9) : temps dans la cible, moyennes, variabilité.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key, required this.state});

  final AppState state;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _days = 14;

  @override
  Widget build(BuildContext context) {
    final profile = widget.state.profile;
    final readings = widget.state.readingsLastDays(_days);
    final values = readings.map((r) => r.valueMgdl).toList();

    final avg = GlucoseLogic.average(values);
    final sd = GlucoseLogic.stdDev(values);
    final tir = GlucoseLogic.timeInRange(readings, profile.thresholds);
    final dist = GlucoseLogic.distribution(readings, profile.thresholds);
    final targetTir = profile.targets.tirTargetPercent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                for (final (d, label) in const [(7, '7 jours'), (14, '14 jours'), (30, '30 jours')])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _days == d,
                      onSelected: (_) => setState(() => _days = d),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: readings.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insights_outlined, size: 60, color: AppColors.primary.withValues(alpha: 0.35)),
                    const SizedBox(height: 14),
                    const Text(
                      'Pas encore de données',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Les statistiques se calculent sur les $_days derniers jours. Enregistrez '
                      'quelques mesures pour les voir apparaître.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF5B6D6A), height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _TirCard(
                  tir: tir,
                  target: targetTir,
                  dist: dist,
                  count: readings.length,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Moyenne',
                        value: formatGl(avg, withUnit: false),
                        unit: 'g/L',
                        icon: Icons.functions,
                        caption: '${readings.length} mesures',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        label: 'Écart-type',
                        value: (sd / 100).toStringAsFixed(2),
                        unit: 'g/L',
                        icon: Icons.scatter_plot_outlined,
                        caption: 'variabilité',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Coeff. variation',
                        value: GlucoseLogic.coefficientOfVariation(values).toStringAsFixed(1),
                        unit: '%',
                        icon: Icons.percent,
                        color: GlucoseLogic.coefficientOfVariation(values) <= 36
                            ? AppColors.inRange
                            : AppColors.high,
                        caption: '≤ 36 % = équilibre correct',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        label: 'Amplitude',
                        value: values.isEmpty
                            ? '—'
                            : formatGl(values.reduce((a, b) => a > b ? a : b) -
                                values.reduce((a, b) => a < b ? a : b),
                                withUnit: false),
                        unit: 'g/L',
                        icon: Icons.swap_vert,
                        caption: 'max − min',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const SectionHeader(title: 'Évolution sur la période', icon: Icons.show_chart),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 16, 14, 8),
                    child: GlucoseChart(
                      readings: readings,
                      profile: profile,
                      height: 200,
                      showAxisLabels: true,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const SectionHeader(title: 'Moyennes par moment', icon: Icons.schedule),
                _ByContext(readings: readings, profile: profile),
                const SizedBox(height: 18),
                const SectionHeader(title: 'Répartition détaillée', icon: Icons.donut_small),
                _DistributionCard(dist: dist, count: readings.length),
                const SizedBox(height: 18),
                const MedicalNotice(),
              ],
            ),
    );
  }
}

class _TirCard extends StatelessWidget {
  const _TirCard({
    required this.tir,
    required this.target,
    required this.dist,
    required this.count,
  });

  final double tir;
  final double target;
  final Map<GlucoseStatus, double> dist;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ok = tir >= target;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TEMPS DANS LA CIBLE',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: Color(0xFF5B6D6A),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  tir.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: ok ? AppColors.inRange : AppColors.high,
                  ),
                ),
                const Text(' %', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (ok ? AppColors.inRange : AppColors.high).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Objectif ≥ ${target.toStringAsFixed(0)} %',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: ok ? AppColors.inRange : AppColors.high,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Part des $count mesures comprises entre 0,70 et 1,80 g/L.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
            ),
            const SizedBox(height: 12),
            SegmentBar(
              segments: [
                (dist[GlucoseStatus.hypoglycemia]! / 100, AppColors.hypoglycemia),
                (dist[GlucoseStatus.low]! / 100, AppColors.low),
                (dist[GlucoseStatus.inRange]! / 100, AppColors.inRange),
                (dist[GlucoseStatus.high]! / 100, AppColors.high),
                (dist[GlucoseStatus.hyperglycemia]! / 100, AppColors.hyperglycemia),
              ],
              height: 16,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (final s in GlucoseStatus.values)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${s.label} ${dist[s]!.toStringAsFixed(0)} %',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF5B6D6A)),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ByContext extends StatelessWidget {
  const _ByContext({required this.readings, required this.profile});

  final List<GlucoseReading> readings;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final byContext = <MeasureContext, List<double>>{};
    for (final r in readings) {
      byContext.putIfAbsent(r.context, () => []).add(r.valueMgdl);
    }
    if (byContext.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            for (final entry in byContext.entries) ...[
              Row(
                children: [
                  Icon(entry.key.icon, size: 17, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key.label,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${formatGl(GlucoseLogic.average(entry.value), withUnit: false)} g/L',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 46,
                    child: Text(
                      '${entry.value.length} mes.',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF8A9A98)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.dist, required this.count});

  final Map<GlucoseStatus, double> dist;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            for (final s in GlucoseStatus.values)
              InfoRow(
                label: s.label,
                value:
                    '${(dist[s]! / 100 * count).round()} mesures · ${dist[s]!.toStringAsFixed(1)} %',
                valueColor: s.color,
              ),
          ],
        ),
      ),
    );
  }
}
