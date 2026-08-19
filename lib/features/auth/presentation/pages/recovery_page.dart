import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final _controller = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    // TODO: Реализовать отправку на API
    setState(() => _sent = true);
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
                color: AppColors.accent.withOpacity(0.6),
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
                AppTextField(
                  label: "Email или телефон",
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  hintText: "ivan@example.com",
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: "Отправить инструкцию",
                  onPressed: _handleSend,
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
