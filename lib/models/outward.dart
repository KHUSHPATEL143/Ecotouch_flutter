class Outward {
  final int? id;
  final int productId;
  final DateTime date;
  final double bagSize;
  final int bagCount;
  final double totalWeight;
  final double pricePerUnit;
  final String? notes;
  final DateTime? createdAt;
  
  // Optional: product name for display
  final String? productName;
  
  Outward({
    this.id,
    required this.productId,
    required this.date,
    required this.bagSize,
    required this.bagCount,
    required this.totalWeight,
    this.pricePerUnit = 0.0,
    this.notes,
    this.createdAt,
    this.productName,
  });
  
  factory Outward.fromJson(Map<String, dynamic> json) {
    return Outward(
      id: json['id'] as int?,
      productId: json['product_id'] as int,
      date: DateTime.parse(json['date'] as String),
      bagSize: (json['bag_size'] as num).toDouble(),
      bagCount: json['bag_count'] as int,
      totalWeight: json['total_weight'] != null 
          ? (json['total_weight'] as num).toDouble()
          : (json['bag_size'] as num).toDouble() * (json['bag_count'] as int),
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      productName: json['product_name'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'date': date.toIso8601String().split('T')[0],
      'bag_size': bagSize,
      'bag_count': bagCount,

      'total_weight': totalWeight,
      'price_per_unit': pricePerUnit,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
  
  Outward copyWith({
    int? id,
    int? productId,
    DateTime? date,
    double? bagSize,
    int? bagCount,

    double? totalWeight,
    double? pricePerUnit,
    String? notes,
    DateTime? createdAt,
    String? productName,
  }) {
    return Outward(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      date: date ?? this.date,
      bagSize: bagSize ?? this.bagSize,
      bagCount: bagCount ?? this.bagCount,

      totalWeight: totalWeight ?? this.totalWeight,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      productName: productName ?? this.productName,
    );
  }
}
