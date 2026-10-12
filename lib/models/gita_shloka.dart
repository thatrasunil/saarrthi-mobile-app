class GitaShloka {
  final String id;
  final int chapter;
  final int verse;
  final String referenceEn;
  final String referenceTe;
  final String themeEn;
  final String themeTe;
  final String shlokaSanskrit;
  final String shlokaTelugu;
  final String meaningEn;
  final String meaningTe;
  final String pilgrimReflectionEn;
  final String pilgrimReflectionTe;

  GitaShloka({
    required this.id,
    required this.chapter,
    required this.verse,
    required this.referenceEn,
    required this.referenceTe,
    required this.themeEn,
    required this.themeTe,
    required this.shlokaSanskrit,
    required this.shlokaTelugu,
    required this.meaningEn,
    required this.meaningTe,
    required this.pilgrimReflectionEn,
    required this.pilgrimReflectionTe,
  });

  factory GitaShloka.fromJson(Map<String, dynamic> json) {
    return GitaShloka(
      id: json['id'] as String? ?? '',
      chapter: (json['chapter'] as num?)?.toInt() ?? 2,
      verse: (json['verse'] as num?)?.toInt() ?? 47,
      referenceEn: json['referenceEn'] as String? ?? 'Bhagavad Gita 2.47',
      referenceTe: json['referenceTe'] as String? ?? 'శ్రీమద్భగవద్గీత 2.47',
      themeEn: json['themeEn'] as String? ?? 'Selfless Action',
      themeTe: json['themeTe'] as String? ?? 'కర్మ యోగం',
      shlokaSanskrit: json['shlokaSanskrit'] as String? ?? '',
      shlokaTelugu: json['shlokaTelugu'] as String? ?? '',
      meaningEn: json['meaningEn'] as String? ?? '',
      meaningTe: json['meaningTe'] as String? ?? '',
      pilgrimReflectionEn: json['pilgrimReflectionEn'] as String? ?? '',
      pilgrimReflectionTe: json['pilgrimReflectionTe'] as String? ?? '',
    );
  }
}
