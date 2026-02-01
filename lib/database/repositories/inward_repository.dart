import '../database_service.dart';
import '../../models/inward.dart';
import '../../utils/date_utils.dart' as app_date_utils;

class InwardRepository {
  /// Get all inward entries
  static Future<List<Inward>> getAll() async {
    final results = await DatabaseService.rawQuery('''
      SELECT i.*, r.name as material_name, r.unit as material_unit
      FROM inward i
      INNER JOIN raw_materials r ON i.raw_material_id = r.id
      ORDER BY i.date DESC, i.id DESC
    ''');
    return results.map((json) => Inward.fromJson(json)).toList();
  }

  /// Get inward entries for a specific date
  static Future<List<Inward>> getByDate(DateTime date) async {
    final dateStr = app_date_utils.DateUtils.formatDateForDatabase(date);
    final results = await DatabaseService.rawQuery('''
      SELECT i.*, r.name as material_name, r.unit as material_unit
      FROM inward i
      INNER JOIN raw_materials r ON i.raw_material_id = r.id
      WHERE i.date = ?
      ORDER BY i.id DESC
    ''', [dateStr]);
    return results.map((json) => Inward.fromJson(json)).toList();
  }
  
  /// Get inward entries for date range
  static Future<List<Inward>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final startStr = app_date_utils.DateUtils.formatDateForDatabase(startDate);
    final endStr = app_date_utils.DateUtils.formatDateForDatabase(endDate);
    final results = await DatabaseService.rawQuery('''
      SELECT i.*, r.name as material_name, r.unit as material_unit
      FROM inward i
      INNER JOIN raw_materials r ON i.raw_material_id = r.id
      WHERE i.date BETWEEN ? AND ?
      ORDER BY i.date DESC, i.id DESC
    ''', [startStr, endStr]);
    return results.map((json) => Inward.fromJson(json)).toList();
  }
  
  /// Insert inward entry
  static Future<int> insert(Inward inward) async {
    return await DatabaseService.insert('inward', inward.toJson());
  }
  
  /// Update inward entry
  static Future<int> update(Inward inward) async {
    if (inward.id == null) throw Exception('Inward ID is required for update');
    return await DatabaseService.update(
      'inward',
      inward.toJson(),
      where: 'id = ?',
      whereArgs: [inward.id],
    );
  }
  
  /// Delete inward entry
  static Future<int> delete(int id) async {
    return await DatabaseService.delete(
      'inward',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
