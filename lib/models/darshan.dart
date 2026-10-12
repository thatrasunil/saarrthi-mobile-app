class DarshanStatus {
  final String queueType;
  final int waitHours;
  final String crowdStatus;
  final int compartmentsFull;
  final String recommendation;
  final DateTime lastUpdated;

  DarshanStatus({
    required this.queueType,
    required this.waitHours,
    required this.crowdStatus,
    required this.compartmentsFull,
    required this.recommendation,
    required this.lastUpdated,
  });

  factory DarshanStatus.sample() {
    return DarshanStatus(
      queueType: 'Sarva Darshan (Free SSD)',
      waitHours: 8,
      crowdStatus: 'Moderate Rush',
      compartmentsFull: 14,
      recommendation: 'Queue moves smoothly after 2 PM. Complete footstep registration at Alipiri early.',
      lastUpdated: DateTime.now(),
    );
  }

  factory DarshanStatus.fromJson(Map<String, dynamic> json) {
    return DarshanStatus(
      queueType: json['queueType'] as String? ?? 'Sarva Darshan',
      waitHours: (json['waitHours'] as num?)?.toInt() ?? 8,
      crowdStatus: json['crowdStatus'] as String? ?? 'Normal',
      compartmentsFull: (json['compartmentsFull'] as num?)?.toInt() ?? 12,
      recommendation: json['recommendation'] as String? ?? 'Visit during non-peak afternoon hours.',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
