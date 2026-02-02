import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../theme/app_colors.dart';
import '../../../database/database_service.dart';

class DataBackupManagement extends ConsumerStatefulWidget {
  const DataBackupManagement({super.key});

  @override
  ConsumerState<DataBackupManagement> createState() => _DataBackupManagementState();
}

class _DataBackupManagementState extends ConsumerState<DataBackupManagement> {
  bool _isLoading = false;

  Future<void> _backupData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Pick Directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // User canceled
        return;
      }

      // 2. Generate Filename
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'ecotouch_backup_$dateStr.db';
      final fullPath = '$selectedDirectory/$filename';

      // 3. Perform Backup
      await DatabaseService.backupDatabase(fullPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully at $fullPath'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // .db might not be a standard filter, try any first or custom
        // allowedExtensions: ['db'], // Windows sometimes has issues with specific extensions if filter is strict
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final backupPath = result.files.single.path!;
      
      // Verify extension (optional but good safety)
      if (!backupPath.toLowerCase().endsWith('.db')) {
        throw Exception('Selected file must be a .db database file');
      }

      final currentPath = DatabaseService.currentDatabasePath;
      if (currentPath == null) {
        throw Exception('Current database path not found');
      }

      // 2. Confirm Restore
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Data?'),
          content: const Text(
            'WARNING: This will overwite all current data with the selected backup.\n'
            'This action cannot be undone.\n\n'
            'Are you sure you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('RESTORE'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // 3. Perform Restore
      await DatabaseService.restoreDatabase(backupPath, currentPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully. You may need to restart the app.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Backup and restore your application data',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing data... Please wait.'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Backup Card
                    _buildActionCard(
                      context,
                      title: 'Backup Data',
                      description: 'Save a copy of your data to a secure location.',
                      icon: Icons.cloud_upload_outlined,
                      buttonText: 'Create Backup',
                      onTap: _backupData,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 32),
                    // Restore Card
                    _buildActionCard(
                      context,
                      title: 'Restore Data',
                      description: 'Restore your data from a previous backup file.',
                      icon: Icons.cloud_download_outlined,
                      buttonText: 'Restore Backup',
                      onTap: _restoreData,
                      color: AppColors.success, 
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
    required Color color,
  }) {
    return SizedBox(
      width: 300,
      height: 250,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
