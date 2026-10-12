class AlertItem {
  final String id;
  final String titleEn;
  final String titleTe;
  final String descEn;
  final String descTe;
  final String category; // 'High Priority', 'Advisory', 'Information', 'Emergency'
  final String severity; // 'Low', 'Medium', 'High', 'Critical'
  final String cta; // 'Open Queue', 'Open Essentials', 'Open Maps', 'None'
  final String timeAgo;
  final String timeAgoTe;
  bool isRead;

  AlertItem({
    required this.id,
    required this.titleEn,
    required this.titleTe,
    required this.descEn,
    required this.descTe,
    required this.category,
    required this.severity,
    required this.cta,
    required this.timeAgo,
    required this.timeAgoTe,
    this.isRead = false,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? json['title'] as String? ?? '',
      titleTe: json['titleTe'] as String? ?? json['title'] as String? ?? '',
      descEn: json['descEn'] as String? ?? json['description'] as String? ?? '',
      descTe: json['descTe'] as String? ?? json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Information',
      severity: json['severity'] as String? ?? 'Low',
      cta: json['cta'] as String? ?? 'None',
      timeAgo: json['timeAgo'] as String? ?? 'Recently',
      timeAgoTe: json['timeAgoTe'] as String? ?? 'ఇటీవల',
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
