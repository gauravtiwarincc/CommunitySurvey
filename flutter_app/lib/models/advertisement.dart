class Advertisement {
  final String id;
  final String type; // "image" or "video"
  final String? mediaUrl;
  final String? imageUrl;
  final int rewardPoints;
  final int durationSeconds;
  final String? title;
  final String? description;

  Advertisement({
    required this.id,
    required this.type,
    this.mediaUrl,
    this.imageUrl,
    this.rewardPoints = 0,
    this.durationSeconds = 0,
    this.title,
    this.description,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
      mediaUrl: json['mediaUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }
}
