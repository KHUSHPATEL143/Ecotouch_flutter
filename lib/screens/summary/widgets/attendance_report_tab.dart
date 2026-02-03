import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../database/database_service.dart';
import '../../../utils/date_utils.dart' as app_date_utils;
import '../../../providers/summary_providers.dart';
import '../../../widgets/export_dialog.dart';
import '../../../services/export_service.dart';

// Provider for attendance data
final attendanceReportProvider =
    FutureProvider.family<List<Map<String, dynamic>>, DateTimeRange>(
        (ref, range) async {
  final startStr = app_date_utils.DateUtils.formatDateForDatabase(range.start);
  final endStr = app_date_utils.DateUtils.formatDateForDatabase(range.end);

  // Get all workers first (assuming we have a workers table, or get distinct workers from attendance)
  // For now, getting distinct workers from attendance to ensure we show active ones
  // Ideal: SELECT * FROM workers

  // Join with workers table to get worker_name
  final records = await DatabaseService.rawQuery('''
    SELECT 
      a.worker_id,
      w.name as worker_name,
      a.date,
      a.status
    FROM attendance a
    JOIN workers w ON a.worker_id = w.id
    WHERE a.date BETWEEN ? AND ?
    ORDER BY w.name, a.date
  ''', [startStr, endStr]);

  return records;
});

// Provider for last 30 days stats (Current Health)
final recentAttendanceProvider = FutureProvider<Map<int, double>>((ref) async {
  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 30));

  final startStr = app_date_utils.DateUtils.formatDateForDatabase(start);
  final endStr = app_date_utils.DateUtils.formatDateForDatabase(end);

  final records = await DatabaseService.rawQuery('''
    SELECT 
      worker_id,
      status
    FROM attendance
    WHERE date BETWEEN ? AND ?
  ''', [startStr, endStr]);

  final Map<int, double> stats = {};

  for (final row in records) {
    final workerId = row['worker_id'] as int;
    final status = row['status'] as String;

    if (!stats.containsKey(workerId)) stats[workerId] = 0;

    if (status == 'full_day') {
      stats[workerId] = stats[workerId]! + 1.0;
    } else if (status == 'half_day') {
      stats[workerId] = stats[workerId]! + 1.0;
    }
  }

  return stats;
});


class AttendanceReportTab extends ConsumerStatefulWidget {
  const AttendanceReportTab({super.key});

  @override
  ConsumerState<AttendanceReportTab> createState() => _AttendanceReportTabState();
}

class _AttendanceReportTabState extends ConsumerState<AttendanceReportTab> {
  // Vertical Controllers for the 3 columns
  final ScrollController _verticalNameController = ScrollController();
  final ScrollController _verticalDataController = ScrollController();
  final ScrollController _verticalStatsController = ScrollController();

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // Sync all vertical controllers
    _verticalNameController.addListener(() => _syncScroll(_verticalNameController));
    _verticalDataController.addListener(() => _syncScroll(_verticalDataController));
    _verticalStatsController.addListener(() => _syncScroll(_verticalStatsController));
  }

  @override
  void dispose() {
    _verticalNameController.dispose();
    _verticalDataController.dispose();
    _verticalStatsController.dispose();
    super.dispose();
  }

  void _syncScroll(ScrollController source) {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      if (source != _verticalNameController && _verticalNameController.hasClients) {
        _verticalNameController.jumpTo(source.offset);
      }
      if (source != _verticalDataController && _verticalDataController.hasClients) {
        _verticalDataController.jumpTo(source.offset);
      }
      if (source != _verticalStatsController && _verticalStatsController.hasClients) {
        _verticalStatsController.jumpTo(source.offset);
      }
    } catch (e) {
      // Ignore scroll errors during dispose/init
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(reportDateRangeProvider);
    final viewMode = ref.watch(reportViewModeProvider);
    final attendanceAsync = ref.watch(attendanceReportProvider(dateRange));
    final recentStatsAsync = ref.watch(recentAttendanceProvider);

    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              _buildViewSelector(context, ref, viewMode),
              const SizedBox(width: 16),
              _buildDateNavigator(context, ref, dateRange),
              const Spacer(),
              _buildExportButton(context),
            ],
          ),
        ),

        // Matrix
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            child: attendanceAsync.when(
              data: (data) => recentStatsAsync.when(
                  data: (recentStats) => _buildAttendanceMatrix(
                      context, data, dateRange, recentStats),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error loading stats: $e'))),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ),
      ],
    );
  }

  // ... (View Selector and Date Navigator helpers remain same)
  Widget _buildViewSelector(
      BuildContext context, WidgetRef ref, ReportViewMode currentMode) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReportViewMode>(
          value: currentMode == ReportViewMode.daily
              ? ReportViewMode.weekly
              : currentMode,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 16, color: Theme.of(context).iconTheme.color),
          style: Theme.of(context).textTheme.bodyMedium,
          onChanged: (ReportViewMode? newValue) {
            if (newValue != null) {
              ref.read(reportViewModeProvider.notifier).state = newValue;
            }
          },
          items: ReportViewMode.values
              .where((m) => m != ReportViewMode.daily)
              .map<DropdownMenuItem<ReportViewMode>>((ReportViewMode mode) {
            return DropdownMenuItem<ReportViewMode>(
              value: mode,
              child: Text(mode.label),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateNavigator(
      BuildContext context, WidgetRef ref, DateTimeRange range) {
    final navigate = ref.read(reportNavigationProvider);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () => navigate(false),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.2)),
              ),
            ),
            child: Text(
              '${app_date_utils.DateUtils.formatDate(range.start)} - ${app_date_utils.DateUtils.formatDate(range.end)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => navigate(true),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleExport(context),
      icon: const Icon(Icons.download, size: 18),
      label: const Text('Export Report'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final config = await showDialog<ExportConfig>(
      context: context,
      builder: (c) => const ExportDialog(title: 'Export Attendance Matrix'),
    );

    if (config == null) return;
    
     DateTime start;
    DateTime end;

    if (config.scope == ExportScope.day) {
      start = config.date!;
      end = config.date!;
    } else if (config.scope == ExportScope.month) {
      start = config.date!;
      end = DateTime(start.year, start.month + 1, 0);
    } else if (config.scope == ExportScope.week) {
      start = app_date_utils.DateUtils.getStartOfWeek(config.date!);
      end = app_date_utils.DateUtils.getEndOfWeek(config.date!);
    } else {
      if (config.customRange == null) return;
      start = config.customRange!.start;
      end = config.customRange!.end;
    }

    try {
      final records = await DatabaseService.rawQuery('''
        SELECT 
          a.date,
          w.name as worker_name,
          a.status
        FROM attendance a
        JOIN workers w ON a.worker_id = w.id
        WHERE a.date BETWEEN ? AND ?
        ORDER BY a.date ASC, w.id ASC
      ''', [
        app_date_utils.DateUtils.formatDateForDatabase(start),
        app_date_utils.DateUtils.formatDateForDatabase(end)
      ]);

      if (records.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No data found for selected period')));
        }
        return;
      }
      
       final Set<String> workerNames = {};
      final Set<String> dates = {};
      final Map<String, Map<String, String>> matrix = {};

      for (var row in records) {
        final date = (row['date'] as String).split('T')[0];
        final worker = row['worker_name'] as String;
        final status = row['status'] as String;

        workerNames.add(worker);
        dates.add(date);

        if (!matrix.containsKey(date)) {
          matrix[date] = {};
        }
        matrix[date]![worker] = status;
      }

      final sortedDates = dates.toList()..sort();
      final sortedWorkers = workerNames.toList()..sort();

      final List<String> headers = [
        'Date',
        ...sortedWorkers,
        'Total Attendance'
      ];

      final List<List<dynamic>> rows = [];

      for (var date in sortedDates) {
        final List<dynamic> row = [];
        row.add(app_date_utils.DateUtils.formatDate(
            DateTime.parse(date))); 

        int presentCount = 0;
        int halfDayCount = 0;

        for (var worker in sortedWorkers) {
          final status = matrix[date]?[worker];
          if (status == 'full_day') {
            row.add('Present');
            presentCount++;
          } else if (status == 'half_day') {
            row.add('Half Day');
            halfDayCount++;
          } else {
            row.add('-'); 
          }
        }
        final List<String> summaryParts = [];
        if (presentCount > 0) summaryParts.add('Present:$presentCount');
        if (halfDayCount > 0) summaryParts.add('Half Day:$halfDayCount');
        row.add(summaryParts.isEmpty ? '-' : summaryParts.join(' '));

        rows.add(row);
      }
      
       final title =
          'Attendance Matrix (${app_date_utils.DateUtils.formatDate(start)} - ${app_date_utils.DateUtils.formatDate(end)})';

      String? path;
      if (config.format == ExportFormat.excel) {
        path = await ExportService().exportToExcel(
            title: title,
            headers: headers,
            data: rows,
            sheetName: 'Attendance Matrix');
      } else {
        path = await ExportService()
            .exportToPdf(title: title, headers: headers, data: rows);
      }

      if (context.mounted && path != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Exported to $path'),
            backgroundColor: AppColors.success));
      }
    } catch(e) {
      if(context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error));
      }
    }
  }

  Widget _buildAttendanceMatrix(
      BuildContext context,
      List<Map<String, dynamic>> rawData,
      DateTimeRange range,
      Map<int, double> recentStats) {
    
    // Process Data
    final Map<int, Map<String, String>> workerAttendance = {};
    final Map<int, String> workerNames = {};
    final Map<int, double> workerTotalPresentInView = {}; 

    for (var row in rawData) {
      final workerId = row['worker_id'] as int;
      final workerName = row['worker_name'] as String? ?? 'Unknown';
      final dateStr = (row['date'] as String).split('T')[0];
      final status = row['status'] as String;

      workerNames[workerId] = workerName;

      if (!workerAttendance.containsKey(workerId)) {
        workerAttendance[workerId] = {};
        workerTotalPresentInView[workerId] = 0;
      }

      workerAttendance[workerId]![dateStr] = status;
      if (status == 'full_day') {
        workerTotalPresentInView[workerId] = (workerTotalPresentInView[workerId] ?? 0) + 1.0;
      } else if (status == 'half_day') {
        workerTotalPresentInView[workerId] = (workerTotalPresentInView[workerId] ?? 0) + 0.5;
      }
    }

    // Days in range
    final daysCount = range.end.difference(range.start).inDays + 1;
    final days = List.generate(
        daysCount, (index) => range.start.add(Duration(days: index)));

    // Calculate Footer Stats
    final totalActiveWorkers = workerNames.length;
    double totalPresenceInView = 0;
    for(var p in workerTotalPresentInView.values) {
       totalPresenceInView += p;
    }
    
    final double avgAttendance = (totalActiveWorkers > 0 && daysCount > 0)
        ? (totalPresenceInView / (totalActiveWorkers * daysCount)) * 100
        : 0.0;

    // Dimensions
    const double nameColWidth = 180.0; // Slightly reduced for better fit on small screens
    const double dayColWidth = 50.0; // Compact
    const double statsColWidth = 180.0; // Compact
    const double rowHeight = 50.0;
    const double headerHeight = 50.0;
    
    // Sort workers by name
    final sortedWorkerIds = workerNames.keys.toList()..sort((a,b) => (workerNames[a] ?? '').compareTo(workerNames[b] ?? ''));

    return Column(
      children: [
        // Main Body: 3 Columns (Left Fixed, Middle Scrollable, Right Fixed)
        Expanded(
          child: Row(
            children: [
              // 1. LEFT COLUMN (Names) - Fixed Width
              SizedBox(
                width: nameColWidth,
                child: Column(
                  children: [
                    // Header
                    Container(
                      height: headerHeight,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                      ),
                      padding: const EdgeInsets.only(left: 24),
                      alignment: Alignment.centerLeft,
                      child: const Text('WORKER NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    // Body List
                    Expanded(
                      child: ListView.builder(
                        controller: _verticalNameController,
                        physics: const ClampingScrollPhysics(), // Important for sync
                        itemCount: sortedWorkerIds.length,
                        itemBuilder: (context, index) {
                          final workerId = sortedWorkerIds[index];
                          final name = workerNames[workerId]!;
                          return Container(
                            height: rowHeight,
                            padding: const EdgeInsets.only(left: 24),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.05))),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                                  child: Text(
                                    name.substring(0, 2).toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).textTheme.bodyMedium?.color),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500))),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 2. MIDDLE COLUMN (Data) - Scrollable Horizontal
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: days.length * dayColWidth,
                    child: Column(
                      children: [
                        // Header (With Days)
                        SizedBox(
                          height: headerHeight,
                          child: Container(
                             decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                              ),
                            child: Row(
                              children: days.map((date) => SizedBox(
                                width: dayColWidth,
                                child: Center(
                                  child: Text(
                                    '${date.day}/${date.month.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                        // Body List (Rows of Day Data)
                        Expanded(
                          child: ListView.builder(
                            controller: _verticalDataController,
                            physics: const ClampingScrollPhysics(), // Important for sync
                            itemCount: sortedWorkerIds.length,
                            itemBuilder: (context, index) {
                              final workerId = sortedWorkerIds[index];
                              final attendance = workerAttendance[workerId] ?? {};
                              return Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.05))),
                                ),
                                child: Row(
                                  children: days.map((date) {
                                    final dateStr = app_date_utils.DateUtils.formatDateForDatabase(date);
                                    final status = attendance[dateStr];
                                    return SizedBox(
                                      width: dayColWidth,
                                      child: Center(child: _buildStatusBadge(context, status)),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // 3. RIGHT COLUMN (Stats) - Fixed Width
              SizedBox(
                width: statsColWidth,
                child: Column(
                  children: [
                    // Header
                    Container(
                      height: headerHeight,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 60, child: Center(child: Text('TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
                          SizedBox(width: 60, child: Center(child: Text('%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
                          SizedBox(width: 60, child: Center(child: Text('30 DAYS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
                        ],
                      ),
                    ),
                    // Body List
                    Expanded(
                      child: ListView.builder(
                        controller: _verticalStatsController,
                        physics: const ClampingScrollPhysics(), // Important for sync
                        itemCount: sortedWorkerIds.length,
                        itemBuilder: (context, index) {
                          final workerId = sortedWorkerIds[index];
                          final totalInView = workerTotalPresentInView[workerId] ?? 0;
                          final viewPercent = (daysCount > 0) ? (totalInView / daysCount) * 100 : 0.0;
                          final recentTotal = recentStats[workerId] ?? 0;
                          
                          return Container(
                             height: rowHeight,
                             decoration: BoxDecoration(
                               border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.05))),
                             ),
                             child: Row(
                               children: [
                                 // Total
                                 SizedBox(
                                   width: 60,
                                   child: Center(
                                     child: Text(
                                       totalInView % 1 == 0 ? totalInView.toInt().toString() : totalInView.toString(),
                                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                     ),
                                   ),
                                 ),
                                 // %
                                 SizedBox(
                                   width: 60,
                                   child: Center(
                                     child: Text(
                                       '${viewPercent.toStringAsFixed(0)}%',
                                       style: TextStyle(
                                           fontSize: 13,
                                           fontWeight: FontWeight.w500,
                                           color: viewPercent < 50 ? AppColors.error : AppColors.success),
                                     ),
                                   ),
                                 ),
                                 // 30 Days
                                 SizedBox(
                                   width: 60,
                                   child: Center(
                                     child: Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                       decoration: BoxDecoration(
                                         color: Theme.of(context).dividerColor.withOpacity(0.05),
                                         borderRadius: BorderRadius.circular(12),
                                       ),
                                       child: Text(
                                         '${recentTotal % 1 == 0 ? recentTotal.toInt() : recentTotal}/30',
                                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                       ),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Footer (Active Workers count)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
             border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL ACTIVE WORKERS',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                  const SizedBox(height: 4),
                  Text('$totalActiveWorkers', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 48),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('AVG ATTENDANCE',
                       style: TextStyle(
                           fontSize: 10,
                           fontWeight: FontWeight.bold,
                           color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                   const SizedBox(height: 4),
                   Text('${avgAttendance.toStringAsFixed(1)}%',
                       style: TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: avgAttendance > 75 ? AppColors.success : (avgAttendance > 40 ? AppColors.warning : AppColors.error))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    if (status == null) {
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child:
            Text('—', style: TextStyle(color: Theme.of(context).disabledColor)),
      );
    }

    Color bgColor;
    Color textColor;
    String text;

    if (status == 'full_day') {
      bgColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
      text = 'P';
    } else if (status == 'half_day') {
      bgColor = AppColors.warning.withOpacity(0.1);
      textColor = AppColors.warning;
      text = 'H';
    } else if (status == 'absent') {
       bgColor = AppColors.error.withOpacity(0.1);
       textColor = AppColors.error;
       text = 'A';
    } else {
      // Default / fallback
      bgColor = AppColors.error.withOpacity(0.1);
      textColor = AppColors.error;
      text = 'A';
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
