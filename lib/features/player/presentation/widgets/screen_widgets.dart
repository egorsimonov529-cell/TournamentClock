import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Секция-разделитель на экране
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        bottom: AppSpacing.md,
        top: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          if (action != null)
            InkWell(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Фильтр-chip
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Заголовок экрана
class ScreenTitle extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final Widget? leading;
  final List<Widget>? actions;

  const ScreenTitle({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          ...?actions,
        ],
      ),
    );
  }
}
