class RewardItem {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String category; // "gadget" or "voucher"
  final String? icon;
  final double? cashValue;

  RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.category,
    this.icon,
    this.cashValue,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsCost: json['pointsCost'] as int? ?? 0,
      category: json['category'] as String? ?? 'gadget',
      icon: json['icon'] as String?,
      cashValue: (json['cashValue'] as num?)?.toDouble(),
    );
  }
}
