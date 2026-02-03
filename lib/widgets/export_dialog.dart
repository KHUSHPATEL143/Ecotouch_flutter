import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ExportFormat { excel, pdf }
enum ExportScope { day, week, month, yearly }

class ExportConfig {
  final ExportFormat format;
  final ExportScope? scope;
  final DateTime? date; // For Day/Month Start
  final DateTimeRange? customRange; // For Week or Custom

  ExportConfig({
    required this.format,
    this.scope,
    this.date,
    this.customRange,
  });
}

class ExportDialog extends StatefulWidget {
  final bool showScopeSelector;
  final String title;

  const ExportDialog({
    super.key,
    this.showScopeSelector = true,
    this.title = 'Export Data',
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.excel;
  ExportScope _selectedScope = ExportScope.day;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Format Selection
            const Text('Select Format', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFormatChip(ExportFormat.excel, 'Excel', Icons.table_chart, Colors.green),
                const SizedBox(width: 12),
                _buildFormatChip(ExportFormat.pdf, 'PDF', Icons.picture_as_pdf, Colors.red),
              ],
            ),

            if (widget.showScopeSelector) ...[
              const SizedBox(height: 24),
              const Text('Select Period', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              
              // Scope Chips
              Row(
                children: [
                   _buildScopeChip(ExportScope.day, 'Daily'),
                   const SizedBox(width: 8),
                   _buildScopeChip(ExportScope.week, 'Weekly'),
                   const SizedBox(width: 8),
                   _buildScopeChip(ExportScope.month, 'Monthly'),
   const SizedBox(width: 8),
   _buildScopeChip(ExportScope.yearly, 'Yearly'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date Picker Trigger
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getFormattedDate(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final config = ExportConfig(
                    format: _selectedFormat,
                    scope: widget.showScopeSelector ? _selectedScope : null,
                    date: _selectedDate,
                  );
                  Navigator.pop(context, config);
                },
                icon: const Icon(Icons.download),
                label: const Text('Export File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatChip(ExportFormat format, String label, IconData icon, Color color) {
    final isSelected = _selectedFormat == format;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFormat = format),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Theme.of(context).disabledColor),
              const SizedBox(height: 4),
              Text(
                label, 
                style: TextStyle(
                  color: isSelected ? color : Theme.of(context).disabledColor,
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScopeChip(ExportScope scope, String label) {
    final isSelected = _selectedScope == scope;
    return Expanded(
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _selectedScope = scope);
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _getFormattedDate() {
    if (_selectedScope == ExportScope.month) {
      return DateFormat('MMMM yyyy').format(_selectedDate);
    } else if (_selectedScope == ExportScope.yearly) {
      return DateFormat('yyyy').format(_selectedDate);
    } else if (_selectedScope == ExportScope.week) {
        // Find start and end of week
        final start = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
    }
    return DateFormat('MMMM d, yyyy').format(_selectedDate);
  }
}
