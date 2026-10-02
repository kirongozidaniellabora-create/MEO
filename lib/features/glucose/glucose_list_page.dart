import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/units.dart';
import '../../data/models/glucose_reading.dart';
import '../../domain/app_state.dart';
import '../../domain/glucose_logic.dart';
import 'glucose_editor_page.dart';

/// Historique des mesures (WBS lot 5.3) : liste groupée par jour, filtres, actions.
class GlucoseListPage extends StatefulWidget {
  const GlucoseListPage({super.key, required this.state});

  final AppState state;

  @override
  State<GlucoseListPage> createState() => _GlucoseListPageState();
}

class _GlucoseListPageState extends State<GlucoseListPage> {
  int _range = 14;

  @override
  Widget build(BuildContext context) {
    final readings = widget.state.readingsLastDays(_range);

    // Regroupement par jour, du plus récent au plus ancien.
    final byDay = <DateTime, List<GlucoseReading>>{};
    for (final r in readings) {
      final key = DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day);
      byDay.putIfAbsent(key, () => []).add(r);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    final thresholds = widget.state.profile.thresholds;

    return Scaffold(
      body: Column(
        children: [
          _filterBar(),
          Expanded(
            child: readings.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: days.length,
                    itemBuilder: (context, i) {
                      final day = days[i];
                      final list = byDay[day]!..sort((a, b) => b.dateTime.compareTo(a.dateTime));
                      return _DayGroup(
                        day: day,
                        readings: List.unmodifiable(list),
                        thresholds: thresholds,
                        onTap: (r) => _openEditor(r),
                        onDuplicate: (r) => _duplicate(r),
                        onDelete: (r) => widget.state.deleteReading(r.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(null),
        icon: const Icon(Icons.add),
        label: const Text('Mesure'),
      ),
    );
  }

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          for (final (days, label) in const [
            (7, '7 j'),
            (14, '14 j'),
            (30, '30 j'),
            (0, 'Tout'),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: _range == days,
                onSelected: (_) => setState(() => _range = days),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune mesure sur cette période',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Enregistrez votre première glycémie : le graphique, la moyenne et le temps '
              'dans la cible apparaîtront automatiquement.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF5B6D6A), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor(GlucoseReading? r) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GlucoseEditorPage(state: widget.state, existing: r),
      ),
    );
  }

  Future<void> _duplicate(GlucoseReading r) async {
    await widget.state.duplicateReading(r);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Mesure dupliquée : ajustez la valeur puis enregistrez.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.day,
    required this.readings,
    required this.thresholds,
    required this.onTap,
    required this.onDuplicate,
    required this.onDelete,
  });

  final DateTime day;
  final List<GlucoseReading> readings;
  final GlucoseThresholds thresholds;
  final void Function(GlucoseReading) onTap;
  final void Function(GlucoseReading) onDuplicate;
  final void Function(GlucoseReading) onDelete;

  @override
  Widget build(BuildContext context) {
    final values = readings.map((r) => r.valueMgdl).toList();
    final avg = GlucoseLogic.average(values);
    final inRange = readings.where((r) => r.valueMgdl >= 70 && r.valueMgdl <= 180).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  relativeDayFr(day).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5B6D6A),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                'moy. ${formatGl(avg, withUnit: false)} · $inRange/${readings.length} dans la cible',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A9A98)),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < readings.length; i++) ...[
                if (i > 0) const Divider(indent: 68, endIndent: 12),
                _buildSwipeable(context, readings[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeable(BuildContext context, GlucoseReading r) {
    return Dismissible(
      key: ValueKey('swipe-${r.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        color: Colors.redAccent.withValues(alpha: 0.12),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) => onDelete(r),
      child: _ReadingTile(
        reading: r,
        thresholds: thresholds,
        onTap: () => onTap(r),
        onDuplicate: () => onDuplicate(r),
      ),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  const _ReadingTile({
    required this.reading,
    required this.thresholds,
    required this.onTap,
    required this.onDuplicate,
  });

  final GlucoseReading reading;
  final GlucoseThresholds thresholds;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final status = GlucoseStatus.fromValue(reading.valueMgdl, thresholds);
    final subtitle = _subtitle();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(reading.context.icon, size: 20, color: status.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        hhmm(reading.dateTime),
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          reading.context.label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8A9A98)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatGl(reading.valueMgdl),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: status.color),
            ),
            PopupMenuButton<String>(
              tooltip: 'Actions',
              icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF8A9A98)),
              onSelected: (v) {
                if (v == 'edit') onTap();
                if (v == 'copy') onDuplicate();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Modifier')),
                PopupMenuItem(value: 'copy', child: Text('Dupliquer')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    if (reading.exerciseMinutes > 0) parts.add('${reading.exerciseMinutes} min sport');
    if (reading.sleepHours != null) parts.add('sommeil ${formatHours(reading.sleepHours!)}');
    if (reading.stressLevel > 0) parts.add('stress');
    if (reading.note.isNotEmpty) parts.add(reading.note);
    return parts.join(' · ');
  }
}
