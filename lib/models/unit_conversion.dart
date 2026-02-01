class UnitConversion {
  final int? id;
  final String fromUnit;
  final String toUnit;
  final double conversionFactor;
  final DateTime? createdAt;

  UnitConversion({
    this.id,
    required this.fromUnit,
    required this.toUnit,
    required this.conversionFactor,
    this.createdAt,
  });

  factory UnitConversion.fromJson(Map<String, dynamic> json) {
    return UnitConversion(
      id: json['id'] as int?,
      fromUnit: json['from_unit'] as String,
      toUnit: json['to_unit'] as String,
      conversionFactor: (json['conversion_factor'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'from_unit': fromUnit,
      'to_unit': toUnit,
      'conversion_factor': conversionFactor,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  UnitConversion copyWith({
    int? id,
    String? fromUnit,
    String? toUnit,
    double? conversionFactor,
    DateTime? createdAt,
  }) {
    return UnitConversion(
      id: id ?? this.id,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
