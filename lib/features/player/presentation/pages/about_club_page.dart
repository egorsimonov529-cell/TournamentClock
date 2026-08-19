import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/screen_widgets.dart';

class AboutClubPage extends StatelessWidget {
  const AboutClubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: ScreenTitle(title: '╨Ю ╨║╨╗╤Г╨▒╨╡')),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Icon(Icons.casino_rounded, size: 72, color: AppColors.accent),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Poker Club',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  '╨Ь╨╡╤Б╤В╨╛ ╨┤╨╗╤П ╤З╨╡╤Б╤В╨╜╨╛╨╣ ╨╕╨│╤А╤Л, ╤П╤А╨║╨╕╤Е ╤В╤Г╤А╨╜╨╕╤А╨╛╨▓ ╨╕ ╤Б╨╕╨╗╤М╨╜╨╛╨│╨╛ ╤Б╨╛╨╛╨▒╤Й╨╡╤Б╤В╨▓╨░.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '╨Э╨░╤И╨░ ╨╝╨╕╤Б╤Б╨╕╤П',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        '╨б╨╛╨╖╨┤╨░╨▓╨░╤В╤М ╨║╨╛╨╝╤Д╨╛╤А╤В╨╜╤Г╤О ╨╕ ╨▒╨╡╨╖╨╛╨┐╨░╤Б╨╜╤Г╤О ╤Б╤А╨╡╨┤╤Г ╨┤╨╗╤П ╨╕╨│╤А╨╛╨║╨╛╨▓ ╨╗╤О╨▒╨╛╨│╨╛ ╤Г╤А╨╛╨▓╨╜╤П.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: '╨Ь╨╛╤Б╨║╨▓╨░, ╤Ж╨╡╨╜╤В╤А ╨│╨╛╤А╨╛╨┤╨░',
                      ),
                      Divider(height: 24),
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        text: '╨Х╨╢╨╡╨┤╨╜╨╡╨▓╨╜╨╛ ╤Б 10:00 ╨┤╨╛ 02:00',
                      ),
                      Divider(height: 24),
                      _InfoRow(
                        icon: Icons.verified_user_outlined,
                        text:
                            '╨Ю╤В╨▓╨╡╤В╤Б╤В╨▓╨╡╨╜╨╜╨░╤П ╨╕╨│╤А╨░ ╨╕ ╤З╨╡╤Б╤В╨╜╤Л╨╡ ╨┐╤А╨░╨▓╨╕╨╗╨░',
                      ),
                    ],
                  ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.accent),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
