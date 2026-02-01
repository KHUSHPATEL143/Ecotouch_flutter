class ProductionRawMaterial {
  final int productionId;
  final int rawMaterialId;
  final double quantityUsed;
  
  // For display purposes (not stored in DB)
  final String? rawMaterialName;

  ProductionRawMaterial({
    required this.productionId,
    required this.rawMaterialId,
    required this.quantityUsed,
    this.rawMaterialName,
  });

  Map<String, dynamic> toJson() {
    return {
      'production_id': productionId,
      'raw_material_id': rawMaterialId,
      'quantity_used': quantityUsed,
    };
  }

  factory ProductionRawMaterial.fromJson(Map<String, dynamic> json) {
    return ProductionRawMaterial(
      productionId: json['production_id'] as int,
      rawMaterialId: json['raw_material_id'] as int,
      quantityUsed: (json['quantity_used'] as num).toDouble(),
      rawMaterialName: json['raw_material_name'] as String?,
    );
  }
}
