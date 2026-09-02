class Achievement {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final int currentValue;
  final int targetValue;
  final bool achieved;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.currentValue = 0,
    this.targetValue = 1,
    this.achieved = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        currentValue: (json['current_value'] as num?)?.toInt() ?? 0,
        targetValue: (json['target_value'] as num?)?.toInt() ?? 1,
        achieved: json['achieved'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'current_value': currentValue,
        'target_value': targetValue,
        'achieved': achieved,
      };

  bool get completed => achieved || currentValue >= targetValue;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? currentValue,
    int? targetValue,
    bool? achieved,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      achieved: achieved ?? this.achieved,
    );
  }
}
