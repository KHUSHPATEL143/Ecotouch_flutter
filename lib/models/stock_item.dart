import '../theme/app_colors.dart';

class StockItem {
  final int id;
  final String name;
  final double currentStock;
  final String unit;
  final double minAlertLevel;
  final StockStatus status;
  
  StockItem({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.unit,
    required this.minAlertLevel,
    required this.status,
  });
  
  factory StockItem.fromRawMaterial({
    required int id,
    required String name,
    required double currentStock,
    required String unit,
    required double minAlertLevel,
  }) {
    final status = _calculateStatus(currentStock, minAlertLevel);
    return StockItem(
      id: id,
      name: name,
      currentStock: currentStock,
      unit: unit,
      minAlertLevel: minAlertLevel,
      status: status,
    );
  }
  
  static StockStatus _calculateStatus(double currentStock, double minAlertLevel) {
    if (currentStock < minAlertLevel) {
      return StockStatus.critical;
    } else if (currentStock < minAlertLevel * 2) {
      return StockStatus.low;
    } else {
      return StockStatus.sufficient;
    }
  }
  
  String get formattedStock => '${currentStock.toStringAsFixed(2)} $unit';
}

enum StockStatus {
  sufficient,
  low,
  critical;
  
  String get displayName {
    switch (this) {
      case StockStatus.sufficient:
        return 'Sufficient';
      case StockStatus.low:
        return 'Low';
      case StockStatus.critical:
        return 'Critical';
    }
  }
  
  int get color {
    switch (this) {
      case StockStatus.sufficient:
        return AppColors.stockSufficient.value;
      case StockStatus.low:
        return AppColors.stockLow.value;
      case StockStatus.critical:
        return AppColors.stockCritical.value;
    }
  }
}
