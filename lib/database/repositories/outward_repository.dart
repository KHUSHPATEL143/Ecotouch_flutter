import '../database_service.dart';
import '../../models/outward.dart';
import '../../utils/date_utils.dart' as app_date_utils;

class OutwardRepository {
  /// Get all outward entries
  static Future<List<Outward>> getAll() async {
    final results = await DatabaseService.rawQuery('''
      SELECT o.*, p.name as product_name
      FROM outward o
      INNER JOIN products p ON o.product_id = p.id
      ORDER BY o.date DESC, o.id DESC
    ''');
    return results.map((json) => Outward.fromJson(json)).toList();
  }

  /// Get outward entries for a specific date
  static Future<List<Outward>> getByDate(DateTime date) async {
    final dateStr = app_date_utils.DateUtils.formatDateForDatabase(date);
    final results = await DatabaseService.rawQuery('''
      SELECT o.*, p.name as product_name
      FROM outward o
      INNER JOIN products p ON o.product_id = p.id
      WHERE o.date = ?
      ORDER BY o.id DESC
    ''', [dateStr]);
    return results.map((json) => Outward.fromJson(json)).toList();
  }
  
  /// Get outward entries for date range
  static Future<List<Outward>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final startStr = app_date_utils.DateUtils.formatDateForDatabase(startDate);
    final endStr = app_date_utils.DateUtils.formatDateForDatabase(endDate);
    final results = await DatabaseService.rawQuery('''
      SELECT o.*, p.name as product_name
      FROM outward o
      INNER JOIN products p ON o.product_id = p.id
      WHERE o.date BETWEEN ? AND ?
      ORDER BY o.date DESC, o.id DESC
    ''', [startStr, endStr]);
    return results.map((json) => Outward.fromJson(json)).toList();
  }
  
  /// Insert outward entry
  static Future<int> insert(Outward outward) async {
    return await DatabaseService.insert('outward', outward.toJson());
  }
  
  /// Update outward entry
  static Future<int> update(Outward outward) async {
    if (outward.id == null) throw Exception('Outward ID is required for update');
    return await DatabaseService.update(
      'outward',
      outward.toJson(),
      where: 'id = ?',
      whereArgs: [outward.id],
    );
  }
  
  /// Delete outward entry
  static Future<int> delete(int id) async {
    return await DatabaseService.delete(
      'outward',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
