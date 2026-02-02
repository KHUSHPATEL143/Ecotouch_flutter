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
    // Watch the provider directly to get updates when rows are modified
    final attendanceAsync = ref.watch(attendanceListProvider(selectedDate));
    
    // Fallback to passed list if loading/error, or use latest data
    final currentAttendanceList = attendanceAsync.value ?? widget.attendanceList;

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
                'Total Workers: ${widget.workers.length} | Present: ${currentAttendanceList.where((a) => a.status != AttendanceStatus.absent).length}',
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
                      // Find attendance for this worker in the UPDATED list
                      final attendance = currentAttendanceList.firstWhere(
                        (a) => a.workerId == worker.id,
                        orElse: () => Attendance(
                          workerId: worker.id!,
                          date: selectedDate,
                          status: AttendanceStatus.absent, // Default to Absent as per request
                          timeIn: '',
                        ),
                      );

                      final isMarked = currentAttendanceList.any((a) => a.workerId == worker.id);

                      return _AttendanceRow(
                        key: ValueKey('${worker.id}_${attendance.status}_${attendance.timeIn}'), // Force rebuild on change
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
  bool _isEditing = false; // Add editing state

  @override
  void initState() {
    super.initState();
    _initializeState();
    // If not marked, we are effectively 'editing' (entering new data)
    _isEditing = !widget.isMarked; 
  }
  
  void _initializeState() {
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
         _initializeState();
         // If unmarking (deleted externally?), go back to edit mode
         if (!widget.isMarked) _isEditing = true;
         // If marked, default to viewing, unless we are actively editing
         if (widget.isMarked && !_isEditing) _isEditing = false;
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
        // Validation: If status is Absent, Time In/Out optional?
        // If status is present/halfday, ensure consistency? 
        
        final newAttendance = widget.attendance.copyWith(
          workerName: widget.worker.name,
          status: _status,
          timeIn: _timeIn?.format(context) ?? '',
          timeOut: _timeOut?.format(context),
        );

        if (widget.isMarked && widget.attendance.id != null) {
           await AttendanceRepository.update(newAttendance);
        } else {
          // Defaults for Time In if not set but Marked Present
          String tIn = newAttendance.timeIn ?? '';
          if ((_status == AttendanceStatus.fullDay || _status == AttendanceStatus.halfDay) && tIn.isEmpty) {
             tIn = const TimeOfDay(hour: 9, minute: 0).format(context);
          }
           
          final toInsert = newAttendance.copyWith(timeIn: tIn);
          await AttendanceRepository.insert(toInsert);
        }
      }
      
      // Exit edit mode on save
      if (!isDelete) setState(() => _isEditing = false);
      
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
              child: _isEditing 
                ? DropdownButtonHideUnderline(
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
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                )
                : StatusBadge(
                    label: _status.displayName,
                    type: _status == AttendanceStatus.fullDay
                        ? StatusType.success
                        : (_status == AttendanceStatus.halfDay ? StatusType.warning : StatusType.error),
                    compact: true,
                  ),
            ),
            
            // Time In
            Expanded(
              flex: 2,
              child: _isEditing
                  ? InkWell(
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _timeIn ?? const TimeOfDay(hour: 9, minute: 0));
                        if (t != null) setState(() => _timeIn = t);
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
                    )
                  : Text(_timeIn?.format(context) ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            
            // Time Out
            Expanded(
              flex: 2,
              child: _isEditing
                  ? InkWell(
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _timeOut ?? const TimeOfDay(hour: 18, minute: 0));
                        if (t != null) setState(() => _timeOut = t);
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
                    )
                  : Text(_timeOut?.format(context) ?? '-'),
            ),
            
            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   if (_isSaving)
                     const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                   else if (_isEditing) ...[
                      // Save Button
                      IconButton(
                        icon: const Icon(Icons.check, color: AppColors.success, size: 20),
                        tooltip: 'Save',
                        onPressed: () => _save(),
                      ),
                      // Cancel Button (Only if it was already marked, i.e., we are updating)
                      if (widget.isMarked)
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error, size: 20),
                          tooltip: 'Cancel',
                          onPressed: () {
                             setState(() {
                               _initializeState();
                               _isEditing = false;
                             });
                          },
                        ),
                   ] else ...[
                      // Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                      // Delete Button
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
