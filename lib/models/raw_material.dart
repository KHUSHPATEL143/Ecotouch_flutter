class RawMaterial {
  final int? id;
  final String name;
  final String unit;
  final double minAlertLevel;
  final DateTime? createdAt;
  
  RawMaterial({
    this.id,
    required this.name,
    required this.unit,
    this.minAlertLevel = 0,
    this.createdAt,
  });
  
  factory RawMaterial.fromJson(Map<String, dynamic> json) {
    return RawMaterial(
      id: json['id'] as int?,
      name: json['name'] as String,
      unit: json['unit'] as String,
      minAlertLevel: (json['min_alert_level'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'unit': unit,
      'min_alert_level': minAlertLevel,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
  
  RawMaterial copyWith({
    int? id,
    String? name,
    String? unit,
    double? minAlertLevel,
    DateTime? createdAt,
  }) {
    return RawMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      minAlertLevel: minAlertLevel ?? this.minAlertLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
