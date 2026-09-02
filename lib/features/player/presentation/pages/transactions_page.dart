import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/transaction_item.dart';
import '../widgets/screen_widgets.dart';
import '../../domain/providers/transactions_provider.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: ScreenTitle(title: "История операций"),
          ),

          // Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChipWidget(
                      label: "Все",
                      selected: _selectedFilter == 'all',
                      onTap: () {
                        setState(() => _selectedFilter = 'all');
                        ref.read(transactionsProvider.notifier).setFilter(null);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilterChipWidget(
                      label: "Пополнения",
                      selected: _selectedFilter == 'deposit',
                      onTap: () {
                        setState(() => _selectedFilter = 'deposit');
                        ref.read(transactionsProvider.notifier).setFilter('deposit');
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilterChipWidget(
                      label: "Выводы",
                      selected: _selectedFilter == 'withdraw',
                      onTap: () {
                        setState(() => _selectedFilter = 'withdraw');
                        ref.read(transactionsProvider.notifier).setFilter('withdraw');
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilterChipWidget(
                      label: "Турниры",
                      selected: _selectedFilter == 'tournament',
                      onTap: () {
                        setState(() => _selectedFilter = 'tournament');
                        ref.read(transactionsProvider.notifier).setFilter('tournament');
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilterChipWidget(
                      label: "Бонусы",
                      selected: _selectedFilter == 'bonus',
                      onTap: () {
                        setState(() => _selectedFilter = 'bonus');
                        ref.read(transactionsProvider.notifier).setFilter('bonus');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Transactions list
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'Нет операций',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return const SizedBox(height: AppSpacing.sm);
                    }
                    final transaction = transactions[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: TransactionItem(
                        type: _getTransactionType(transaction.type),
                        amount: _formatAmount(transaction.amount),
                        date: _formatDate(transaction.createdAt),
                        time: _formatTime(transaction.createdAt),
                        description: transaction.description,
                        status: _getStatusFromType(transaction.type),
                      ),
                    );
                  },
                  childCount: transactions.length + 1,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Ошибка загрузки: $error'),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => ref.refresh(transactionsProvider),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _getTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return 'Пополнение';
      case 'withdraw':
        return 'Вывод';
      case 'tournament':
        return 'Турнир';
      case 'bonus':
        return 'Бонус';
      case 'general':
      default:
        return 'Операция';
    }
  }

  String _formatAmount(double amount) {
    final formatted = amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    final prefix = amount >= 0 ? '+' : '-';
    return '$prefix$formatted ₽';
  }

  String _formatDate(DateTime date) {
    final months = ['', 'янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final month = months[date.month];
    return '${date.day} $month';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TransactionStatus _getStatusFromType(String type) {
    return TransactionStatus.completed;
  }
}
