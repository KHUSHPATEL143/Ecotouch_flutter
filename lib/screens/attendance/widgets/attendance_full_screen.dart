import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/attendance.dart';
import '../../../models/worker.dart';
import '../../../database/repositories/attendance_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/date_utils.dart' as app_date_utils;
import '../../../providers/global_providers.dart';
import '../../../widgets/status_badge.dart';

class AttendanceFullScreen extends ConsumerStatefulWidget {
  final List<Worker> workers;
  final List<Attendance> attendanceList;
  final VoidCallback onClose;

  const AttendanceFullScreen({
    super.key,
    required this.workers,
    required this.attendanceList,
    required this.onClose,
  });

  @override
  ConsumerState<AttendanceFullScreen> createState() => _AttendanceFullScreenState();
}

class _AttendanceFullScreenState extends ConsumerState<AttendanceFullScreen> {
  // Local state to track edits before saving?
  // Or save immediately? Design implies "Edit" button, suggesting row-level interaction.
  // We will map workers to attendance.
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Attendance Management (Full Screen)'),
            Text(
                  app_date_utils.DateUtils.formatDate(selectedDate),
                  style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
          tooltip: 'Close (Esc)',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Total Workers: ${widget.workers.length} | Present: ${widget.attendanceList.length}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
        },
        child: Focus(
          autofocus: true,
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark 
                        ? AppColors.darkSurfaceVariant 
                        : AppColors.lightSurfaceVariant,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border(bottom: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      _buildHeaderCell(context, 'Worker Name', flex: 3),
                      _buildHeaderCell(context, 'Status', flex: 2),
                      _buildHeaderCell(context, 'Time In', flex: 2),
                      _buildHeaderCell(context, 'Time Out', flex: 2),
                      _buildHeaderCell(context, 'Actions', flex: 2, align: TextAlign.center),
                    ],
                  ),
                ),
                
                // List
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.workers.length,
                    separatorBuilder: (c, i) => Divider(height: 1, color: theme.dividerColor),
                    itemBuilder: (context, index) {
                      final worker = widget.workers[index];
                      // Find attendance for this worker
                      final attendance = widget.attendanceList.firstWhere(
                        (a) => a.workerId == worker.id,
                        orElse: () => Attendance(
                          workerId: worker.id!,
                          date: selectedDate,
                          status: AttendanceStatus.fullDay, // Default for new, but won't be saved until marked
                          timeIn: '',
                        ),
                      );

                      final isMarked = widget.attendanceList.any((a) => a.workerId == worker.id);

                      return _AttendanceRow(
                        key: ValueKey(worker.id),
                        worker: worker,
                        attendance: attendance,
                        isMarked: isMarked,
                        onUpdate: () {
                           ref.invalidate(attendanceListProvider(selectedDate));
                           ref.invalidate(dashboardStatsProvider);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text, {int flex = 1, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}

class _AttendanceRow extends ConsumerStatefulWidget {
  final Worker worker;
  final Attendance attendance;
  final bool isMarked;
  final VoidCallback onUpdate;

  const _AttendanceRow({
    super.key, 
    required this.worker, 
    required this.attendance, 
    required this.isMarked,
    required this.onUpdate,
  });

  @override
  ConsumerState<_AttendanceRow> createState() => _AttendanceRowState();
}

class _AttendanceRowState extends ConsumerState<_AttendanceRow> {
  late AttendanceStatus _status;
  TimeOfDay? _timeIn;
  TimeOfDay? _timeOut;
  bool _isHovering = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.attendance.status;
    _timeIn = widget.attendance.timeIn != null && widget.attendance.timeIn!.isNotEmpty
        ? app_date_utils.DateUtils.parseTime(widget.attendance.timeIn!)
        : null;
    _timeOut = widget.attendance.timeOut != null && widget.attendance.timeOut!.isNotEmpty
        ? app_date_utils.DateUtils.parseTime(widget.attendance.timeOut!)
        : null;
  }
  
  @override
  void didUpdateWidget(_AttendanceRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attendance != widget.attendance || oldWidget.isMarked != widget.isMarked) {
         _status = widget.attendance.status;
        _timeIn = widget.attendance.timeIn != null && widget.attendance.timeIn!.isNotEmpty
            ? app_date_utils.DateUtils.parseTime(widget.attendance.timeIn!)
            : null;
        _timeOut = widget.attendance.timeOut != null && widget.attendance.timeOut!.isNotEmpty
            ? app_date_utils.DateUtils.parseTime(widget.attendance.timeOut!)
            : null;
    }
  }

  Future<void> _save({bool isDelete = false}) async {
    setState(() => _isSaving = true);
    try {
      if (isDelete) {
        if (widget.attendance.id != null) {
          await AttendanceRepository.delete(widget.attendance.id!);
        }
      } else {
        final newAttendance = widget.attendance.copyWith(
          workerName: widget.worker.name, // Ensure name is preserved
          status: _status,
          timeIn: _timeIn?.format(context) ?? '',
          timeOut: _timeOut?.format(context),
        );

        if (widget.isMarked && widget.attendance.id != null) {
          await AttendanceRepository.update(newAttendance);
        } else {
          // If inserting, ensure timeIn is set or default
          final toInsert = newAttendance.copyWith(
            timeIn: newAttendance.timeIn == null || newAttendance.timeIn!.isEmpty 
                ? const TimeOfDay(hour: 9, minute: 0).format(context) 
                : newAttendance.timeIn,
          );
          await AttendanceRepository.insert(toInsert);
        }
      }
      widget.onUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: _isHovering ? Theme.of(context).hoverColor : Colors.transparent,
        child: Row(
          children: [
            // Worker Name
            Expanded(
              flex: 3,
              child: Text(
                widget.worker.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            
            // Status
            Expanded(
              flex: 2,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AttendanceStatus>(
                  value: _status,
                  isDense: true,
                  style: Theme.of(context).textTheme.bodyMedium,
                  items: [
                    DropdownMenuItem(
                      value: AttendanceStatus.fullDay,
                      child: StatusBadge(label: 'Full Day', type: StatusType.success, compact: true),
                    ),
                    DropdownMenuItem(
                      value: AttendanceStatus.halfDay,
                      child: StatusBadge(label: 'Half Day', type: StatusType.warning, compact: true),
                    ),
                    DropdownMenuItem(
                      value: AttendanceStatus.absent,
                      child: StatusBadge(label: 'Absent', type: StatusType.error, compact: true),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                         setState(() => _status = val);
                         _save(); // Auto-save on change? User requested "Edit" button...
                         // Let's implement explicit save via the Edit/Save button logic as user requested.
                         // Wait, user said "Edit and Delete button". 
                         // "Edit" usually implies entering edit mode.
                         // But for a grid like this, direct manipulation is faster.
                         // Ideally, changes should be saved.
                         // I'll make the fields interactive but they only commit when you click "Save" or auto-save?
                         // "Edit" button at the end suggests read-only by default.
                         // But that's annoying for bulk entry.
                         // I will make it interactive and auto-save OR have a save button at the row end.
                         // User said: "another column where the user can select: ... And last column where the user can select timeout, and also at last edit and delete button."
                         // This implies the action column has the buttons.
                         // I'll implementing direct selection updates state, but 'Edit' button?
                         // Maybe the user means "Update" button to confirm changes?
                         // Or proper "Edit" mode where fields unlock?
                         // Let's go with: Fields are always editable for simplicity in Full Screen, the "Edit" button acts as a specific "Update" trigger if user wants to be explicit, or maybe it's "Save" if the row is new.
                    }
                  },
                ),
              ),
            ),
            
            // Time In
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: _timeIn ?? const TimeOfDay(hour: 9, minute: 0));
                  if (t != null) {
                    setState(() => _timeIn = t);
                    // _save(); 
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _timeIn?.format(context) ?? 'Set Time',
                    style: TextStyle(
                      color: _timeIn == null ? Theme.of(context).hintColor : null,
                      decoration: _timeIn == null ? TextDecoration.underline : null,
                      decorationStyle: TextDecorationStyle.dotted,
                    ),
                  ),
                ),
              ),
            ),
            
            // Time Out
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: _timeOut ?? const TimeOfDay(hour: 18, minute: 0));
                  if (t != null) {
                    setState(() => _timeOut = t);
                    // _save();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _timeOut?.format(context) ?? '-',
                    style: TextStyle(
                      color: _timeOut == null ? Theme.of(context).hintColor : null,
                    ),
                  ),
                ),
              ),
            ),
            
            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   if (_isSaving)
                     const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                   else ...[
                      // Save/Update Button (Visible if active or changed, or just always visible for clarity as 'Edit' was requested)
                      // If it's already marked, we show 'Edit' icon? Or 'Check' icon?
                      IconButton(
                        icon: Icon( widget.isMarked ? Icons.save_as_outlined : Icons.save_alt, 
                          color: widget.isMarked ? AppColors.primaryBlue : AppColors.success,
                          size: 20,
                        ),
                        tooltip: widget.isMarked ? 'Update' : 'Mark Present',
                        onPressed: () => _save(),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Delete Button (Only if marked)
                      if (widget.isMarked)
                        IconButton(
                           icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                           tooltip: 'Remove',
                           onPressed: () => _save(isDelete: true),
                        ),
                   ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
