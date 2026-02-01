class Production {
  final int? id;
  final int productId;
  final DateTime date;
  final int batches;
  final double totalQuantity;
  final double? unitSize;
  final double? unitCount;
  final DateTime? createdAt;
  
  // Optional: product and category names for display
  final String? productName;
  final String? categoryName;
  final String? productUnit;
  final String? innerUnit; // e.g. "pieces" if productUnit is "box"
  
  // Optional: raw materials used and workers assigned
  final Map<int, double>? rawMaterialsUsed;
  final List<int>? workerIds;
  
  Production({
    this.id,
    required this.productId,
    required this.date,
    required this.batches,
    required this.totalQuantity,
    this.unitSize,
    this.unitCount,
    this.createdAt,
    this.productName,
    this.categoryName,
    this.productUnit,
    this.innerUnit,
    this.rawMaterialsUsed,
    this.workerIds,
  });
  
  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'] as int?,
      productId: json['product_id'] as int,
      date: DateTime.parse(json['date'] as String),
      batches: json['batches'] as int,
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      unitSize: (json['unit_size'] as num?)?.toDouble(),
      unitCount: (json['unit_count'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      productName: json['product_name'] as String?,
      categoryName: json['category_name'] as String?,
      productUnit: json['product_unit'] as String?,
      innerUnit: json['inner_unit'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'date': date.toIso8601String().split('T')[0],
      'batches': batches,
      'total_quantity': totalQuantity,
      'unit_size': unitSize,
      'unit_count': unitCount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
  
  Production copyWith({
    int? id,
    int? productId,
    DateTime? date,
    int? batches,
    double? totalQuantity,
    double? unitSize,
    double? unitCount,
    DateTime? createdAt,
    String? productName,
    String? categoryName,
    String? productUnit,
    String? innerUnit,
    Map<int, double>? rawMaterialsUsed,
    List<int>? workerIds,
  }) {
    return Production(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      date: date ?? this.date,
      batches: batches ?? this.batches,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      unitSize: unitSize ?? this.unitSize,
      unitCount: unitCount ?? this.unitCount,
      createdAt: createdAt ?? this.createdAt,
      productName: productName ?? this.productName,
      categoryName: categoryName ?? this.categoryName,
      productUnit: productUnit ?? this.productUnit,
      innerUnit: innerUnit ?? this.innerUnit,
      rawMaterialsUsed: rawMaterialsUsed ?? this.rawMaterialsUsed,
      workerIds: workerIds ?? this.workerIds,
    );
  }
}
