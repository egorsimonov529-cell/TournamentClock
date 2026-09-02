import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/admin_workspace_state.dart';

class AdminFinanceScreen extends ConsumerWidget {
  const AdminFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminWorkspaceProvider);
    final income = state.transactions
        .where((item) => item.amount > 0)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expenses = state.transactions
        .where((item) => item.amount < 0)
        .fold<double>(0, (sum, item) => sum + item.amount.abs());

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(
                title: 'Доходы',
                value: income,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Metric(
                title: 'Расходы',
                value: expenses,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Metric(
                title: 'Баланс',
                value: income - expenses,
                color: const Color(0xff00C875),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xff191D24),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Операции',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _addTransaction(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Добавить'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Операций пока нет',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: state.transactions.length,
                          separatorBuilder: (_, _) =>
                              const Divider(color: Color(0xff2A2D35)),
                          itemBuilder: (context, index) {
                            final item = state.transactions[index];
                            final positive = item.amount >= 0;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    (positive
                                            ? Colors.greenAccent
                                            : Colors.orangeAccent)
                                        .withValues(alpha: .12),
                                child: Icon(
                                  positive
                                      ? Icons.south_west_rounded
                                      : Icons.north_east_rounded,
                                  color: positive
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
                                ),
                              ),
                              title: Text(item.description),
                              subtitle: Text(
                                _formatDate(item.createdAt),
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: Text(
                                '${positive ? '+' : '-'}${item.amount.abs().toStringAsFixed(0)} ₽',
                                style: TextStyle(
                                  color: positive
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addTransaction(BuildContext context, WidgetRef ref) async {
    final description = TextEditingController();
    final amount = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новая операция'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Описание'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Введите описание'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Сумма',
                  helperText: 'Расход укажите со знаком минус',
                ),
                validator: (value) =>
                    double.tryParse((value ?? '').replaceAll(',', '.')) == null
                    ? 'Введите корректную сумму'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    
    // Освобождаем контроллеры сразу после закрытия диалога
    description.dispose();
    amount.dispose();
    
    if (result == true && context.mounted) {
      try {
        final parsedAmount = double.parse(amount.text.replaceAll(',', '.'));
        ref
            .read(adminWorkspaceProvider.notifier)
            .addTransaction(
              description.text.trim(),
              parsedAmount,
            );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Операция добавлена')));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _Metric extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const _Metric({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xff191D24),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(0)} ₽',
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
