class RankDefinition {
  final String id;
  final String code;
  final String name;
  final int minimumPoints;
  final String description;

  const RankDefinition({
    required this.id,
    required this.code,
    required this.name,
    required this.minimumPoints,
    this.description = '',
  });

  RankDefinition copyWith({
    String? code,
    String? name,
    int? minimumPoints,
    String? description,
  }) => RankDefinition(
    id: id,
    code: code ?? this.code,
    name: name ?? this.name,
    minimumPoints: minimumPoints ?? this.minimumPoints,
    description: description ?? this.description,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'minimumPoints': minimumPoints,
    'description': description,
  };

  factory RankDefinition.fromJson(Map<String, dynamic> json) => RankDefinition(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    minimumPoints: json['minimumPoints'] as int? ?? 0,
    description: json['description'] as String? ?? '',
  );
}
