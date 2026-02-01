import '../database_service.dart';
import '../../models/unit_conversion.dart';

class UnitConversionRepository {
  /// Get all unit conversions
  static Future<List<UnitConversion>> getAll() async {
    final results = await DatabaseService.query(
      'unit_conversions',
      orderBy: 'from_unit ASC, to_unit ASC',
    );
    return results.map((json) => UnitConversion.fromJson(json)).toList();
  }

  /// Get a specific conversion factor
  static Future<double?> getConversionFactor(String fromUnit, String toUnit) async {
    final results = await DatabaseService.query(
      'unit_conversions',
      where: 'from_unit = ? AND to_unit = ?',
      whereArgs: [fromUnit, toUnit],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    return (results.first['conversion_factor'] as num).toDouble();
  }

  /// Create a new unit conversion
  static Future<int> create(UnitConversion conversion) async {
    return await DatabaseService.insert(
      'unit_conversions',
      conversion.toJson(),
    );
  }

  /// Update an existing unit conversion
  static Future<int> update(UnitConversion conversion) async {
    if (conversion.id == null) {
      throw Exception('Cannot update unit conversion without an ID');
    }
    
    return await DatabaseService.update(
      'unit_conversions',
      conversion.toJson(),
      where: 'id = ?',
      whereArgs: [conversion.id],
    );
  }

  /// Delete a unit conversion
  static Future<int> delete(int id) async {
    return await DatabaseService.delete(
      'unit_conversions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get conversion by ID
  static Future<UnitConversion?> getById(int id) async {
    final results = await DatabaseService.query(
      'unit_conversions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    return UnitConversion.fromJson(results.first);
  }
}
