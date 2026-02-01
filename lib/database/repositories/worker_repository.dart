import '../database_service.dart';
import '../../models/worker.dart';

class WorkerRepository {
  /// Get all workers
  static Future<List<Worker>> getAll() async {
    final results = await DatabaseService.query('workers', orderBy: 'name ASC');
    return results.map((json) => Worker.fromJson(json)).toList();
  }
  
  /// Get workers by type
  static Future<List<Worker>> getByType(WorkerType type) async {
    final results = await DatabaseService.query(
      'workers',
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'name ASC',
    );
    return results.map((json) => Worker.fromJson(json)).toList();
  }
  
  /// Get worker by ID
  static Future<Worker?> getById(int id) async {
    final results = await DatabaseService.query(
      'workers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return Worker.fromJson(results.first);
  }
  
  /// Insert new worker
  static Future<int> insert(Worker worker) async {
    return await DatabaseService.insert('workers', worker.toJson());
  }
  
  /// Update worker
  static Future<int> update(Worker worker) async {
    if (worker.id == null) throw Exception('Worker ID is required for update');
    return await DatabaseService.update(
      'workers',
      worker.toJson(),
      where: 'id = ?',
      whereArgs: [worker.id],
    );
  }
  
  /// Delete worker
  static Future<int> delete(int id) async {
    return await DatabaseService.delete(
      'workers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
