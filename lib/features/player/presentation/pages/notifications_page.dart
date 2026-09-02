import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../widgets/notification_card.dart';
import '../widgets/screen_widgets.dart';
import '../../domain/providers/notifications_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: ScreenTitle(
              title: "Уведомления",
              actions: [
                Icon(Icons.done_all_rounded, size: 24, color: AppColors.accent),
              ],
            ),
          ),

          asyncNotifications.when(
            data: (items) {
              if (items.isEmpty) {
                return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.pageHorizontal,
                        right: AppSpacing.pageHorizontal,
                        top: AppSpacing.md,
                        bottom: AppSpacing.sm,
                      ),
                      child: IosCard(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            "У вас пока нет уведомлений",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final n = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: 8),
                    child: IosCard(
                      child: NotificationCard(
                        title: n.title,
                        description: n.description,
                        time: n.time,
                        iconColor: n.read ? AppColors.textSecondary : AppColors.accent,
                        isRead: n.read,
                      ),
                    ),
                  );
                }, childCount: items.length),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Ошибка загрузки уведомлений', style: TextStyle(color: Colors.white54)))),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
