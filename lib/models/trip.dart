class Trip {
  final int? id;
  final int vehicleId;
  final DateTime date;
  final String destination;
  final double startKm;
  final double endKm;
  final String? startTime; // Format: HH:mm
  final String? endTime;   // Format: HH:mm
  final double fuelCost;
  final double otherCost;
  final DateTime? createdAt;
  
  // Optional: associated vehicle name
  final String? vehicleName;
  final String? vehicleRegistrationNumber;
  
  Trip({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.destination,
    this.startKm = 0,
    this.endKm = 0,
    this.startTime,
    this.endTime,
    this.fuelCost = 0,
    this.otherCost = 0,
    this.createdAt,
    this.vehicleName,
    this.vehicleRegistrationNumber,
  });
  
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as int?,
      vehicleId: json['vehicle_id'] as int,
      date: DateTime.parse(json['date'] as String),
      destination: json['destination'] as String,
      startKm: (json['start_km'] as num?)?.toDouble() ?? 0,
      endKm: (json['end_km'] as num?)?.toDouble() ?? 0,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      fuelCost: (json['fuel_cost'] as num?)?.toDouble() ?? 0,
      otherCost: (json['other_cost'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      vehicleName: json['vehicle_name'] as String?,
      vehicleRegistrationNumber: json['registration_number'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'date': date.toIso8601String().split('T')[0],
      'destination': destination,
      'start_km': startKm,
      'end_km': endKm,
      'start_time': startTime,
      'end_time': endTime,
      'fuel_cost': fuelCost,
      'other_cost': otherCost,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
  
  Trip copyWith({
    int? id,
    int? vehicleId,
    DateTime? date,
    String? destination,
    double? startKm,
    double? endKm,
    String? startTime,
    String? endTime,
    double? fuelCost,
    double? otherCost,
    DateTime? createdAt,
    String? vehicleName,
    String? vehicleRegistrationNumber,
  }) {
    return Trip(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      destination: destination ?? this.destination,
      startKm: startKm ?? this.startKm,
      endKm: endKm ?? this.endKm,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      fuelCost: fuelCost ?? this.fuelCost,
      otherCost: otherCost ?? this.otherCost,
      createdAt: createdAt ?? this.createdAt,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleRegistrationNumber: vehicleRegistrationNumber ?? this.vehicleRegistrationNumber,
    );
  }
  
  double get totalDistance => (endKm > startKm) ? endKm - startKm : 0;
  double get totalCost => fuelCost + otherCost;
}
