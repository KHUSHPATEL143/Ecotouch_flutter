import '../database/database_service.dart';
import 'dart:async';

/// Service for monitoring database health and performance
class DatabaseHealthService {
  static Timer? _monitoringTimer;
  static final List<Map<String, dynamic>> _healthHistory = [];
  static const int maxHistorySize = 100;

  /// Start monitoring database health
  /// Checks health metrics every [intervalMinutes] minutes
  static void startMonitoring({int intervalMinutes = 30}) {
    stopMonitoring(); // Stop any existing timer

    _monitoringTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => _checkHealth(),
    );

    // Run initial check
    _checkHealth();
    print('✓ Database health monitoring started (interval: ${intervalMinutes}m)');
  }

  /// Stop monitoring
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Perform health check
  static Future<void> _checkHealth() async {
    try {
      final health = await DatabaseService.getDatabaseHealth();
      
      if (health.isEmpty) return;

      // Add timestamp
      health['timestamp'] = DateTime.now().toIso8601String();

      // Add to history
      _healthHistory.add(health);
      if (_healthHistory.length > maxHistorySize) {
        _healthHistory.removeAt(0);
      }

      // Check for issues
      final fragmentation = double.tryParse(health['fragmentationPercent'] ?? '0') ?? 0;
      final totalSizeMB = double.tryParse(health['totalSizeMB'] ?? '0') ?? 0;

      if (fragmentation > 20) {
        print('⚠ Database fragmentation high: ${fragmentation.toStringAsFixed(1)}%');
        print('  Consider running manual vacuum');
      }

      if (totalSizeMB > 100) {
        print('⚠ Database size large: ${totalSizeMB.toStringAsFixed(2)} MB');
      }

      // Log health status
      print('Database Health: ${health['usedSizeMB']}MB used, '
            '${health['fragmentationPercent']}% fragmentation, '
            'mode: ${health['journalMode']}');
    } catch (e) {
      print('Error during health check: $e');
    }
  }

  /// Get current database health
  static Future<Map<String, dynamic>> getCurrentHealth() async {
    return await DatabaseService.getDatabaseHealth();
  }

  /// Get health history
  static List<Map<String, dynamic>> getHealthHistory() {
    return List.unmodifiable(_healthHistory);
  }

  /// Check if database needs optimization
  static Future<bool> needsOptimization() async {
    try {
      final health = await DatabaseService.getDatabaseHealth();
      final fragmentation = double.tryParse(health['fragmentationPercent'] ?? '0') ?? 0;
      
      // Needs optimization if fragmentation > 15%
      return fragmentation > 15;
    } catch (e) {
      return false;
    }
  }

  /// Run manual optimization
  static Future<void> optimize() async {
    try {
      print('Running database optimization...');
      await DatabaseService.vacuumDatabase();
      print('✓ Database optimization completed');
    } catch (e) {
      print('Error during optimization: $e');
      rethrow;
    }
  }

  /// Get database statistics summary
  static Future<Map<String, String>> getStatsSummary() async {
    try {
      final health = await DatabaseService.getDatabaseHealth();
      
      return {
        'Size': '${health['usedSizeMB']} MB',
        'Fragmentation': '${health['fragmentationPercent']}%',
        'Journal Mode': health['journalMode'] ?? 'Unknown',
        'Status': _getHealthStatus(health),
      };
    } catch (e) {
      return {'Error': e.toString()};
    }
  }

  /// Determine health status based on metrics
  static String _getHealthStatus(Map<String, dynamic> health) {
    final fragmentation = double.tryParse(health['fragmentationPercent'] ?? '0') ?? 0;
    final totalSizeMB = double.tryParse(health['totalSizeMB'] ?? '0') ?? 0;

    if (fragmentation > 20 || totalSizeMB > 200) {
      return 'Needs Attention';
    } else if (fragmentation > 10 || totalSizeMB > 100) {
      return 'Fair';
    } else {
      return 'Good';
    }
  }

  /// Clear health history
  static void clearHistory() {
    _healthHistory.clear();
  }
}
