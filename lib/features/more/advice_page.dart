import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/common.dart';

/// Contenu éducatif (WBS lot 11).
///
/// Contenu **général et non prescriptif**, avec mention des sources à la fin de chaque fiche
/// (objectif SMART **O7**, risque **R8**).
class AdvicePage extends StatelessWidget {
  const AdvicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conseils & éducation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const MedicalNotice(
            text: 'Ces fiches sont informative. En cas de doute ou de symptôme, '
                'demandez l’avis de votre médecin ou de votre diabétologue, ou appelez le 15.',
          ),
          const SizedBox(height: 18),
          for (final category in adviceCategories) ...[
            SectionHeader(title: category.title, icon: category.icon),
            for (final article in category.articles)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AdviceCard(article: article),
              ),
            const SizedBox(height: 10),
          ],
          const SectionHeader(title: 'Sources', icon: Icons.menu_book_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Le contenu s’inspire des référentiels publics :',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  ..._sources.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $s',
                        style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF3A4B49)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Contenu rédigé à titre pédagogique pour un projet scolaire, '
                    'sans validation médicale.',
                    style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.article});

  final AdviceArticle article;

  @override
  Widget build(BuildContext context) {
    final accent = switch (article.urgency) {
      AdviceUrgency.emergency => AppColors.hypoglycemia,
      AdviceUrgency.important => AppColors.low,
      AdviceUrgency.info => AppColors.primary,
    };

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(article.icon, size: 20, color: accent),
          ),
          title: Text(
            article.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          subtitle: article.urgency == AdviceUrgency.emergency
              ? const Text(
                  'URGENCE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.hypoglycemia,
                    letterSpacing: 0.6,
                  ),
                )
              : null,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                article.body,
                style: const TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xFF2E3E3C)),
              ),
            ),
            if (article.steps.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (var i = 0; i < article.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accent),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          article.steps[i],
                          style: const TextStyle(fontSize: 12.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Source : ${article.source}',
                style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AdviceUrgency { emergency, important, info }

class AdviceArticle {
  const AdviceArticle({
    required this.title,
    required this.icon,
    required this.urgency,
    required this.body,
    this.steps = const [],
    required this.source,
  });

  final String title;
  final IconData icon;
  final AdviceUrgency urgency;
  final String body;
  final List<String> steps;
  final String source;
}

class AdviceCategory {
  const AdviceCategory({required this.title, required this.icon, required this.articles});

  final String title;
  final IconData icon;
  final List<AdviceArticle> articles;
}

const _sources = [
  'Haute Autorité de Santé (HAS) — « Parcours de soins des patients vivant avec un diabète »',
  'Société Française de Diabétologie (SFD) — recommandations de laialectologie',
  'Inserm / ameli.fr — informations sur le diabète etандhypoglycémie',
  'OMS — « Gestion du diabète en soins primaires »',
];

final adviceCategories = <AdviceCategory>[
  AdviceCategory(
    title: 'Urgences',
    icon: Icons.emergency_outlined,
    articles: [
      AdviceArticle(
        title: 'Hypoglycémie : que faire immédiatement',
        icon: Icons.warning_amber_rounded,
        urgency: AdviceUrgency.emergency,
        body:
            'L’hypoglycémie (glycémie < 0,70 g/L) peut être brutale et mettre en danger. '
            'Le réflexe se dit « 15-15 » : 15 g de glucides rapides, attendre 15 minutes, '
            'recontrôler. Attention : compter les glucides rapides dans les objectifs d’insuline, '
            'sinon on risque un rebond hypoglycémique.',
        steps: [
          'Si la personne est consciente : donner 15 g de glucides rapides (3 comprimés de sucre, '
              '15 cl de jus de fruit, ou 15 cl de soda sucré). '
              'Un soda non sucré ne contient pas de glucides et ne sert donc pas ici.',
          'Attendre 15 minutes puis recontrôler la glycémie.',
          'Si elle est toujours basse, répéter une fois.',
          'Une fois la glycémie remontée, prendre une collation plus complexe (pain, fromage) '
              'pour éviter un rebond.',
          'Si la personne est inconsciente ou fait des convulsions : ne rien donner par la bouche, '
              'la mettre sur le côté et appeler le 15 ou le 112 immédiatement.',
        ],
        source: 'SFD, recommandations d’éducation thérapeutique',
      ),
      AdviceArticle(
        title: 'Hyperglycémie : quand s’inquiéter',
        icon: Icons.report_problem_outlined,
        urgency: AdviceUrgency.important,
        body:
            'Une glycémie élevée isolée est fréquente (repas riche, oubli d’insuline, stress, '
            'maladie). Elle devient urgente si elle s’associe à des vomissements, '
            'une douleur abdominale, une respiration ample et rapide ou une somnolence : '
            'ces signes évoquent une acidocétose et nécessitent un avis médical immédiat.',
        steps: [
          'Boire de l’eau (petites gorgées fréquentes).',
          'Recontrôler dans 2 heures.',
          'Si vous êtes sous insuline et qu’une dose a été oubliée, ne la doublez pas sans avis.',
          'En cas de vomissements ou de signes d’acidose, consultez sans délai ou appelez le 15.',
        ],
        source: 'SFD',
      ),
      AdviceArticle(
        title: 'Quand appeler le 15 / le 112',
        icon: Icons.phone_in_talk_outlined,
        urgency: AdviceUrgency.emergency,
        body:
            'Appelez immédiatement en cas de : perte de connaissance ou convulsions, '
            'confusion ou propos incohérents, vomissements répétés impossibles à contrôler, '
            'douleur thoracique, essoufflement au repos, déshydratation sévère, '
            'ou glycémie > 3,00 g/L persistante avec symptômes.',
        steps: [
          'France : 15 (SAMU) ou 112 (numéro d’urgence européen).',
          'Restez auprès de la personne, ne la laissez pas seule.',
          'Ayez à portée de main la liste de ses traitements et son carnet de suivi.',
        ],
        source: 'Numéro 15 / 112 — information publique',
      ),
    ],
  ),
  AdviceCategory(
    title: 'Insulinothérapie',
    icon: Icons.vaccines_outlined,
    articles: [
      AdviceArticle(
        title: 'Basal et bolus : les deux piliers',
        icon: Icons.timeline,
        urgency: AdviceUrgency.info,
        body:
            'L’insuline basale couvre les besoins de fond, jour et nuit, et maintient la glycémie '
            'stable entre les repas. L’insuline rapide (bolus) couvre le repas : '
            'son action commence 30 minutes après l’injection, culmine vers 1 à 2 heures '
            'et se termine après 4 à 6 heures. L’insuline basale doit être injectée à heure fixe, '
            'tous les jours, même à jeun.',
        steps: [
          'Basal : une injection par jour à heure fixe (souvent le soir).',
          'Bolus : calculé à partir des glucides du repas et de la glycémie du moment.',
          'Changez de quadrant d’injection pour limiter les lipodystrophies.',
          'Sortez l’insuline du réfrigérateur 30 minutes avant l’injection pour limiter la douleur.',
        ],
        source: 'SFD',
      ),
      AdviceArticle(
        title: 'Où et comment injecter',
        icon: Icons.accessibility_new_outlined,
        urgency: AdviceUrgency.info,
        body:
            'L’injection se fait dans le tissu sous-cutané, pas dans le muscle. '
            'Les zones disponibles sont l’abdomen, les faces externo-latérales des cuisses, '
            'les fesses et la face postéro-externe du bras. L’abdomen est la zone la plus '
            'rapide et la plus discrète.',
        steps: [
          'Changer de zone à chaque injection (rotation).',
          'Pincez la peau si la zone est maigre.',
          'Purifier la zone à l’alcool et laisser sécher (l’alcool non séché pique).',
          'Vérifiez régulièrement l’absence de boutons (lipodystrophies) : la résorption y est '
              'alors imprévisible.',
        ],
        source: 'SFD',
      ),
      AdviceArticle(
        title: 'Conservation et voyage',
        icon: Icons.luggage_outlined,
        urgency: AdviceUrgency.info,
        body:
            'Les stylos non ouverts se conservent au réfrigérateur (entre 2 et 8 °C), '
            'sans contact avec la poche de congélation. Un stylo en cours d’utilisation '
            'se garde à température ambiante, à l’abri de la lumière, pendant 4 à 6 semaines. '
            'En voyage, transportez toujours une dose de sécurité dans votre bagage cabine : '
            'la soute peut atteindre des températures extrêmes.',
        steps: [
          'Ne congelez jamais l’insuline.',
          'Changez de lot progressivement.',
          'Gardez au moins 15 jours de produit, en demande de délivrance anticipée.',
          'Ayez toujours l’ordonnance et la carte de diabétique sur vous.',
        ],
        source: 'ANSM, SFD',
      ),
    ],
  ),
  AdviceCategory(
    title: 'Nutrition',
    icon: Icons.restaurant_outlined,
    articles: [
      AdviceArticle(
        title: 'Comptabiliser les glucides',
        icon: Icons.pie_chart_outline,
        urgency: AdviceUrgency.info,
        body:
            'Pour le diabétique insulinodépendant, ce sont les glucides qui pèsent le plus sur '
            'la glycémie : ils sont comptés pour ajuster l’insuline. Les protéines et les graisses '
            'comptent moins sur le court terme mais influencent la glycémie différée. '
            'Privilégiez les glucides complexes (céréales complètes, légumineuses, légumes) '
            'et limitez les sucres rapides.',
        steps: [
          'Environ 50 g de glucides par jour pour 2 000 kcal, répartis sur 3 repas + 1 collation.',
          'Repère : 1 tranche de pain ≈ 15 g, 1 pomme ≈ 15 g, 1 portion de riz (150 g) ≈ 45 g.',
          'Mangez les glucides en premier dans l’assiette.',
          'Associer un aliment contenant des fibres et des protéines ralentit l’absorption.',
        ],
        source: 'SFD, HAS',
      ),
      AdviceArticle(
        title: 'Repères pour l’eau et l’alcool',
        icon: Icons.local_drink_outlined,
        urgency: AdviceUrgency.info,
        body:
            'L’hydratation est le réflexe de base en cas de glycémie élevée. '
            'Limitez l’alcool : il peut provoquer des hypoglycémies retardées, '
            'surtout la nuit, et masque vos symptômes d’alerte.',
        steps: [
          '1,5 à 2 litres d’eau par jour, davantage en cas de chaleur ou de sport.',
          'Évitez les sodas sucrés : une canette contient environ 35 g de glucides.',
          'Si vous consommez de l’alcool, associez-le à un apport glucidique et mangez avant.',
          'N’associez jamais alcool et conduite si vous craignez une hypoglycémie.',
        ],
        source: 'SFD, ameli.fr',
      ),
    ],
  ),
  AdviceCategory(
    title: 'Activité physique & quotidien',
    icon: Icons.directions_run,
    articles: [
      AdviceArticle(
        title: 'Bouger, en sécurité',
        icon: Icons.fitness_center,
        urgency: AdviceUrgency.info,
        body:
            'L’activité physique est le meilleur traitement gratuit du diabète de type 2 : '
            'elle augmente la sensibilité à l’insuline pendant plusieurs heures après l’effort. '
            'Une marche de 30 minutes par jour fait déjà bouger les indicateurs.',
        steps: [
          'Visez 150 minutes d’activité modérée par semaine (30 min × 5 jours).',
          'Si vous êtes sous insuline : mesurez avant, prévoyez du sucre rapide, '
              'et ajustez si l’activité commence juste après l’injection.',
          'Portez une paire de chaussures adaptée et examinez vos pieds après l’effort.',
          'En cas de glycémie > 2,50 g/L avec des corps cétoniques, ne faites pas d’effort.',
        ],
        source: 'OMS, SFD',
      ),
      AdviceArticle(
        title: 'Santé du pied : le réflexe quotidien',
        icon: Icons.directions_walk,
        urgency: AdviceUrgency.important,
        body:
            'Les plaies du pied sont la complication la plus fréquente et la plus grave du '
            'diabète, parce que le manque de sensibilité (neuropathie) retarde la douleur. '
            'Une plaie non vue peut s’infecter en quelques jours.',
        steps: [
          'Regardez vos pieds chaque soir, y compris la plante et entre les orteils.',
          'Gardez les ongles courts et droits, sans cuts.',
          'Ne jamais marcher pieds nus, même à la maison ni à la plage.',
          'Faites soigner immédiatement toute plaie, même minime.',
          'En cas de perte de sensibilité, un bilan podologique annuel est recommandé.',
        ],
        source: 'HAS, SFD',
      ),
      AdviceArticle(
        title: 'Appliquer la règle des 10 %',
        icon: Icons.lightbulb_outline,
        urgency: AdviceUrgency.info,
        body:
            'Les besoins en insuline évoluent au fil des mois, à cause du poids, '
            'de l’activité physique et de la fonction rénale. Adapter les doses '
            'est normal, mais cela se fait avec un suivi médical.',
        steps: [
          'Notez vos écarts et apportent-les à la consultation, pas au jour le jour.',
          'Ne modifiez pas votre dose totale de plus de 10 % sans avis.',
          'Tenez à jour votre carnet : dates, doses, glycémies, incidents.',
        ],
        source: 'SFD',
      ),
    ],
  ),
];
