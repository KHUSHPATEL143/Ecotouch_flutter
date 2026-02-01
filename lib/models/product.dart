class Product {
  final int? id;
  final String name;
  final int categoryId;
  final DateTime? createdAt;
  
  // Optional: category name for display
  final String? categoryName;
  
  // Optional: raw materials with ratios
  final Map<int, double>? rawMaterialRatios;
  
  final String? unit;
  final double initialStock;
  
  Product({
    this.id,
    required this.name,
    required this.categoryId,
    this.createdAt,
    this.categoryName,
    this.rawMaterialRatios,
    this.unit,
    this.initialStock = 0,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String,
      categoryId: json['category_id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      categoryName: json['category_name'] as String?,
      unit: json['unit'] as String?,
      initialStock: (json['initial_stock'] as num?)?.toDouble() ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (unit != null) 'unit': unit,
      'initial_stock': initialStock,
    };
  }
  
  Product copyWith({
    int? id,
    String? name,
    int? categoryId,
    DateTime? createdAt,
    String? categoryName,
    Map<int, double>? rawMaterialRatios,
    String? unit,
    double? initialStock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
      rawMaterialRatios: rawMaterialRatios ?? this.rawMaterialRatios,
      unit: unit ?? this.unit,
      initialStock: initialStock ?? this.initialStock,
    );
  }
}
