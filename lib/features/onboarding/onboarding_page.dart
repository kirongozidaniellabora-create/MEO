import 'package:flutter/material.dart';

import '../../data/models/profile.dart';

/// Onboarding (WBS lot 4.2) : 4 pages, exécuté une seule fois.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onDone});

  final void Function(Profile profile) onDone;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _index = 0;
  DiabetesType _type = DiabetesType.type2;
  int _age = 35;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      widget.onDone(
        Profile(
          displayName: _nameController.text.trim().isEmpty
              ? 'Moi'
              : _nameController.text.trim(),
          age: _age,
          diabetesType: _type,
        ),
      );
    }
  }

  void _back() {
    if (_index == 0) return;
    _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (_index > 0)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Précédent',
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Row(
                      children: [
                        for (var i = 0; i < 4; i++)
                          Expanded(
                            child: Container(
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i <= _index
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFDDE6E4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [_intro(), _name(), _typePage(), _disclaimer()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: FilledButton(
                onPressed: _next,
                child: Text(_index == 3 ? 'Commencer' : 'Continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page({required IconData icon, required String title, required String subtitle, Widget? child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF5B6D6A)),
          ),
          if (child != null) ...[const SizedBox(height: 24), child],
        ],
      ),
    );
  }

  Widget _intro() => _page(
    icon: Icons.water_drop_outlined,
    title: 'Bienvenue sur DiabTrack',
    subtitle:
        'Votre carnet de suivi du diabète, dans votre poche. Enregistrez vos glycémies, vos '
        'insulines et vos repas en quelques secondes, et visualisez votre équilibre jour après jour.\n\n'
        'Toutes vos données restent sur votre téléphone : rien n’est envoyé sur Internet.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Bullet(icon: Icons.timer_outlined, text: 'Une glycémie enregistrée en moins de 20 secondes'),
        _Bullet(icon: Icons.insights_outlined, text: 'Temps dans la cible, moyennes et variabilité'),
        _Bullet(icon: Icons.lock_outline, text: 'Stockage 100 % local, sans compte ni serveur'),
      ],
    ),
  );

  Widget _name() => _page(
    icon: Icons.person_outline,
    title: 'Faisons connaissance',
    subtitle: 'Comment souhaitez-vous être appelé(e) dans l’application ?',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Prénom ou surnom', hintText: 'Moi'),
        ),
        const SizedBox(height: 22),
        const Text('Votre âge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _age.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: '$_age ans',
                onChanged: (v) => setState(() => _age = v.round()),
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                '$_age',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _typePage() => _page(
    icon: Icons.medical_information_outlined,
    title: 'Quel est votre diabète ?',
    subtitle:
        'Cette information sert uniquement à adapter les libellés. Elle pourra être modifiée '
        'dans les paramètres.',
    child: Column(
      children: [
        for (final t in DiabetesType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _type = t),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _type == t
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
                      : const Color(0xFFF1F5F4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _type == t
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFFE2EAE8),
                    width: _type == t ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(t.icon, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.label,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text(
                            t.subtitle,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF5B6D6A)),
                          ),
                        ],
                      ),
                    ),
                    if (_type == t)
                      Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _disclaimer() => _page(
    icon: Icons.health_and_safety_outlined,
    title: 'Avant de commencer',
    subtitle:
        'DiabTrack est un outil d’**accompagnement**, pas un dispositif médical. '
        'Il ne fait aucun diagnostic et ne modifie aucune prescription.',
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bullet(
          icon: Icons.warning_amber_rounded,
          text: 'Les doses calculées sont **indicatives** : validez-les avec votre soignant.',
        ),
        _Bullet(
          icon: Icons.menu_book_outlined,
          text: 'Une section « Conseils » founderce chaque situation d’urgence.',
        ),
        _Bullet(
          icon: Icons.privacy_tip_outlined,
          text: 'Vos données sont enregistrées **uniquement sur ce téléphone**. '
              'Vous pouvez les exporter à tout moment.',
        ),
      ],
    ),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    var start = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > start) {
        spans.add(TextSpan(text: text.substring(start, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
        ),
      );
      start = m.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: spans),
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
