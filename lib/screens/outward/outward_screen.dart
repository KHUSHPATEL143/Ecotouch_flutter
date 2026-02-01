import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../utils/validators.dart';
import '../../database/repositories/outward_repository.dart';
import '../../models/outward.dart';
import '../../models/product.dart';
import '../../providers/global_providers.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/summary_providers.dart';
import '../../widgets/status_badge.dart';
import '../../services/export_service.dart';
import '../../widgets/export_dialog.dart';
import '../../services/stock_calculation_service.dart';

final outwardListProvider = FutureProvider.family<List<Outward>, DateTime>((ref, date) async {
  return await OutwardRepository.getByDate(date);
});

// Remove local productStockProvider as we use improved inventory_providers
// final productStockProvider = ...

class OutwardScreen extends ConsumerStatefulWidget {
  const OutwardScreen({super.key});

  @override
  ConsumerState<OutwardScreen> createState() => _OutwardScreenState();
}

class _OutwardScreenState extends ConsumerState<OutwardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bagSizeController = TextEditingController();
  final _bagCountController = TextEditingController();
  final _notesController = TextEditingController();

  int? _editingId;
  Product? _selectedProduct;
  double _total = 0;
  String _displayUnit = 'kg';

  @override
  void dispose() {
    _bagSizeController.dispose();
    _bagCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadConvertedUnit(Product product) {
    setState(() {
      _displayUnit = product.unit ?? 'unit'; // Or converted unit
    });
  }

  Future<void> _handleExport() async {
    final config = await showDialog<ExportConfig>(
      context: context,
      builder: (c) => const ExportDialog(title: 'Export Sales History'),
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
    } else {
      start = config.customRange!.start;
      end = config.customRange!.end;
    }

    try {
      final data = await OutwardRepository.getByDateRange(start, end);
      
      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No shipment records found for selected period')),
          );
        }
        return;
      }

      final headers = [
        'Date', 
        'Notes / Customer', 
        'Product Name', 
        'Pack Size', 
        'Packs', 
        'Total Qty',
      ];

      final rows = data.map((e) => [
        app_date_utils.DateUtils.formatDate(e.date),
        e.notes ?? 'Unknown',
        e.productName ?? 'Unknown',
        e.bagSize.toString(),
        e.bagCount.toString(),
        e.totalWeight.toStringAsFixed(2),
      ]).toList();

      final title = 'Outward Sales Report (${app_date_utils.DateUtils.formatDate(start)} - ${app_date_utils.DateUtils.formatDate(end)})';

      if (config.format == ExportFormat.excel) {
        await ExportService().exportToExcel(
          title: title,
          headers: headers,
          data: rows,
        );
      } else {
        await ExportService().exportToPdf(
          title: title,
          headers: headers,
          data: rows,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final outwardAsync = ref.watch(outwardListProvider(selectedDate));
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
           Padding(
             padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
             child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outward Logistics (Sales)',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Record product shipments and sales',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Export Button
                IconButton(
                  onPressed: _handleExport,
                  icon: const Icon(Icons.download),
                  tooltip: 'Export Report',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.darkSurfaceVariant 
                        : AppColors.lightSurfaceVariant,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.darkSurfaceVariant 
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                      const SizedBox(width: 8),
                      Text(
                        app_date_utils.DateUtils.formatDate(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT PANEL: Entry Form (Flex 4)
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 32, right: 24, bottom: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _editingId == null ? 'New Shipment Entry' : 'Edit Shipment Entry',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                              ),
                              if (_editingId != null) const Spacer(),
                              if (_editingId != null)
                                TextButton.icon(
                                  onPressed: _clearForm,
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Cancel Edit'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                           // Product Dropdown
                             productsAsync.when(
                               data: (products) => DropdownButtonFormField<Product>(
                                 value: _selectedProduct,
                                 decoration: const InputDecoration(
                                   labelText: 'Product SKU *',
                                   hintText: 'Select product...',
                                   border: OutlineInputBorder(),
                                 ),
                                 items: products.map((product) {
                                   return DropdownMenuItem(
                                     value: product,
                                     child: Text(product.name),
                                   );
                                 }).toList(),
                                   onChanged: (product) {
                                     setState(() => _selectedProduct = product);
                                     if (product != null) _loadConvertedUnit(product);
                                   },
                                 validator: (value) => value == null ? 'Please select a product' : null,
                               ),
                               loading: () => const LinearProgressIndicator(),
                               error: (_, __) => const Text('Error loading products'),
                             ),
                                    
                             const SizedBox(height: 20),
                                    
                             // Bag Size
                             TextFormField(
                               controller: _bagSizeController,
                               decoration: InputDecoration(
                                 labelText: _selectedProduct?.unit != null ? 'Size per ${_selectedProduct!.unit}' : 'Pack Size',
                                 suffixText: _displayUnit,
                                 helperText: 'Size/Weight',
                                 border: const OutlineInputBorder(),
                               ),
                               keyboardType: TextInputType.number,
                               validator: (value) => Validators.positiveNumber(value, fieldName: 'Size'),
                               onChanged: (_) => setState(() {}),
                             ),

                             const SizedBox(height: 20),
                             
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Quantity
                                  Expanded(
                                    child: TextFormField(
                                        controller: _bagCountController,
                                        decoration: InputDecoration(
                                          labelText: 'Quantity',
                                          suffixText: _selectedProduct?.unit ?? 'Units',
                                          helperText: 'Total Count',
                                          border: const OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) => Validators.positiveInteger(value, fieldName: 'Quantity'),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                        height: 56,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total Shipment',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              '${_total.toStringAsFixed(2)} $_displayUnit',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          
                          const SizedBox(height: 20),
                          
                          // Notes Section
                           TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes / Customer / Dest.',
                                hintText: 'Customer, Location, Invoice...',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _submitEntry,
                              icon: Icon(_editingId == null ? Icons.check_circle_outline : Icons.save),
                              label: Text(_editingId == null ? 'Record Shipment' : 'Update Shipment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _editingId == null ? AppColors.success : AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Vertical Divider
                Container(
                  width: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),

                 // RIGHT PANEL: Log (Flex 6)
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 32, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         // Log Header
                         Padding(
                           padding: const EdgeInsets.all(16),
                           child: Row(
                          children: [
                            Text(
                              'Shipment History (Today)',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                            ),
                            const Spacer(),
                            StatusBadge(
                              label: '${outwardAsync.value?.length ?? 0} Shipments',
                              type: StatusType.neutral,
                            ),
                          ],
                        ),
                          ),
                        Divider(height: 1, color: Theme.of(context).dividerColor),

                        // Table
                        Expanded(
                          child: outwardAsync.when(
                              data: (outwardList) {
                                if (outwardList.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.local_shipping_outlined, size: 48, color: Theme.of(context).hintColor.withOpacity(0.3)),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No shipments recorded today',
                                          style: TextStyle(color: Theme.of(context).hintColor),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                
                                return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ListView.separated(
                                      itemCount: outwardList.length,
                                      separatorBuilder: (c, i) => Divider(height: 1, indent: 0, endIndent: 0, color: Theme.of(context).dividerColor),
                                      itemBuilder: (context, index) {
                                        final outward = outwardList[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      outward.productName ?? 'Unknown',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${outward.bagSize} kg × ${outward.bagCount} bags',
                                                      style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${outward.totalWeight.toStringAsFixed(2)} kg',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(outward.notes ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                                                  ],
                                                ),
                                              ),
                                              const StatusBadge(
                                                label: 'Shipped',
                                                type: StatusType.success,
                                                fontSize: 10,
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, size: 18),
                                                onPressed: () => _editOutward(outward),
                                                tooltip: 'Edit',
                                                color: AppColors.primaryBlue,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 18),
                                                onPressed: () => _deleteOutward(outward),
                                                tooltip: 'Delete',
                                                color: AppColors.error,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, s) => Center(child: Text('Error: $e')),
                           ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final selectedDate = ref.read(selectedDateProvider);
      final bagSize = double.parse(_bagSizeController.text);
      final bagCount = int.parse(_bagCountController.text);
      final total = bagSize * bagCount;
      
      // Validate stock availability
      final stockMap = await StockCalculationService.calculateProductStock(
        selectedDate,
      );
      
      // Calculate total stock from FIFO map for this product
      final currentStock = stockMap[_selectedProduct!.id] ?? 0;
      
      if (currentStock < total) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Insufficient stock. Available: ${currentStock.toStringAsFixed(2)} kg'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      
      final outward = Outward(
        id: _editingId,
        productId: _selectedProduct!.id!,
        date: selectedDate,
        bagSize: bagSize,
        bagCount: bagCount,
        totalWeight: total,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (_editingId != null) {
        await OutwardRepository.update(outward);
      } else {
        await OutwardRepository.insert(outward);
      }
      
      ref.invalidate(outwardListProvider(selectedDate));
      
      // Invalidate stock provider
      ref.invalidate(productStockProvider);
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingId != null ? 'Shipment updated successfully' : 'Outward shipment recorded successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Reset form
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _editOutward(Outward outward) async {
    // Find product object
    final products = await ref.read(productsProvider.future);
    final product = products.firstWhere(
      (p) => p.id == outward.productId,
      orElse: () => Product(name: 'Unknown', categoryId: 0),
    );

    setState(() {
      _editingId = outward.id;
      _selectedProduct = product.id != null ? product : null;
      _bagSizeController.text = outward.bagSize.toString();
      _bagCountController.text = outward.bagCount.toString();
      _notesController.text = outward.notes ?? '';
    });
  }

  Future<void> _deleteOutward(Outward outward) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shipment'),
        content: Text('Delete shipment of ${outward.productName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && outward.id != null) {
      await OutwardRepository.delete(outward.id!);
      
      if (_editingId == outward.id) {
        _clearForm();
      }

      final selectedDate = ref.read(selectedDateProvider);
      ref.invalidate(outwardListProvider(selectedDate));
      ref.invalidate(productStockProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shipment deleted'), backgroundColor: AppColors.success),
        );
      }
    }
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedProduct = null;
      _bagSizeController.clear();
      _bagCountController.clear();
      _notesController.clear();
    });
  }
}
