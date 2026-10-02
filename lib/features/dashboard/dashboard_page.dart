import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/units.dart';
import '../../data/models/glucose_reading.dart';
import '../../domain/app_state.dart';
import '../../domain/glucose_logic.dart';
import '../../navigation.dart';
import '../../widgets/common.dart';

/// Tableau de bord (WBS lot 6) : la « carte principale » du produit.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final latest = state.latest;
    final today = state.todayReadings;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _Greeting(name: profile.displayName),
        const SizedBox(height: 12),
        _LatestReadingCard(reading: latest, state: state),
        const SizedBox(height: 16),
        if (latest != null && GlucoseLogic.status(latest, profile).isUrgent)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _AlertBanner(status: GlucoseLogic.status(latest, profile), reading: latest),
          ),
        const SectionHeader(title: 'Courbe du jour', icon: Icons.show_chart),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (today.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        'Aucune mesure aujourd’hui',
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF8A9A98)),
                      ),
                    ),
                  )
                else
                  GlucoseChart(readings: today, profile: profile),
                if (today.length >= 2) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Text(
                      '${today.length} mesures · moyenne ${formatGl(state.todayAverageMgdl)}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A9A98)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader(title: 'Aujourd’hui', icon: Icons.today_outlined),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Mesures',
                value: '${today.length}',
                unit: '',
                icon: Icons.water_drop_outlined,
                caption: 'enregistrées',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'Dans la cible',
                value: today.isEmpty ? '—' : state.todayTimeInRange.toStringAsFixed(0),
                unit: '%',
                icon: Icons.check_circle_outline,
                color: AppColors.inRange,
                caption: '70–180 mg/dL',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Insuline',
                value: formatUnits(state.todayInsulinTotal),
                icon: Icons.vaccines_outlined,
                color: AppColors.insulin,
                caption: 'dose ${formatUnits(profile.insulin.dailyPrescribedUnits)}/j',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'Glucides',
                value: state.todayCarbsTotal.toStringAsFixed(0),
                unit: 'g',
                icon: Icons.restaurant_outlined,
                color: AppColors.carbs,
                caption: '${state.todayMeals.length} repas',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader(title: 'Actions rapides', icon: Icons.bolt_outlined),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.water_drop_outlined,
                label: 'Glycémie',
                color: AppColors.primary,
                onTap: () => openGlucoseEditor(context, state),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.vaccines_outlined,
                label: 'Injection',
                color: AppColors.insulin,
                onTap: () => openInsulinEditor(context, state),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.restaurant_outlined,
                label: 'Repas',
                color: AppColors.carbs,
                onTap: () => openMealEditor(context, state),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader(title: 'Dernières mesures', icon: Icons.history),
        if (state.readings.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text(
                    'Votre suivi commence ici',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enregistrez une glycémie en 4 gestes, ou chargez le jeu de démonstration '
                    'depuis l’onglet « Plus » pour découvrir l’application.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF5B6D6A), height: 1.4),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < state.readings.take(4).length; i++) ...[
                  if (i > 0) const Divider(indent: 68, endIndent: 12),
                  _MiniReadingTile(reading: state.readings[i], state: state),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${greetingFr()} $name',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              Text(
                dateFullFr(DateTime.now()),
                style: const TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite, color: AppColors.primary, size: 22),
        ),
      ],
    );
  }
}

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard({required this.reading, required this.state});

  final GlucoseReading? reading;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    if (reading == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Icon(Icons.water_drop_outlined, size: 46, color: AppColors.primary),
              const SizedBox(height: 10),
              const Text(
                'Aucune glycémie enregistrée',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Touchez « Mesure » en haut pour commencer.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF5B6D6A)),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => openGlucoseEditor(context, state),
                icon: const Icon(Icons.add),
                label: const Text('Première mesure'),
              ),
            ],
          ),
        ),
      );
    }

    final r = reading!;
    final status = GlucoseLogic.status(r, profile);

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              status.color.withValues(alpha: 0.16),
              status.color.withValues(alpha: 0.04),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'DERNIÈRE MESURE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: Color(0xFF5B6D6A),
                  ),
                ),
                const Spacer(),
                Text(
                  relativeTimeFr(r.dateTime),
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            BigValue(mgdl: r.valueMgdl, color: status.color),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(status: status),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${r.context.label} · ${hhmm(r.dateTime)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openGlucoseEditor(context, state, r),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Modifier'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => openGlucoseEditor(context, state),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Mesure'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.status, required this.reading});

  final GlucoseStatus status;
  final GlucoseReading reading;

  @override
  Widget build(BuildContext context) {
    final isHypo = status == GlucoseStatus.hypoglycemia;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: status.color.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: status.color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHypo ? 'Hypoglycémie détectée' : 'Hyperglycémie détectée',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isHypo
                  ? 'Mesurez à nouveau dans 15 minutes après correction. Si vous ne pouvez pas '
                        'vous corriger ou si les symptômes persistent, appelez le 15 (SAMU) '
                        'ou le 112 depuis l’Union européenne.'
                  : 'Buvez de l’eau, surveillez les symptômes et recontrôlez dans 2 heures. '
                        'En cas de vomissements ou de douleurs abdominales, consultez sans délai.',
              style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF3A2A2A)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniReadingTile extends StatelessWidget {
  const _MiniReadingTile({required this.reading, required this.state});

  final GlucoseReading reading;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final status = GlucoseLogic.status(reading, state.profile);
    return ListTile(
      onTap: () => openGlucoseEditor(context, state, reading),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(reading.context.icon, size: 18, color: status.color),
      ),
      title: Text(
        formatGl(reading.valueMgdl),
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: status.color),
      ),
      subtitle: Text(
        '${hhmm(reading.dateTime)} · ${reading.context.label}',
        style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
      ),
      trailing: Icon(status.icon, size: 18, color: status.color),
    );
  }
}
