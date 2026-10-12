class Festival {
  final String id;
  final String name;
  final String date;
  final String location;
  final String placeId;
  final int gravityScore;
  final String expectedCrowd;
  final String recommendedTime;
  final String specialTips;

  Festival({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.placeId,
    this.gravityScore = 5,
    this.expectedCrowd = 'Moderate',
    this.recommendedTime = 'Morning & Evening',
    this.specialTips = '',
  });

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sacred Festival',
      date: json['date'] as String? ?? '',
      location: json['location'] as String? ?? 'Tirumala',
      placeId: json['placeId'] as String? ?? 'venkateswara',
      gravityScore: (json['gravityScore'] as num?)?.toInt() ?? 5,
      expectedCrowd: json['expectedCrowd'] as String? ?? 'Moderate',
      recommendedTime: json['recommendedTime'] as String? ?? 'Morning & Evening',
      specialTips: json['specialTips'] as String? ?? '',
    );
  }
}
