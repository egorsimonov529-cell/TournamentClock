import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/transaction_item.dart';
import '../widgets/screen_widgets.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _filter = "Все";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: ScreenTitle(title: "История операций"),
          ),

          // Filters
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  FilterChipWidget(label: "Все", selected: true),
                  SizedBox(width: AppSpacing.sm),
                  FilterChipWidget(label: "Пополнения"),
                  SizedBox(width: AppSpacing.sm),
                  FilterChipWidget(label: "Выводы"),
                  SizedBox(width: AppSpacing.sm),
                  FilterChipWidget(label: "Турниры"),
                ],
              ),
            ),
          ),

          // Transactions list
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TransactionItem(
                  type: "Пополнение",
                  amount: "5 000 ₽",
                  date: "14 авг",
                  time: "14:32",
                  description: "Пополнение через СБП",
                  status: TransactionStatus.completed,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TransactionItem(
                  type: "Турнир",
                  amount: "-2 000 ₽",
                  date: "14 авг",
                  time: "21:00",
                  description: "Night Deepstack",
                  status: TransactionStatus.completed,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TransactionItem(
                  type: "Вывод",
                  amount: "-3 000 ₽",
                  date: "13 авг",
                  time: "10:15",
                  description: "Вывод на карту",
                  status: TransactionStatus.pending,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TransactionItem(
                  type: "Бонус",
                  amount: "+5 000 ₽",
                  date: "12 авг",
                  time: "09:00",
                  description: "Welcome Bonus",
                  status: TransactionStatus.completed,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TransactionItem(
                  type: "Турнир",
                  amount: "-1 000 ₽",
                  date: "10 авг",
                  time: "18:00",
                  description: "Sunday Special",
                  status: TransactionStatus.completed,
                ),
              ),
            ]),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
