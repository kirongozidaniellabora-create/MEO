import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/units.dart';
import '../../data/models/insulin_meal_hba1c.dart';
import '../../domain/app_state.dart';
import '../../navigation.dart';
import '../../widgets/common.dart';

/// Journal du traitement (WBS lot 7) : dose du jour, jauge face à la dose prescrite.
class InsulinPage extends StatefulWidget {
  const InsulinPage({super.key, required this.state});

  final AppState state;

  @override
  State<InsulinPage> createState() => _InsulinPageState();
}

class _InsulinPageState extends State<InsulinPage> {
  int _range = 7;

  @override
  Widget build(BuildContext context) {
    final prescribed = widget.state.profile.insulin.dailyPrescribedUnits;
    final total = widget.state.todayInsulinTotal;
    final ratio = prescribed > 0 ? (total / prescribed).clamp(0.0, 1.5) : 0.0;
    final over = prescribed > 0 && total > prescribed;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: _range - 1));
    final entries = widget.state.insulinEntries
        .where((e) => !e.dateTime.isBefore(start))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DOSE DU JOUR',
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
                              total.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 46,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                color: over ? AppColors.hyperglycemia : AppColors.insulin,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('U', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text(
                              'sur ${prescribed.toStringAsFixed(0)} U prescrites',
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF5B6D6A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: ratio > 1 ? 1 : ratio,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFEDF1F0),
                            valueColor: AlwaysStoppedAnimation(
                              over ? AppColors.hyperglycemia : AppColors.insulin,
                            ),
                          ),
                        ),
                        if (over) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Vous avez dépassé la dose quotidienne prescrite de '
                            '${(total - prescribed).toStringAsFixed(1)} U. Vérifiez, et contactez '
                            'votre soignant si nécessaire.',
                            style: const TextStyle(fontSize: 12, color: AppColors.hyperglycemia),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Basal',
                        value: formatUnits(
                          widget.state.todayInsulin
                              .where((e) => e.kind == InsulinKind.basal)
                              .fold<double>(0, (s, e) => s + e.units),
                        ),
                        icon: Icons.schedule,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        label: 'Bolus',
                        value: formatUnits(
                          widget.state.todayInsulin
                              .where((e) => e.kind == InsulinKind.bolus)
                              .fold<double>(0, (s, e) => s + e.units),
                        ),
                        icon: Icons.bolt,
                        color: AppColors.insulin,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(child: SectionHeader(title: 'Injections', icon: Icons.vaccines_outlined)),
                    for (final (d, label) in const [(1, '24 h'), (7, '7 j'), (30, '30 j')])
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text(label),
                          visualDensity: VisualDensity.compact,
                          selected: _range == d,
                          onSelected: (_) => setState(() => _range = d),
                        ),
                      ),
                  ],
                ),
                if (entries.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          _range == 1
                              ? 'Aucune injection enregistrée aujourd’hui'
                              : 'Aucune injection sur les $_range derniers jours',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF5B6D6A)),
                        ),
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < entries.length; i++) ...[
                    if (i > 0) const Divider(indent: 16, endIndent: 16),
                    _InsulinTile(
                      entry: entries[i],
                      onTap: () => openInsulinEditor(context, widget.state, entries[i]),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openInsulinEditor(context, widget.state),
        icon: const Icon(Icons.add),
        label: const Text('Injection'),
        backgroundColor: AppColors.insulin,
      ),
    );
  }
}

class _InsulinTile extends StatelessWidget {
  const _InsulinTile({required this.entry, required this.onTap});

  final InsulinEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = entry.kind == InsulinKind.basal ? AppColors.secondary : AppColors.insulin;
    final subtitle = [
      if (entry.productName.isNotEmpty) entry.productName,
      if (entry.isCorrection) 'correction',
      if (entry.penLot.isNotEmpty) 'lot ${entry.penLot}',
    ].join(' · ');

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(entry.kind.icon, size: 20, color: color),
      ),
      title: Text(
        formatUnits(entry.units),
        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: color),
      ),
      subtitle: Text(
        subtitle.isEmpty ? entry.kind.label : subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            hhmm(entry.dateTime),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          Text(
            relativeDayFr(entry.dateTime),
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF8A9A98)),
          ),
        ],
      ),
    );
  }
}
