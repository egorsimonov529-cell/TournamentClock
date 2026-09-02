import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  double _balance = 12500;

  Future<void> _showOperationDialog({required bool deposit}) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(deposit ? 'Пополнение баланса' : 'Заявка на вывод'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Сумма, ₽',
              hintText: '1000',
            ),
            validator: (value) {
              final parsed = double.tryParse(
                (value ?? '').replaceAll(',', '.'),
              );
              if (parsed == null || parsed <= 0) {
                return 'Введите положительную сумму';
              }
              if (!deposit && parsed > _balance) {
                return 'Недостаточно средств';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  dialogContext,
                  double.parse(controller.text.replaceAll(',', '.')),
                );
              }
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null || !mounted) return;
    setState(() => _balance += deposit ? amount : -amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deposit
              ? 'Баланс пополнен на ${amount.toStringAsFixed(0)} ₽'
              : 'Заявка на вывод ${amount.toStringAsFixed(0)} ₽ создана',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Баланс и финансы",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildBalanceCard(),
          const SizedBox(height: 24),
          const Text(
            "История операций",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTransactionItem(
            type: "deposit",
            description: "Пополнение баланса",
            amount: "+₽10,000",
            date: "5 авг 2026, 14:30",
          ),
          _buildTransactionItem(
            type: "buyin",
            description: "Buy-in: Sunday Mega Tournament",
            amount: "-₽1,000",
            date: "5 авг 2026, 14:35",
          ),
          _buildTransactionItem(
            type: "prize",
            description: "Приз: Weekly Championship #11",
            amount: "+₽3,500",
            date: "3 авг 2026, 22:15",
          ),
          _buildTransactionItem(
            type: "buyin",
            description: "Buy-in: Weekly Championship #11",
            amount: "-₽5,000",
            date: "3 авг 2026, 19:00",
          ),
          _buildTransactionItem(
            type: "deposit",
            description: "Пополнение баланса",
            amount: "+₽25,000",
            date: "1 авг 2026, 10:00",
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Текущий баланс",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "₽ ${_balance.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "≈ \$145 USD",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _showOperationDialog(deposit: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Пополнить",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 160,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showOperationDialog(deposit: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Вывести",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String type,
    required String description,
    required String amount,
    required String date,
  }) {
    final isPositive = amount.startsWith('+');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPositive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isPositive ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isPositive ? AppColors.success : AppColors.error,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
