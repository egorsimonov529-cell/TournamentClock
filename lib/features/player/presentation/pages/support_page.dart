import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/faq_item.dart';
import '../widgets/screen_widgets.dart';
import '../widgets/support_channel_card.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: ScreenTitle(title: 'Поддержка')),
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Связаться с нами'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SupportChannelCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Чат поддержки',
                  subtitle: 'Обычно отвечаем в течение 5 минут',
                ),
                SizedBox(height: AppSpacing.sm),
                SupportChannelCard(
                  icon: Icons.email_outlined,
                  title: 'Электронная почта',
                  subtitle: 'support@pokerclub.ru',
                ),
                SizedBox(height: AppSpacing.sm),
                SupportChannelCard(
                  icon: Icons.phone_outlined,
                  title: 'Телефон',
                  subtitle: 'Ежедневно с 10:00 до 23:00',
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Частые вопросы'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FAQItem(
                  question: 'Как зарегистрироваться на турнир?',
                  answer: 'Откройте турнир и нажмите кнопку регистрации.',
                ),
                FAQItem(
                  question: 'Как пополнить баланс?',
                  answer:
                      'Перейдите в раздел баланса и выберите удобный способ.',
                ),
                FAQItem(
                  question: 'Как восстановить доступ?',
                  answer:
                      'Используйте восстановление пароля на странице входа.',
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
