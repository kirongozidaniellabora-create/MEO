import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models/insulin_meal_hba1c.dart';
import '../../domain/app_state.dart';
import '../../widgets/common.dart';

/// Suivi de l'HbA1c (WBS lot 9.4) : reflet de l'équilibre sur 2 à 3 mois.
class Hba1cPage extends StatefulWidget {
  const Hba1cPage({super.key, required this.state});

  final AppState state;

  @override
  State<Hba1cPage> createState() => _Hba1cPageState();
}

class _Hba1cPageState extends State<Hba1cPage> {
  @override
  Widget build(BuildContext context) {
    final records = widget.state.hba1cRecords;
    final target = widget.state.profile.targets.hba1cPercent;
    final latest = records.isEmpty ? null : records.first;

    return Scaffold(
      appBar: AppBar(title: const Text('HbA1c')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const MedicalNotice(
            compact: true,
            text: 'L’HbA1c se mesure par une analyse sanguine tous les 3 mois environ. '
                'Saisissez ici les résultats de vos bilans : l’application ne peut pas les '
                'calculer toute seule.',
          ),
          const SizedBox(height: 16),
          if (latest != null) ...[
            Card(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _color(latest.valuePercent, target).withValues(alpha: 0.08),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DERNIER RÉSULTAT',
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
                              latest.valuePercent.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                color: _color(latest.valuePercent, target),
                              ),
                            ),
                            const Text(
                              ' %',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5B6D6A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dateLongFr(latest.date)} · objectif ${target.toStringAsFixed(1)} %',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      _color(latest.valuePercent, target) == AppColors.inRange
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      size: 34,
                      color: _color(latest.valuePercent, target),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const SectionHeader(title: 'Évolution', icon: Icons.timeline),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: records.length < 2
                  ? const SizedBox(
                      height: 90,
                      child: Center(
                        child: Text(
                          'Au moins deux résultats sont nécessaires pour tracer une courbe',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF8A9A98)),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 170,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _Hba1cChartPainter(records: records, target: target),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Résultats enregistrés', icon: Icons.list_alt),
          if (records.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Aucun résultat saisi',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF5B6D6A)),
                  ),
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < records.length; i++) ...[
                    if (i > 0) const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _color(records[i].valuePercent, target).withValues(alpha: 0.13),
                        child: Text(
                          records[i].valuePercent.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: _color(records[i].valuePercent, target),
                          ),
                        ),
                      ),
                      title: Text(
                        '${dateLongFr(records[i].date)}${records[i].labName.isEmpty ? '' : ' · ${records[i].labName}'}',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                      subtitle: Text(
                        records[i].valuePercent <= target
                            ? 'Objectif atteint'
                            : 'Au-dessus de l’objectif de ${target.toStringAsFixed(1)} %',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
                      ),
                      trailing: IconButton(
                        tooltip: 'Supprimer',
                        icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFB4C0BE)),
                        onPressed: () => widget.state.deleteHba1c(records[i].id),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un résultat'),
          ),
        ],
      ),
    );
  }

  static Color _color(double value, double target) =>
      value <= target ? AppColors.inRange : AppColors.high;

  Future<void> _add() async {
    final result = await showDialog<({double value, DateTime date, String lab})>(
      context: context,
      builder: (ctx) => const _Hba1cDialog(),
    );
    if (result == null) return;
    await widget.state.addHba1c(
      Hba1cRecord(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        date: result.date,
        valuePercent: result.value,
        labName: result.lab,
      ),
    );
  }
}

class _Hba1cDialog extends StatefulWidget {
  const _Hba1cDialog();

  @override
  State<_Hba1cDialog> createState() => _Hba1cDialogState();
}

class _Hba1cDialogState extends State<_Hba1cDialog> {
  final _value = TextEditingController(text: '7.0');
  final _lab = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _value.dispose();
    _lab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsed = double.tryParse(_value.text.replaceAll(',', '.'));
    final valid = parsed != null && parsed >= 3.5 && parsed <= 20;
    return AlertDialog(
      title: const Text('Nouveau résultat d’HbA1c'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Valeur en %', hintText: '7.0'),
          ),
          if (parsed != null && !valid)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Valeur hors limites plausibles (3,5 à 20 %).',
                style: TextStyle(fontSize: 11.5, color: Colors.redAccent),
              ),
            ),
          const SizedBox(height: 10),
          TextField(
            controller: _lab,
            decoration: const InputDecoration(labelText: 'Laboratoire (facultatif)'),
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(dateLongFr(_date)),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                lastDate: DateTime.now(),
                locale: const Locale('fr'),
              );
              if (d != null) setState(() => _date = d);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: valid
              ? () => Navigator.pop(
                  context,
                  (value: parsed, date: _date, lab: _lab.text.trim()),
                )
              : null,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

class _Hba1cChartPainter extends CustomPainter {
  _Hba1cChartPainter({required this.records, required this.target});

  /// Les plus récents d'abord (ordre du modèle) : on inverse pour le tracé chronologique.
  final List<Hba1cRecord> records;
  final double target;

  @override
  void paint(Canvas canvas, Size size) {
    final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
    var min = 4.5;
    var max = 9.5;
    for (final r in sorted) {
      min = r.valuePercent < min ? r.valuePercent : min;
      max = r.valuePercent > max ? r.valuePercent : max;
    }
    min -= 0.4;
    max += 0.4;
    const leftPad = 30.0;
    const bottomPad = 20.0;
    final plotW = size.width - leftPad - 6;
    final plotH = size.height - bottomPad - 6;
    if (plotW <= 0 || plotH <= 0) return;

    double yOf(double v) => 6 + plotH - (v - min) / (max - min) * plotH;
    double xOf(int i) =>
        sorted.length == 1 ? leftPad + plotW / 2 : leftPad + i / (sorted.length - 1) * plotW;

    // Graduations
    final grid = Paint()
      ..color = const Color(0xFFE2EAE8)
      ..strokeWidth = 1;
    for (var v = min.ceil().toDouble(); v <= max; v += 1) {
      final y = yOf(v);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - 6, y), grid);
      final tp = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(0),
          style: const TextStyle(fontSize: 9, color: Color(0xFF7B8B88)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    // Objectif
    final ty = yOf(target);
    final dash = Paint()
      ..color = AppColors.inRange.withValues(alpha: 0.7)
      ..strokeWidth = 1.4;
    for (var x = leftPad; x < size.width - 6; x += 8) {
      canvas.drawLine(Offset(x, ty), Offset(x + 4, ty), dash);
    }

    // Courbe
    final path = Path();
    for (var i = 0; i < sorted.length; i++) {
      final p = Offset(xOf(i), yOf(sorted[i].valuePercent));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        final prev = Offset(xOf(i - 1), yOf(sorted[i - 1].valuePercent));
        final mid = Offset((prev.dx + p.dx) / 2, (prev.dy + p.dy) / 2);
        path.quadraticBezierTo(mid.dx, mid.dy, p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.hba1c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < sorted.length; i++) {
      final c = Offset(xOf(i), yOf(sorted[i].valuePercent));
      canvas.drawCircle(c, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        c,
        3.4,
        Paint()..color = sorted[i].valuePercent <= target ? AppColors.inRange : AppColors.high,
      );
      if (i == 0 || i == sorted.length - 1) {
        final tp = TextPainter(
          text: TextSpan(
            text: dateLongFr(sorted[i].date),
            style: const TextStyle(fontSize: 8.5, color: Color(0xFF7B8B88)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(c.dx - tp.width / 2, size.height - bottomPad + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Hba1cChartPainter old) =>
      old.records.length != records.length || old.target != target;
}
