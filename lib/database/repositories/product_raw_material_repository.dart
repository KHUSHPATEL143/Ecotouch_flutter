import '../database_service.dart';
import '../../models/product_raw_material.dart';

class ProductRawMaterialRepository {
  /// Get BOM (Bill of Materials) for a specific product
  static Future<List<ProductRawMaterial>> getByProductId(int productId) async {
    final results = await DatabaseService.rawQuery('''
      SELECT prm.*, rm.name as raw_material_name, rm.unit
      FROM product_raw_materials prm
      INNER JOIN raw_materials rm ON prm.raw_material_id = rm.id
      WHERE prm.product_id = ?
      ORDER BY rm.name ASC
    ''', [productId]);
    
    return results.map((json) => ProductRawMaterial.fromJson(json)).toList();
  }

  /// Get all raw materials for a product (just IDs and quantities)
  static Future<List<ProductRawMaterial>> getSimpleByProductId(int productId) async {
    final results = await DatabaseService.query(
      'product_raw_materials',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    
    return results.map((json) => ProductRawMaterial.fromJson(json)).toList();
  }

  /// Insert a single BOM entry
  static Future<void> insert(ProductRawMaterial item) async {
    await DatabaseService.insert('product_raw_materials', item.toJson());
  }

  /// Insert multiple BOM entries (batch insert)
  static Future<void> insertBatch(List<ProductRawMaterial> items) async {
    for (final item in items) {
      await insert(item);
    }
  }

  /// Delete all BOM entries for a product
  static Future<void> deleteByProductId(int productId) async {
    await DatabaseService.delete(
      'product_raw_materials',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  /// Update BOM for a product (delete old + insert new)
  static Future<void> updateBOM(int productId, List<ProductRawMaterial> items) async {
    await deleteByProductId(productId);
    await insertBatch(items);
  }

  /// Check if a product has BOM defined
  static Future<bool> hasBOM(int productId) async {
    final results = await DatabaseService.query(
      'product_raw_materials',
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    return results.isNotEmpty;
  }
}
