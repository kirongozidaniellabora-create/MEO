import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/units.dart';
import '../../data/models/glucose_reading.dart';
import '../../data/models/profile.dart';
import '../../domain/glucose_logic.dart';

/// Graphique des mesures de glycémie (WBS lot 6.2).
///
/// Dessiné **à la main** avec un `CustomPainter` : aucune dépendance à une librairie de
/// graphiques. Choix assumé pour réduire le risque R3 (dépendance réseau) — et pour montrer
/// que l'on sait faire sans bibliothèque.
class GlucoseChart extends StatelessWidget {
  const GlucoseChart({
    super.key,
    required this.readings,
    required this.profile,
    this.height = 190,
    this.showAxisLabels = true,
  });

  final List<GlucoseReading> readings;
  final Profile profile;
  final double height;
  final bool showAxisLabels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _GlucoseChartPainter(
          readings: readings,
          thresholds: profile.thresholds,
          showAxisLabels: showAxisLabels,
        ),
      ),
    );
  }
}

class _GlucoseChartPainter extends CustomPainter {
  _GlucoseChartPainter({
    required this.readings,
    required this.thresholds,
    required this.showAxisLabels,
  });

  final List<GlucoseReading> readings;
  final GlucoseThresholds thresholds;
  final bool showAxisLabels;

  static const _labelWidth = 34.0;
  static const _bottomAxis = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final t = thresholds;
    final minValue = 50.0;
    final maxValue = 300.0;

    final plotLeft = showAxisLabels ? _labelWidth : 0.0;
    final plotWidth = size.width - plotLeft;
    final plotHeight = size.height - _bottomAxis;
    if (plotWidth <= 0 || plotHeight <= 0) return;

    double yOf(double mgdl) {
      final clamped = mgdl.clamp(minValue, maxValue);
      // Axe inversé : une glycémie haute est en haut.
      return plotHeight - (clamped - minValue) / (maxValue - minValue) * plotHeight;
    }

    // ---- Zones de statut -----------------------------------------------------
    void band(double from, double to, Color color) {
      final y1 = yOf(from.clamp(minValue, maxValue));
      final y2 = yOf(to.clamp(minValue, maxValue));
      final rect = Rect.fromLTRB(plotLeft, math.min(y1, y2), size.width, math.max(y1, y2));
      canvas.drawRect(rect, Paint()..color = color);
    }

    band(minValue, t.hypoLimit, AppColors.hypoglycemia.withValues(alpha: 0.10));
    band(t.hypoLimit, t.targetLow, AppColors.low.withValues(alpha: 0.08));
    band(t.targetLow, t.targetHigh, AppColors.inRange.withValues(alpha: 0.10));
    band(t.targetHigh, t.hyperLimit, AppColors.high.withValues(alpha: 0.08));
    band(t.hyperLimit, maxValue, AppColors.hyperglycemia.withValues(alpha: 0.10));

    // ---- Graduations ---------------------------------------------------------
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5D3)
      ..strokeWidth = 1;
    const ticks = [50.0, 100.0, 150.0, 200.0, 250.0, 300.0];
    for (final tick in ticks) {
      final y = yOf(tick);
      canvas.drawLine(Offset(plotLeft, y), Offset(size.width, y), gridPaint);
      if (showAxisLabels) {
        final tp = TextPainter(
          text: TextSpan(
            text: tick.toStringAsFixed(0),
            style: const TextStyle(fontSize: 9, color: Color(0xFF7B8B88)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(plotLeft - tp.width - 4, y - tp.height / 2));
      }
    }

    // ---- Bornes de la cible --------------------------------------------------
    final targetTop = yOf(t.targetHigh);
    final targetBottom = yOf(t.targetLow);
    canvas.drawLine(
      Offset(plotLeft, targetTop),
      Offset(size.width, targetTop),
      Paint()
        ..color = AppColors.inRange.withValues(alpha: 0.55)
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      Offset(plotLeft, targetBottom),
      Offset(size.width, targetBottom),
      Paint()
        ..color = AppColors.inRange.withValues(alpha: 0.55)
        ..strokeWidth = 1.4,
    );

    if (readings.length < 2) {
      _paintEmptyHint(canvas, size, plotLeft);
      return;
    }

    // ---- Échelle horizontale : heure de la première à la dernière mesure ------
    final first = readings.first.dateTime;
    final last = readings.last.dateTime;
    final spanMs = math.max(last.difference(first).inMilliseconds, 1);

    double xOf(DateTime d) {
      final ratio = d.difference(first).inMilliseconds / spanMs;
      return plotLeft + ratio * plotWidth;
    }

    // ---- Courbe --------------------------------------------------------------
    final sorted = [...readings]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final path = Path();
    for (var i = 0; i < sorted.length; i++) {
      final p = Offset(xOf(sorted[i].dateTime), yOf(sorted[i].valueMgdl));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        final prev = Offset(xOf(sorted[i - 1].dateTime), yOf(sorted[i - 1].valueMgdl));
        final mid = Offset((prev.dx + p.dx) / 2, (prev.dy + p.dy) / 2);
        path.quadraticBezierTo(mid.dx, mid.dy, p.dx, p.dy);
      }
    }

    final bounds = path.getBounds().inflate(20);
    final area = Path.from(path)
      ..lineTo(xOf(last), plotHeight)
      ..lineTo(xOf(first), plotHeight)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTRB(0, bounds.top, 0, plotHeight)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ---- Points --------------------------------------------------------------
    for (final r in sorted) {
      final center = Offset(xOf(r.dateTime), yOf(r.valueMgdl));
      final status = GlucoseStatus.fromValue(r.valueMgdl, thresholds);
      canvas.drawCircle(center, 6.5, Paint()..color = Colors.white);
      canvas.drawCircle(center, 4.5, Paint()..color = status.color);
    }

    // ---- Étiquettes des extrémités -------------------------------------------
    if (showAxisLabels) {
      _label(canvas, hhmm(first), Offset(plotLeft, plotHeight + 3), alignLeft: true);
      _label(
        canvas,
        hhmm(last),
        Offset(size.width - 34, plotHeight + 3),
        alignLeft: false,
      );
    }
  }

  void _paintEmptyHint(Canvas canvas, Size size, double plotLeft) {
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Pas assez de mesures pour tracer la courbe',
        style: TextStyle(fontSize: 11, color: Color(0xFF7B8B88)),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - plotLeft - 8);
    tp.paint(canvas, Offset(plotLeft + (size.width - plotLeft - tp.width) / 2,
        (size.height - _bottomAxis - tp.height) / 2));
  }

  void _label(Canvas canvas, String text, Offset at, {required bool alignLeft}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 9, color: Color(0xFF7B8B88)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(alignLeft ? at.dx : at.dx, at.dy));
  }

  /// Redessine si les valeurs, les dates, les seuils ou l'affichage ont changé.
  ///
  /// Comparer uniquement `readings.length` ne suffit pas : éditer la valeur d'une
  /// mesure (ou la déplacer dans le temps) garde la même longueur, et le
  /// graphique affichait alors une courbe périmée.
  @override
  bool shouldRepaint(covariant _GlucoseChartPainter old) {
    if (old.showAxisLabels != showAxisLabels) return true;
    if (old.readings.length != readings.length) return true;
    if (old.thresholds != thresholds) return true;
    for (var i = 0; i < readings.length; i++) {
      final a = old.readings[i];
      final b = readings[i];
      if (a.valueMgdl != b.valueMgdl || a.dateTime != b.dateTime) {
        return true;
      }
    }
    return false;
  }
}

/// Badge de statut : couleur + icône + libellé (lisibilité garantie).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.compact = false});

  final GlucoseStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: compact ? 12 : 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Petite carte d'indicateur réutilisable.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.icon,
    this.color,
    this.caption,
  });

  final String label;
  final String value;
  final String unit;
  final IconData? icon;
  final Color? color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EAE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: color ?? AppColors.primary),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: color ?? AppColors.ink,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF5B6D6A)),
                ),
              ],
            ],
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                caption!,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF8A9A98)),
              ),
            ),
        ],
      ),
    );
  }
}

/// En-tête de section réutilisable.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.icon});

  final String title;
  final Widget? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Barre segmentée horizontale (répartition 5 statuts / temps dans la cible).
class SegmentBar extends StatelessWidget {
  const SegmentBar({
    super.key,
    required this.segments,
    this.height = 14,
    this.showLegend = true,
  });

  /// Liste de (valeur 0-1, couleur).
  final List<(double, Color)> segments;
  final double height;
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (s, e) => s + e.$1);
    if (total <= 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEDF1F0),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Aucune donnée sur la période',
          style: TextStyle(fontSize: 10, color: Color(0xFF8A9A98)),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Row(
        children: [
          for (final (value, color) in segments)
            if (value > 0)
              Expanded(
                flex: math.max(1, (value / total * 1000).round()),
                child: Container(height: height, color: color),
              ),
        ],
      ),
    );
  }
}

/// Ligne « libellé / valeur » utilisée dans les fiches de détail.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF5B6D6A)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avertissement médical réutilisable (objectif O7, risque R8).
class MedicalNotice extends StatelessWidget {
  const MedicalNotice({super.key, this.compact = false, this.text});

  final bool compact;
  final String? text;

  static const defaultText =
      'Cette application ne remplace pas un avis médical et ne modifie aucune prescription. '
      'Adaptez toujours vos doses et vos objectifs avec votre médecin ou votre diabétologue.';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF8D6E00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text ?? defaultText,
              style: TextStyle(
                fontSize: compact ? 11 : 12.5,
                height: 1.35,
                color: const Color(0xFF5D4A00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Affichage « 1,28 g/L » mis en valeur (carte principale du tableau de bord).
class BigValue extends StatelessWidget {
  const BigValue({super.key, required this.mgdl, required this.color, this.size = 54});

  final double mgdl;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gl = mgdlToGl(mgdl);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          gl.toStringAsFixed(2),
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(width: 5),
        Text('g/L', style: TextStyle(fontSize: size * 0.34, color: color.withValues(alpha: 0.8))),
      ],
    );
  }
}
