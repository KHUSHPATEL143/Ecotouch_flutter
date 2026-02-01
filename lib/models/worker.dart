class Worker {
  final int? id;
  final String name;
  final String? city;
  final String? phone;
  final WorkerType type;
  final DateTime? createdAt;
  
  Worker({
    this.id,
    required this.name,
    this.city,
    this.phone,
    required this.type,
    this.createdAt,
  });
  
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as int?,
      name: json['name'] as String,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      type: WorkerType.fromString(json['type'] as String),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (city != null) 'city': city,
      if (phone != null) 'phone': phone,
      'type': type.value,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
  
  Worker copyWith({
    int? id,
    String? name,
    String? city,
    String? phone,
    WorkerType? type,
    DateTime? createdAt,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum WorkerType {
  labour('labour'),
  driver('driver');
  
  final String value;
  const WorkerType(this.value);
  
  static WorkerType fromString(String value) {
    return WorkerType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => WorkerType.labour,
    );
  }
  
  String get displayName {
    switch (this) {
      case WorkerType.labour:
        return 'Labourer';
      case WorkerType.driver:
        return 'Driver';
    }
  }
}
