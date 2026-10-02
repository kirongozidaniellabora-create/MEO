import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/units.dart';
import '../../domain/app_state.dart';
import '../../widgets/common.dart';
import 'advice_page.dart';
import 'calculators_page.dart';
import 'hba1c_page.dart';
import 'meals_page.dart';
import 'settings_page.dart';
import 'stats_page.dart';

/// Onglet « Plus » (WBS lot 5.1 de la maquette) : accès à toutes les fonctions secondaires.
class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                  child: Text(
                    _initials(profile.displayName),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.diabetesType.label} · ${profile.age} ans',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          _Pill(
                            text: 'Cible ${formatGl(profile.targets.fastingMgdl, withUnit: false)} g/L',
                          ),
                          _Pill(text: 'HbA1c ${profile.targets.hba1cPercent.toStringAsFixed(1)} %'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader(title: 'Suivi', icon: Icons.insights_outlined),
        _Tile(
          icon: Icons.query_stats,
          color: AppColors.primary,
          title: 'Statistiques',
          subtitle: 'Temps dans la cible, moyennes, variabilité',
          onTap: () => _push(context, StatsPage(state: state)),
        ),
        _Tile(
          icon: Icons.restaurant_outlined,
          color: AppColors.carbs,
          title: 'Repas & glucides',
          subtitle: 'Journal des repas et répartition des glucides',
          onTap: () => _push(context, MealsPage(state: state)),
        ),
        _Tile(
          icon: Icons.bloodtype_outlined,
          color: AppColors.hba1c,
          title: 'HbA1c',
          subtitle: 'Suivi des analyses sanguines trimestrielles',
          onTap: () => _push(context, Hba1cPage(state: state)),
        ),
        const SizedBox(height: 18),
        const SectionHeader(title: 'Aide & outils', icon: Icons.help_outline),
        _Tile(
          icon: Icons.calculate_outlined,
          color: AppColors.secondary,
          title: 'Calculateurs',
          subtitle: 'Dose de correction, insuline pour glucides, hypoglycémie',
          onTap: () => _push(context, CalculatorsPage(state: state)),
        ),
        _Tile(
          icon: Icons.menu_book_outlined,
          color: AppColors.insulin,
          title: 'Conseils & éducation',
          subtitle: 'Urgences, insulinothérapie, nutrition, activité physique',
          onTap: () => _push(context, const AdvicePage()),
        ),
        const SizedBox(height: 18),
        const SectionHeader(title: 'Données', icon: Icons.settings_outlined),
        _Tile(
          icon: Icons.tune,
          color: AppColors.primary,
          title: 'Paramètres',
          subtitle: 'Objectifs, ratios insuliniques, export et réinitialisation',
          onTap: () => _push(context, SettingsPage(state: state)),
        ),
        const SizedBox(height: 18),
        const MedicalNotice(),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'DiabTrack V1.0 — projet MEO, ICAM B1',
            style: TextStyle(fontSize: 11, color: Color(0xFF8A9A98)),
          ),
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF3A4B49)),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6D6A), height: 1.3),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFB4C0BE)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
