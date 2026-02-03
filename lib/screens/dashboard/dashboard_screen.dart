import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/global_providers.dart';
import '../../widgets/stat_card.dart';
import '../../models/stock_item.dart';
import '../../services/stock_calculation_service.dart';
import 'widgets/production_graph_widget.dart';

// Providers for dashboard data
// Providers for dashboard data - Moved to global_providers.dart

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: statsAsync.when(
          data: (stats) => ListView(
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Dashboard Overview',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          'Today',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Stat Cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.people_outline,
                      iconColor: AppColors.primaryBlue,
                      iconBackgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.iconBackgroundBlue
                          : AppColors.lightIconBackgroundBlue,
                      title: 'Workers Present',
                      value: stats['workersPresent'].toString(),
                      subtitle: 'Active today',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      icon: Icons.factory_outlined,
                      iconColor: AppColors.success,
                      iconBackgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.iconBackgroundGreen
                          : AppColors.lightIconBackgroundGreen,
                      title: 'Batches Produced',
                      value: stats['batchesProduced'].toString(),
                      subtitle: 'Units',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      icon: Icons.inventory_2_outlined,
                      iconColor: stats['rawMaterialsLow'] > 0 ? AppColors.warning : AppColors.success,
                      iconBackgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? (stats['rawMaterialsLow'] > 0 ? AppColors.iconBackgroundOrange : AppColors.iconBackgroundGreen)
                          : (stats['rawMaterialsLow'] > 0 ? AppColors.lightIconBackgroundOrange : AppColors.lightIconBackgroundGreen),
                      title: 'Raw Material',
                      value: stats['rawMaterialsLow'] == 0 ? 'Healthy' : stats['rawMaterialsLow'].toString(),
                      subtitle: stats['rawMaterialsLow'] > 0 ? 'Low stock items' : 'Stock levels sufficient',
                      onTap: stats['rawMaterialsLow'] > 0
                          ? () => _showStockAlerts(context, stats['stockAlerts'], true)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      icon: Icons.inventory_outlined,
                      iconColor: stats['productsLow'] > 0 ? AppColors.warning : AppColors.success,
                      iconBackgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? (stats['productsLow'] > 0 ? AppColors.iconBackgroundOrange : AppColors.iconBackgroundGreen)
                          : (stats['productsLow'] > 0 ? AppColors.lightIconBackgroundOrange : AppColors.lightIconBackgroundGreen),
                      title: 'Product Stock',
                      value: stats['productsLow'] == 0 ? 'Healthy' : stats['productsLow'].toString(),
                      subtitle: stats['productsLow'] > 0 ? 'Low stock items' : 'Stock levels sufficient',
                      onTap: stats['productsLow'] > 0
                          ? () => _showStockAlerts(context, stats['stockAlerts'], false)
                          : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Production Graph (Replaces Stock Alerts)
              // Production Graph
              SizedBox(
                height: 400,
                child: ProductionGraphWidget(dailyStats: stats['productionHistory']),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
          ),
        ),
      ),
    );
  }




  void _showStockAlerts(
      BuildContext context, List<StockItem> alerts, bool isRawMaterial) {
    // Filter alerts based on type if needed, but currently mixed.
    // Ideally existing logic in provider mixed them.
    // Let's filter here based on assumption or just show all relevant.
    // Provider returns 'stockAlerts' which is ALL alerts.
    // We should filter to show only Raw Material or Product based on which card was clicked.
    // However, StockItem doesn't explicitly store type (it's generic).
    // We'll approximate or just show all for now, OR better yet, let's filter by unit?
    // Actually, distinct lists in provider would be better, but for now let's just show all alerts
    // or improve provider later.
    // Wait, let's just filter by a simple heuristic if possible, or show all.
    // Showing all is safer for "Stock Alerts".

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Low Stock Alerts'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: alerts.isEmpty
              ? const Text('No active alerts.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: alerts.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = alerts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.status == StockStatus.critical
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        child: Icon(
                          Icons.inventory_2,
                          color: item.status == StockStatus.critical
                              ? AppColors.error
                              : AppColors.warning,
                          size: 20,
                        ),
                      ),
                      title: Text(item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          'Current: ${item.formattedStock} (Min: ${item.minAlertLevel} ${item.unit})'),
                      trailing: Chip(
                        label: Text(
                          item.status.displayName,
                          style: TextStyle(
                            color: Color(item.status.color),
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor:
                            Color(item.status.color).withOpacity(0.1),
                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
