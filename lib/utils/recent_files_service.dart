import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RecentFilesService {
  static const String _fileName = 'recent_databases.json';
  static const int _maxRecentFiles = 5;

  /// Get the list of recent database paths
  static Future<List<String>> getRecentFiles() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.cast<String>();
    } catch (e) {
      print('Error reading recent files: $e');
      return [];
    }
  }

  /// Add a database path to the recent list
  static Future<void> addRecentFile(String path) async {
    try {
      final file = await _getFile();
      final List<String> currentList = await getRecentFiles();

      // Remove if exists to move to top
      currentList.remove(path);
      
      // Add to top
      currentList.insert(0, path);

      // Trim list
      if (currentList.length > _maxRecentFiles) {
        currentList.removeRange(_maxRecentFiles, currentList.length);
      }

      await file.writeAsString(jsonEncode(currentList));
    } catch (e) {
      print('Error saving recent file: $e');
    }
  }

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
