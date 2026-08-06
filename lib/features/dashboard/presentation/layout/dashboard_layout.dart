import 'package:flutter/material.dart';

import '../../../../core/layout/app_window.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/stat_card/stat_card.dart';
import '../widgets/topbar/top_bar.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _selectedMenuIndex = 0;

  final List<String> _menuTitles = const [
    "Dashboard",
    "Игроки",
    "Турниры",
    "Финансы",
    "Лояльность",
    "Настройки",
    "Tournament Clock",
  ];

  @override
  Widget build(BuildContext context) {
    return AppWindow(
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: Sidebar(
              onMenuChange: (index) {
                setState(() {
                  _selectedMenuIndex = index;
                });
              },
              selectedIndex: _selectedMenuIndex,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                children: [

                  TopBar(
                    sectionTitle: _menuTitles[_selectedMenuIndex],
                  ),

                  const SizedBox(height: 30),

                  if (_selectedMenuIndex == 0) ...[
                    // Dashboard content - keep original UI
                    Row(
                      children: [

                        StatCard(
                          title: "Доход сегодня",
                          value: "₽248 300",
                          icon: Icons.payments_rounded,
                        ),

                        const SizedBox(width: 18),

                        StatCard(
                          title: "Игроков онлайн",
                          value: "154",
                          icon: Icons.people_alt_rounded,
                        ),

                        const SizedBox(width: 18),

                        StatCard(
                          title: "Активные столы",
                          value: "17",
                          icon: Icons.casino_rounded,
                        ),

                        const SizedBox(width: 18),

                        StatCard(
                          title: "Турниры",
                          value: "5",
                          icon: Icons.emoji_events_rounded,
                        ),

                      ],
                    ),

                    const SizedBox(height: 24),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff191D24),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            "Здесь будет график, таблицы и аналитика",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Placeholder for other sections
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff191D24),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 64,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _menuTitles[_selectedMenuIndex],
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Раздел в разработке",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
