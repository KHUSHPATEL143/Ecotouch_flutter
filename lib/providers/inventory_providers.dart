import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_calculation_service.dart';
import '../models/stock_by_bag_size.dart';
import 'global_providers.dart';

final rawMaterialStockProvider = FutureProvider<Map<int, double>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  return await StockCalculationService.calculateRawMaterialStock(date);
});

final productStockProvider = FutureProvider<Map<int, double>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  return await StockCalculationService.calculateProductStock(date);
});

final rawMaterialStockByBagSizeProvider = FutureProvider<List<StockByBagSize>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  return await StockCalculationService.calculateRawMaterialStockByBagSize(date);
});

final productStockByBagSizeProvider = FutureProvider<List<StockByBagSize>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  return await StockCalculationService.calculateProductStockByBagSize(date);
});
