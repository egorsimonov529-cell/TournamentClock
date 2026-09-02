import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/domain/admin_workspace_state.dart';

class PlayerNavigationItem {
  final IconData icon;
  final String label;

  const PlayerNavigationItem(this.icon, this.label);
}

class PlayerNavigationRail extends ConsumerWidget {
  final List<PlayerNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PlayerNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(adminWorkspaceProvider);
    final clubName = workspace.clubName.trim().isNotEmpty
        ? workspace.clubName
        : 'Poker Club';

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.casino_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      clubName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              ...List.generate(items.length, (index) {
                final item = items[index];
                final selected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: selected
                        ? AppColors.primary.withValues(alpha: .15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onSelected(index),
                      child: Semantics(
                        selected: selected,
                        button: true,
                        label: item.label,
                        child: SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(
                                item.icon,
                                color: selected
                                    ? AppColors.primary
                                    : Colors.white60,
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 15,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
