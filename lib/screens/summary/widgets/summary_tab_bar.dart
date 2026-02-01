import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class SummaryTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const SummaryTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        tabs: tabs.map((tab) => Text(tab)).toList(),
      ),
    );
  }
}
