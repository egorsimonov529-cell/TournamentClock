import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/leaderboard_page.dart';

class IosLeaderboardPage extends StatelessWidget {
  const IosLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Рейтинг')),
      child: SafeArea(
        child: LeaderboardPage(),
      ),
    );
  }
}
