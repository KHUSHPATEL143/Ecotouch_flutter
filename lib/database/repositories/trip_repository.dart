import '../database_service.dart';
import '../../models/trip.dart';
import '../../utils/date_utils.dart' as app_date_utils;

class TripRepository {
  /// Get all trips
  static Future<List<Trip>> getAll() async {
    final results = await DatabaseService.rawQuery('''
      SELECT t.*, v.name as vehicle_name, v.registration_number
      FROM trips t
      LEFT JOIN vehicles v ON t.vehicle_id = v.id
      ORDER BY t.date DESC, t.id DESC
    ''');
    return results.map((json) => Trip.fromJson(json)).toList();
  }

  /// Get trips for a specific date
  static Future<List<Trip>> getByDate(DateTime date) async {
    final dateStr = app_date_utils.DateUtils.formatDateForDatabase(date);
    final results = await DatabaseService.rawQuery('''
      SELECT t.*, v.name as vehicle_name, v.registration_number
      FROM trips t
      LEFT JOIN vehicles v ON t.vehicle_id = v.id
      WHERE t.date = ?
      ORDER BY t.id DESC
    ''', [dateStr]);
    return results.map((json) => Trip.fromJson(json)).toList();
  }
  
  /// Get trips for date range
  static Future<List<Trip>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final startStr = app_date_utils.DateUtils.formatDateForDatabase(startDate);
    final endStr = app_date_utils.DateUtils.formatDateForDatabase(endDate);
    final results = await DatabaseService.rawQuery('''
      SELECT t.*, v.name as vehicle_name, v.registration_number
      FROM trips t
      LEFT JOIN vehicles v ON t.vehicle_id = v.id
      WHERE t.date BETWEEN ? AND ?
      ORDER BY t.date DESC, t.id DESC
    ''', [startStr, endStr]);
    return results.map((json) => Trip.fromJson(json)).toList();
  }
  
  /// Get last trip for a vehicle
  static Future<Trip?> getLastTripForVehicle(int vehicleId) async {
    final results = await DatabaseService.rawQuery('''
      SELECT t.*, v.name as vehicle_name, v.registration_number
      FROM trips t
      LEFT JOIN vehicles v ON t.vehicle_id = v.id
      WHERE t.vehicle_id = ?
      ORDER BY t.end_km DESC, t.date DESC, t.id DESC
      LIMIT 1
    ''', [vehicleId]);
    
    if (results.isEmpty) return null;
    return Trip.fromJson(results.first);
  }
  
  /// Insert trip
  static Future<int> insert(Trip trip) async {
    return await DatabaseService.insert('trips', trip.toJson());
  }
  
  /// Update trip
  static Future<int> update(Trip trip) async {
    if (trip.id == null) throw Exception('Trip ID is required for update');
    return await DatabaseService.update(
      'trips',
      trip.toJson(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }
  
  /// Get latest trip
  static Future<Trip?> getLatest() async {
    final results = await DatabaseService.rawQuery('''
      SELECT t.*, v.name as vehicle_name, v.registration_number
      FROM trips t
      LEFT JOIN vehicles v ON t.vehicle_id = v.id
      ORDER BY t.date DESC, t.id DESC
      LIMIT 1
    ''');
    if (results.isEmpty) return null;
    return Trip.fromJson(results.first);
  }

  /// Delete trip
  static Future<int> delete(int id) async {
    return await DatabaseService.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
