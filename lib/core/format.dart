/// Formatage des dates en français (sans dépendance externe).
library;

const _months = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

const _monthsShort = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

const _days = [
  'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche',
];

const _daysShort = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];

String _two(int v) => v.toString().padLeft(2, '0');

/// « 14 h 30 »
String hhmm(DateTime d) => '${_two(d.hour)} h ${_two(d.minute)}';

/// « 30/09/2026 »
String ddmmyyyy(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// « 30 sept. 2026 »
String dateLongFr(DateTime d) => '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

/// « mardi 30 septembre 2026 »
String dateFullFr(DateTime d) =>
    '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${d.year}';

/// « aujourd'hui », « hier », « il y a 3 jours », puis la date.
String relativeDayFr(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(d.year, d.month, d.day);
  final diff = today.difference(target).inDays;
  if (diff == 0) return "aujourd'hui";
  if (diff == 1) return 'hier';
  if (diff > 1 && diff < 7) return 'il y a $diff jours';
  if (diff == 7) return 'il y a 1 semaine';
  return '${_daysShort[d.weekday - 1]} ${ddmmyyyy(d)}';
}

/// « il y a 2 h », « il y a 12 min », « à l'instant »
String relativeTimeFr(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inSeconds < 60) return "à l'instant";
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 30) return 'il y a ${diff.inDays} j';
  return dateLongFr(d);
}

/// Durée d'écran pour l'accueil : « Bonjour Daniela ».
String greetingFr() {
  final h = DateTime.now().hour;
  if (h < 5) return 'Bonne nuit';
  if (h < 12) return 'Bonjour';
  if (h < 18) return 'Bon après-midi';
  return 'Bonsoir';
}
