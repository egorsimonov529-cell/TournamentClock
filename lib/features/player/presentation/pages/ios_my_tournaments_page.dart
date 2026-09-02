import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/my_tournaments_page.dart';

class IosMyTournamentsPage extends StatelessWidget {
  const IosMyTournamentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Мои турниры')),
      child: SafeArea(
        child: MyTournamentsPage(),
      ),
    );
  }
}
