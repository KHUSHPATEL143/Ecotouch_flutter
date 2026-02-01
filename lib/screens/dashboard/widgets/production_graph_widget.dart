import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class ProductionGraphWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dailyStats;

  const ProductionGraphWidget({
    super.key,
    required this.dailyStats,
  });

  @override
  Widget build(BuildContext context) {
    // Generate last 7 days dates to ensure x-axis is complete
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    // Map stats to a dictionary for easy lookup
    final statsMap = {
      for (var stat in dailyStats) 
        stat['date'] as String: (stat['total_output'] as num).toDouble()
    };

    // Debug: Print received data
    print('📊 Production Graph Data:');
    print('  Daily Stats Count: ${dailyStats.length}');
    for (var stat in dailyStats) {
      print('  ${stat['date']}: ${stat['total_output']} units');
    }

    // Prepare Bar Groups
    List<BarChartGroupData> barGroups = [];
    double maxY = 10; // Minimum scale to ensure visibility

    for (int i = 0; i < last7Days.length; i++) {
      final date = last7Days[i];
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final value = statsMap[dateStr] ?? 0.0;
      
      print('  Day $i (${DateFormat('d/M').format(date)}): $value units');
      
      if (value > maxY) maxY = value;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value == 0 ? 0.1 : value, // Show tiny bar for zero values
              color: value == 0 ? AppColors.primaryBlue.withOpacity(0.3) : AppColors.primaryBlue,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY * 1.1,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      );
    }

    print('  Max Y value: $maxY');


    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Production History (Last 7 Days)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.1,
                  barGroups: barGroups,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Theme.of(context).cardColor,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                         return BarTooltipItem(
                          '${rod.toY.toInt()} Units',
                          const TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= last7Days.length) return const SizedBox.shrink();
                          final date = last7Days[value.toInt()];
                          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('d/M').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday ? AppColors.primaryBlue : Theme.of(context).hintColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
