import '../database_service.dart';
import '../../models/category.dart';

class CategoryRepository {
  /// Get all categories
  static Future<List<Category>> getAll() async {
    final results = await DatabaseService.query('categories', orderBy: 'name ASC');
    return results.map((json) => Category.fromJson(json)).toList();
  }
  
  /// Get category by ID
  static Future<Category?> getById(int id) async {
    final results = await DatabaseService.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    return Category.fromJson(results.first);
  }
  
  /// Create category
  static Future<int> create(Category category) async {
    return await DatabaseService.insert('categories', category.toJson());
  }
  
  /// Update category
  static Future<int> update(Category category) async {
    if (category.id == null) throw Exception('Category ID is required for update');
    
    return await DatabaseService.update(
      'categories',
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }
  
  /// Delete category
  static Future<int> delete(int id) async {
    return await DatabaseService.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Get raw materials for a category
  static Future<List<int>> getRawMaterialIds(int categoryId) async {
    final results = await DatabaseService.query(
      'category_raw_materials',
      columns: ['raw_material_id'],
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    
    return results.map((r) => r['raw_material_id'] as int).toList();
  }
  
  /// Associate raw materials with category
  static Future<void> setRawMaterials(int categoryId, List<int> rawMaterialIds) async {
    await DatabaseService.transaction((txn) async {
      // Delete existing associations
      await txn.delete(
        'category_raw_materials',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
      
      // Insert new associations
      for (final materialId in rawMaterialIds) {
        await txn.insert('category_raw_materials', {
          'category_id': categoryId,
          'raw_material_id': materialId,
        });
      }
    });
  }
}
