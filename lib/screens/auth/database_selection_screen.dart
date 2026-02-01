import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../providers/global_providers.dart';
import '../../database/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/recent_files_service.dart';
import '../main/main_layout.dart';

class DatabaseSelectionScreen extends ConsumerStatefulWidget {
  const DatabaseSelectionScreen({super.key});

  @override
  ConsumerState<DatabaseSelectionScreen> createState() => _DatabaseSelectionScreenState();
}

class _DatabaseSelectionScreenState extends ConsumerState<DatabaseSelectionScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    final files = await RecentFilesService.getRecentFiles();
    if (mounted) {
      setState(() => _recentFiles = files);
    }
  }

  Future<void> _selectDatabaseFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Database Folder',
      );

      if (result != null) {
        final dbPath = path.join(result, AppConstants.databaseName);
        await _openDatabase(dbPath);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to open database: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openDatabase(String dbPath) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await DatabaseService.initDatabase(dbPath);
      await RecentFilesService.addRecentFile(dbPath);
      
      if (mounted) {
        ref.read(databasePathProvider.notifier).state = dbPath;
        ref.read(isAuthenticatedProvider.notifier).state = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final errorStr = e.toString();
          if (errorStr.contains('PathNotFoundException') || 
              errorStr.contains('system cannot find the path')) {
            _errorMessage = 'Database folder not found. Please select a valid location.';
          } else {
            _errorMessage = 'Failed to initialize database: $errorStr';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title
                  Text(
                    'Production Dashboard',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select Database Location',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Select Folder Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _selectDatabaseFolder,
                    icon: const Icon(Icons.folder_open),
                    label: Text(_isLoading ? 'Loading...' : 'Select Database Folder'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recent Files List
                  if (_recentFiles.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Recent Databases',
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _recentFiles.length,
                        itemBuilder: (context, index) {
                          final filePath = _recentFiles[index];
                          return ListTile(
                            leading: const Icon(Icons.history, size: 20),
                            title: Text(
                              path.dirname(filePath),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              path.basename(filePath),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            onTap: _isLoading ? null : () => _openDatabase(filePath),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                    ),
                  ],

                  if (_recentFiles.isEmpty) ...[
                    const SizedBox(height: 16),
                    // Info Text
                    Text(
                      'Select a folder where the database will be stored. '
                      'You can choose a location on your computer or an external drive.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
