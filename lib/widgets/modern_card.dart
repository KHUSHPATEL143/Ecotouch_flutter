import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Modern card widget with enhanced styling options
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Widget? header;
  final List<Widget>? headerActions;
  final bool showBorder;
  final double? elevation;
  final VoidCallback? onTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.header,
    this.headerActions,
    this.showBorder = true,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultPadding = padding ?? const EdgeInsets.all(20);

    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: header!),
                if (headerActions != null) ...headerActions!,
              ],
            ),
          ),
        child,
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(
            color: gradient == null
                ? (backgroundColor ??
                    (isDark ? AppColors.darkSurface : AppColors.lightSurface))
                : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(6),
            border: showBorder
                ? Border.all(
                    color: isDark
                        ? AppColors.border.withOpacity(0.5)
                        : AppColors.lightBorder,
                    width: 1,
                  )
                : null,
            boxShadow: elevation != null && elevation! > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                      blurRadius: elevation! * 2,
                      offset: Offset(0, elevation!),
                    ),
                  ]
                : null,
          ),
          padding: defaultPadding,
          child: cardContent,
        ),
      ),
    );
  }
}

/// Modern card header widget
class ModernCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;

  const ModernCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.primaryBlue,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
