import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/tournament_list_item.dart';
import '../widgets/screen_widgets.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(child: ScreenTitle(title: "Турниры")),

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
                  FilterChipWidget(label: "Предстоящие"),
                  SizedBox(width: AppSpacing.sm),
                  FilterChipWidget(label: "Мои"),
                ],
              ),
            ),
          ),

          // Format filters
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
                  FilterChipWidget(label: "Холдем"),
                  SizedBox(width: AppSpacing.sm),
                  FilterChipWidget(label: "Омаха"),
                  SizedBox(width: AppSpacing.sm),
                  FilterChipWidget(label: "Сателлиты"),
                ],
              ),
            ),
          ),

          // Tournament list
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TournamentListItem(
                  name: "Night Deepstack",
                  date: "15 авг",
                  time: "21:00",
                  buyIn: "2 000 ₽",
                  prizePool: "150 000 ₽",
                  status: "Регистрация",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TournamentListItem(
                  name: "Sunday Special",
                  date: "17 авг",
                  time: "18:00",
                  buyIn: "1 000 ₽",
                  prizePool: "75 000 ₽",
                  status: "Скоро",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TournamentListItem(
                  name: "Progressive KO",
                  date: "18 авг",
                  time: "20:00",
                  buyIn: "5 000 ₽",
                  prizePool: "250 000 ₽",
                  status: "Регистрация",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: TournamentListItem(
                  name: "Satellite to Main Event",
                  date: "20 авг",
                  time: "19:00",
                  buyIn: "500 ₽",
                  prizePool: "Место в Main Event",
                  status: "Регистрация",
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
