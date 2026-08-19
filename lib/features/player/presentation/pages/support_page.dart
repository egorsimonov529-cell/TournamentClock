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
          const SliverToBoxAdapter(
            child: ScreenTitle(title: '╨Я╨╛╨┤╨┤╨╡╤А╨╢╨║╨░'),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(title: '╨б╨▓╤П╨╖╨░╤В╤М╤Б╤П ╤Б ╨╜╨░╨╝╨╕'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SupportChannelCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: '╨з╨░╤В ╨┐╨╛╨┤╨┤╨╡╤А╨╢╨║╨╕',
                  subtitle:
                      '╨Ю╨▒╤Л╤З╨╜╨╛ ╨╛╤В╨▓╨╡╤З╨░╨╡╨╝ ╨▓ ╤В╨╡╤З╨╡╨╜╨╕╨╡ 5 ╨╝╨╕╨╜╤Г╤В',
                ),
                SizedBox(height: AppSpacing.sm),
                SupportChannelCard(
                  icon: Icons.email_outlined,
                  title: '╨н╨╗╨╡╨║╤В╤А╨╛╨╜╨╜╨░╤П ╨┐╨╛╤З╤В╨░',
                  subtitle: 'support@pokerclub.ru',
                ),
                SizedBox(height: AppSpacing.sm),
                SupportChannelCard(
                  icon: Icons.phone_outlined,
                  title: '╨в╨╡╨╗╨╡╤Д╨╛╨╜',
                  subtitle: '╨Х╨╢╨╡╨┤╨╜╨╡╨▓╨╜╨╛ ╤Б 10:00 ╨┤╨╛ 23:00',
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(title: '╨з╨░╤Б╤В╤Л╨╡ ╨▓╨╛╨┐╤А╨╛╤Б╤Л'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FAQItem(
                  question:
                      '╨Ъ╨░╨║ ╨╖╨░╤А╨╡╨│╨╕╤Б╤В╤А╨╕╤А╨╛╨▓╨░╤В╤М╤Б╤П ╨╜╨░ ╤В╤Г╤А╨╜╨╕╤А?',
                  answer:
                      '╨Ю╤В╨║╤А╨╛╨╣╤В╨╡ ╤В╤Г╤А╨╜╨╕╤А ╨╕ ╨╜╨░╨╢╨╝╨╕╤В╨╡ ╨║╨╜╨╛╨┐╨║╤Г ╤А╨╡╨│╨╕╤Б╤В╤А╨░╤Ж╨╕╨╕.',
                ),
                FAQItem(
                  question: '╨Ъ╨░╨║ ╨┐╨╛╨┐╨╛╨╗╨╜╨╕╤В╤М ╨▒╨░╨╗╨░╨╜╤Б?',
                  answer:
                      '╨Я╨╡╤А╨╡╨╣╨┤╨╕╤В╨╡ ╨▓ ╤А╨░╨╖╨┤╨╡╨╗ ╨▒╨░╨╗╨░╨╜╤Б╨░ ╨╕ ╨▓╤Л╨▒╨╡╤А╨╕╤В╨╡ ╤Г╨┤╨╛╨▒╨╜╤Л╨╣ ╤Б╨┐╨╛╤Б╨╛╨▒.',
                ),
                FAQItem(
                  question: '╨Ъ╨░╨║ ╨▓╨╛╤Б╤Б╤В╨░╨╜╨╛╨▓╨╕╤В╤М ╨┤╨╛╤Б╤В╤Г╨┐?',
                  answer:
                      '╨Ш╤Б╨┐╨╛╨╗╤М╨╖╤Г╨╣╤В╨╡ ╨▓╨╛╤Б╤Б╤В╨░╨╜╨╛╨▓╨╗╨╡╨╜╨╕╨╡ ╨┐╨░╤А╨╛╨╗╤П ╨╜╨░ ╤Б╤В╤А╨░╨╜╨╕╤Ж╨╡ ╨▓╤Е╨╛╨┤╨░.',
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
