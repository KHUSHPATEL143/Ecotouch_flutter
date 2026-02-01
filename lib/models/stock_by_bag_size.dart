class StockByBagSize {
  final int materialId;
  final String materialName;
  final double bagSize;
  final int bagCount;
  final double totalWeight;
  final String unit;
  final String containerUnit;
  
  StockByBagSize({
    required this.materialId,
    required this.materialName,
    required this.bagSize,
    required this.bagCount,
    required this.totalWeight,
    required this.unit,
    this.containerUnit = 'units',
  });
  
  @override
  String toString() {
    return '$bagCount packs ($bagSize $unit) = $totalWeight $unit total';
  }
}
