class Attendance {
  final int? id;
  final int workerId;
  final DateTime date;
  final AttendanceStatus status;
  final String? timeIn;
  final String? timeOut;
  
  // Optional: worker name for display
  final String? workerName;
  
  Attendance({
    this.id,
    required this.workerId,
    required this.date,
    required this.status,
    this.timeIn,
    this.timeOut,
    this.workerName,
  });
  
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int?,
      workerId: json['worker_id'] as int,
      date: DateTime.parse(json['date'] as String),
      status: AttendanceStatus.fromString(json['status'] as String),
      timeIn: json['time_in'] as String?,
      timeOut: json['time_out'] as String?,
      workerName: json['worker_name'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'worker_id': workerId,
      'date': date.toIso8601String().split('T')[0],
      'status': status.value,
      if (timeIn != null) 'time_in': timeIn,
      if (timeOut != null) 'time_out': timeOut,
    };
  }
  
  Attendance copyWith({
    int? id,
    int? workerId,
    DateTime? date,
    AttendanceStatus? status,
    String? timeIn,
    String? timeOut,
    String? workerName,
  }) {
    return Attendance(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      date: date ?? this.date,
      status: status ?? this.status,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      workerName: workerName ?? this.workerName,
    );
  }
}

enum AttendanceStatus {
  fullDay('full_day'),
  halfDay('half_day'),
  absent('absent');
  
  final String value;
  const AttendanceStatus(this.value);
  
  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendanceStatus.fullDay,
    );
  }
  
  String get displayName {
    switch (this) {
      case AttendanceStatus.fullDay:
        return 'Full Day';
      case AttendanceStatus.halfDay:
        return 'Half Day';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }
}
