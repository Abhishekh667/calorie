class WaterEntry {
  final String id;
  final DateTime date;
  final double amountMl;
  final DateTime createdAt;

  WaterEntry({
    required this.id,
    required this.date,
    required this.amountMl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amountMl': amountMl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        amountMl: (json['amountMl'] as num).toDouble(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}
