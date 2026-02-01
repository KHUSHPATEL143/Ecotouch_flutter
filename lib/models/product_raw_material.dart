class ProductRawMaterial {
  final int productId;
  final int rawMaterialId;
  final double quantityRatio; // Quantity of raw material per batch
  
  // For display purposes (not stored in DB)
  final String? rawMaterialName;
  final String? unit;

  ProductRawMaterial({
    required this.productId,
    required this.rawMaterialId,
    required this.quantityRatio,
    this.rawMaterialName,
    this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'raw_material_id': rawMaterialId,
      'quantity_ratio': quantityRatio,
    };
  }

  factory ProductRawMaterial.fromJson(Map<String, dynamic> json) {
    return ProductRawMaterial(
      productId: json['product_id'] as int,
      rawMaterialId: json['raw_material_id'] as int,
      quantityRatio: (json['quantity_ratio'] as num).toDouble(),
      rawMaterialName: json['raw_material_name'] as String?,
      unit: json['unit'] as String?,
    );
  }

  ProductRawMaterial copyWith({
    int? productId,
    int? rawMaterialId,
    double? quantityRatio,
    String? rawMaterialName,
    String? unit,
  }) {
    return ProductRawMaterial(
      productId: productId ?? this.productId,
      rawMaterialId: rawMaterialId ?? this.rawMaterialId,
      quantityRatio: quantityRatio ?? this.quantityRatio,
      rawMaterialName: rawMaterialName ?? this.rawMaterialName,
      unit: unit ?? this.unit,
    );
  }
}
