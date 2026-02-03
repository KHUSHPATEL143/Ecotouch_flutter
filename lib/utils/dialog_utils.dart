import 'package:flutter/material.dart';
import '../utils/date_utils.dart' as app_date_utils;

class DialogUtils {
  static Future<bool> showDateWarning(BuildContext context, DateTime selectedDate) async {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && 
                    selectedDate.month == now.month && 
                    selectedDate.day == now.day;

    if (isToday) return true;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Confirm Date'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are adding data for a date that is not Today.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Selected Date: ${app_date_utils.DateUtils.formatDate(selectedDate)}'),
            const SizedBox(height: 16),
            const Text('Do you want to proceed?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true), // Proceed
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Proceed'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error, // Red warning
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}
