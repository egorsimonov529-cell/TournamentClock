import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/my_seating_page.dart';

class IosMySeatingPage extends StatelessWidget {
  const IosMySeatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Рассадка')),
      child: SafeArea(
        child: MySeatingPage(),
      ),
    );
  }
}
