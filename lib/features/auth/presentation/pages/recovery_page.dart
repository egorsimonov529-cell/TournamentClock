import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/providers/auth_state_provider.dart';

class RecoveryPage extends ConsumerStatefulWidget {
  const RecoveryPage({super.key});

  @override
  ConsumerState<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends ConsumerState<RecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _sent = false;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    final success = await ref
        .read(authStateProvider.notifier)
        .requestPasswordReset(_controller.text.trim());

    if (!mounted) return;
    setState(() => _sending = false);

    if (success) {
      setState(() => _sent = true);
      return;
    }

    final message = ref.read(authStateProvider).message ??
        'Не удалось отправить инструкцию';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_reset_rounded,
                size: 64,
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 24),
              const Text(
                "Восстановление пароля",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Введите email или телефон, и мы отправим вам инструкции",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              if (!_sent) ...[
                Form(
                  key: _formKey,
                  child: AppTextField(
                    label: "Email или телефон",
                    controller: _controller,
                    keyboardType: TextInputType.emailAddress,
                    hintText: "ivan@example.com",
                    validator: (value) {
                      final input = value?.trim() ?? '';
                      if (input.isEmpty) return 'Введите email или телефон';
                      final isEmail = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(input);
                      final digits = input.replaceAll(RegExp(r'\D'), '');
                      if (!isEmail && digits.length < 10) {
                        return 'Введите корректный email или телефон';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _sending ? "Отправляем..." : "Отправить инструкцию",
                  onPressed: _sending ? null : _handleSend,
                ),
              ] else ...[
                const AppCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Инструкция отправлена!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Проверьте вашу почту или SMS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 24),
              GhostButton(
                label: "Вернуться ко входу",
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
