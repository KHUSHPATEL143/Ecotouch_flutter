import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../database/database_service.dart';
import '../../../utils/validators.dart';
import '../../../providers/global_providers.dart';


class VehiclesManagement extends ConsumerWidget {
  const VehiclesManagement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicles',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage logistics vehicles',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showVehicleDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return Card(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 64, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text('No vehicles registered'),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => _showVehicleDialog(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Vehicle'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    child: SingleChildScrollView(
                      child: DataTable(
                        dataRowHeight: 60,
                        columns: const [
                          DataColumn(label: Text('Vehicle Name')),
                          DataColumn(label: Text('Registration Number')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: vehicles.map((vehicle) {
                          return DataRow(cells: [
                            DataCell(Text(vehicle['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? AppColors.darkSurfaceVariant 
                                    : AppColors.lightSurfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: Text(
                                vehicle['registration_number'] as String,
                                style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                              ),
                            )),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => _showVehicleDialog(context, ref, vehicle: vehicle),
                                  tooltip: 'Edit',
                                  color: AppColors.primaryBlue,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  onPressed: () => _deleteVehicle(context, ref, vehicle),
                                  tooltip: 'Delete',
                                  color: AppColors.error,
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleDialog(BuildContext context, WidgetRef ref, {Map<String, dynamic>? vehicle}) {
    showDialog(
      context: context,
      builder: (context) => _VehicleDialog(vehicle: vehicle),
    ).then((_) => ref.invalidate(vehiclesProvider));
  }

  Future<void> _deleteVehicle(BuildContext context, WidgetRef ref, Map<String, dynamic> vehicle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete "${vehicle['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService.delete('vehicles', where: 'id = ?', whereArgs: [vehicle['id']]);
        ref.invalidate(vehiclesProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle deleted'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}

class _VehicleDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? vehicle;

  const _VehicleDialog({this.vehicle});

  @override
  ConsumerState<_VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends ConsumerState<_VehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _odometerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _nameController.text = widget.vehicle!['name'] as String;
      _regNumberController.text = widget.vehicle!['registration_number'] as String;
      _modelController.text = widget.vehicle!['model'] as String? ?? '';
      _odometerController.text = (widget.vehicle!['odometer_reading'] as num?)?.toString() ?? '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNumberController.dispose();
    _modelController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'registration_number': _regNumberController.text.trim(),
        'model': _modelController.text.trim(),
        'odometer_reading': double.tryParse(_odometerController.text.trim()) ?? 0,
        // Preserve other fields if update
        if (widget.vehicle != null) 'id': widget.vehicle!['id'],
      };

      try {
        if (widget.vehicle == null) {
          await DatabaseService.insert('vehicles', data);
        } else {
          await DatabaseService.update('vehicles', data, where: 'id = ?', whereArgs: [widget.vehicle!['id']]);
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        // Handle error (e.g. unique constraint)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add Ctrl+S shortcut
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
      },
      child: Focus(
        autofocus: true,
        child: AlertDialog(
          title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Name *',
                      hintText: 'e.g. Truck 1',
                    ),
                    validator: (value) => Validators.required(value, fieldName: 'Vehicle Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _regNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Registration Number *',
                      hintText: 'e.g. MH12 AB 1234',
                    ),
                    validator: (value) => Validators.required(value, fieldName: 'Registration Number'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Model',
                      hintText: 'e.g. Tata Ace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _odometerController,
                    decoration: const InputDecoration(
                      labelText: 'Odometer Reading (km)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.positiveNumber(value, fieldName: 'Odometer Reading'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
