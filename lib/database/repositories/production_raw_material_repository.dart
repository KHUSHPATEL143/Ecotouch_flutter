import '../database_service.dart';
import '../../models/production_raw_material.dart';

class ProductionRawMaterialRepository {
  /// Insert a single production raw material usage record
  static Future<void> insert(ProductionRawMaterial item) async {
    await DatabaseService.insert('production_raw_materials', item.toJson());
  }

  /// Insert multiple production raw material usage records (batch insert)
  static Future<void> insertBatch(List<ProductionRawMaterial> items) async {
    for (final item in items) {
      await insert(item);
    }
  }

  /// Get raw materials used for a specific production entry
  static Future<List<ProductionRawMaterial>> getByProductionId(int productionId) async {
    final results = await DatabaseService.rawQuery('''
      SELECT prm.*, rm.name as raw_material_name
      FROM production_raw_materials prm
      INNER JOIN raw_materials rm ON prm.raw_material_id = rm.id
      WHERE prm.production_id = ?
      ORDER BY rm.name ASC
    ''', [productionId]);
    
    return results.map((json) => ProductionRawMaterial.fromJson(json)).toList();
  }

  /// Get total quantity used of a specific raw material
  static Future<double> getTotalUsed(int rawMaterialId) async {
    final results = await DatabaseService.rawQuery('''
      SELECT COALESCE(SUM(quantity_used), 0) as total
      FROM production_raw_materials
      WHERE raw_material_id = ?
    ''', [rawMaterialId]);
    
    if (results.isEmpty) return 0.0;
    return (results.first['total'] as num).toDouble();
  }

  /// Get total quantity used of a raw material within a date range
  static Future<double> getTotalUsedByDateRange(
    int rawMaterialId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final results = await DatabaseService.rawQuery('''
      SELECT COALESCE(SUM(prm.quantity_used), 0) as total
      FROM production_raw_materials prm
      INNER JOIN production p ON prm.production_id = p.id
      WHERE prm.raw_material_id = ? AND p.date BETWEEN ? AND ?
    ''', [
      rawMaterialId,
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);
    
    if (results.isEmpty) return 0.0;
    return (results.first['total'] as num).toDouble();
  }

  /// Delete all raw material usage records for a production entry
  static Future<void> deleteByProductionId(int productionId) async {
    await DatabaseService.delete(
      'production_raw_materials',
      where: 'production_id = ?',
      whereArgs: [productionId],
    );
  }
}
