import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../news/presentation/widgets/posts_feed.dart';

class IosNewsPage extends StatelessWidget {
  const IosNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Новости')),
      child: SafeArea(
        child: const PostsFeed(),
      ),
    );
  }
}
