class Inward {
  final int? id;
  final int rawMaterialId;
  final DateTime date;
  final double bagSize;
  final int bagCount;
  final double totalWeight;
  final double? totalCost;
  final String? notes;
  final DateTime? createdAt;
  
  // Optional: material name and unit for display
  final String? materialName;
  final String? materialUnit;
  
  Inward({
    this.id,
    required this.rawMaterialId,
    required this.date,
    required this.bagSize,
    required this.bagCount,
    required this.totalWeight,
    this.totalCost,
    this.notes,
    this.createdAt,
    this.materialName,
    this.materialUnit,
  });
  
  factory Inward.fromJson(Map<String, dynamic> json) {
    return Inward(
      id: json['id'] as int?,
      rawMaterialId: json['raw_material_id'] as int,
      date: DateTime.parse(json['date'] as String),
      bagSize: (json['bag_size'] as num).toDouble(),
      bagCount: json['bag_count'] as int,
      totalWeight: (json['total_weight'] as num).toDouble(),
      totalCost: json['total_cost'] != null ? (json['total_cost'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      materialName: json['material_name'] as String?,
      materialUnit: json['material_unit'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'raw_material_id': rawMaterialId,
      'date': date.toIso8601String().split('T')[0],
      'bag_size': bagSize,
      'bag_count': bagCount,

      'total_weight': totalWeight,
      if (totalCost != null) 'total_cost': totalCost,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
  
  Inward copyWith({
    int? id,
    int? rawMaterialId,
    DateTime? date,
    double? bagSize,
    int? bagCount,

    double? totalWeight,
    double? totalCost,
    String? notes,
    DateTime? createdAt,
    String? materialName,
    String? materialUnit,
  }) {
    return Inward(
      id: id ?? this.id,
      rawMaterialId: rawMaterialId ?? this.rawMaterialId,
      date: date ?? this.date,
      bagSize: bagSize ?? this.bagSize,
      bagCount: bagCount ?? this.bagCount,

      totalWeight: totalWeight ?? this.totalWeight,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      materialName: materialName ?? this.materialName,
      materialUnit: materialUnit ?? this.materialUnit,
    );
  }
}
