import '../database_service.dart';
import '../../models/raw_material.dart';

class RawMaterialRepository {
  /// Get all raw materials
  static Future<List<RawMaterial>> getAll() async {
    final results = await DatabaseService.query('raw_materials', orderBy: 'name ASC');
    return results.map((json) => RawMaterial.fromJson(json)).toList();
  }
  
  /// Get raw material by ID
  static Future<RawMaterial?> getById(int id) async {
    final results = await DatabaseService.query(
      'raw_materials',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return RawMaterial.fromJson(results.first);
  }
  
  /// Get raw materials by category
  static Future<List<RawMaterial>> getByCategory(int categoryId) async {
    final results = await DatabaseService.rawQuery('''
      SELECT rm.* FROM raw_materials rm
      INNER JOIN category_raw_materials crm ON rm.id = crm.raw_material_id
      WHERE crm.category_id = ?
      ORDER BY rm.name ASC
    ''', [categoryId]);
    return results.map((json) => RawMaterial.fromJson(json)).toList();
  }
  
  /// Insert new raw material
  static Future<int> insert(RawMaterial material) async {
    return await DatabaseService.insert('raw_materials', material.toJson());
  }
  
  /// Update raw material
  static Future<int> update(RawMaterial material) async {
    if (material.id == null) throw Exception('Material ID is required for update');
    return await DatabaseService.update(
      'raw_materials',
      material.toJson(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }
  
  /// Delete raw material
  static Future<int> delete(int id) async {
    return await DatabaseService.delete(
      'raw_materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
