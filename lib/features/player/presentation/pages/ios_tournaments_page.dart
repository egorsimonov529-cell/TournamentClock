import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/tournaments_page.dart';

class IosTournamentsPage extends StatelessWidget {
  const IosTournamentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Турниры')),
      child: SafeArea(
        child: TournamentsPage(),
      ),
    );
  }
}
